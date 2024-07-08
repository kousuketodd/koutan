import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:koutan/myapp.dart';
import 'package:firebase_core/firebase_core.dart';

void submit(List<Inv> items, String date) async {
  print(items);
  final docRef = FirebaseFirestore.instance.collection("Logs").doc(date);
  final docSnapshot = await docRef.get();
  Map<String, dynamic> categories = docSnapshot.data()!;
  for (Inv item in items) {
    num count = item.count;
    if (item.type == "Expended") {
      count = -count;
    }
    // create a copy of items
    /*
    Food
      Gyoza : 50
      Ramen : 25
    */
    Map<String, dynamic> items = categories[item.category] ?? {};

    // if the category exists
    if (items.isNotEmpty) {
      // update the map
      // checks if it exists
      items[item.name] = (items[item.name] ?? 0) + count;
    } else {
      items[item.category] = count;
    }
    // link the updated category to the doc
    categories[item.category] = items;
  }
  await docRef.update(categories);
}

class Log extends StatefulWidget {
  Log({required this.inventoryLog, required this.callback});
  final List<Inv> inventoryLog;
  final Function callback;

  @override
  State<Log> createState() => _LogState();
}

class _LogState extends State<Log> {
  String _selectedDate = "Date";

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 45, right: 10),
        width: 400,
        height: 600,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: FutureBuilder(
                      future: FirebaseFirestore.instance.collection("Logs").get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text("Error: ${snapshot.error}"));
                        }
                        List<QueryDocumentSnapshot> documents =
                            snapshot.data!.docs;
                        return Center(
                            child: Column(children: [
                          MenuAnchor(
                              builder: (context, controller, child) {
                                return TextButton(
                                    style: TextButton.styleFrom(
                                        minimumSize: Size(120, 40),
                                        maximumSize: Size(120, 40),
                                        backgroundColor: Colors.blue),
                                    onPressed: () {
                                      if (controller.isOpen) {
                                        controller.close();
                                      } else {
                                        controller.open();
                                      }
                                    },
                                    child: Text(_selectedDate,
                                        style: TextStyle(color: Colors.white)));
                              },
                              menuChildren: List<MenuItemButton>.generate(
                                  documents.length,
                                  (int index) => MenuItemButton(
                                      onPressed: () {
                                        setState(() {
                                          _selectedDate =
                                              documents[index].id.toString();
                                        });
                                      },
                                      child:
                                          Text(documents[index].id.toString())))),
                        ]));
                      }),
                ),
                Flexible(child: SizedBox(width: 40)),
                Flexible(
                  child: FloatingActionButton.extended(
                    heroTag: null,
                    backgroundColor: Colors.blue,
                    label: Text(
                      "Enter a new date",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                  backgroundColor: Colors.white,
                                  title: Text("Date"),
                                  content: TextField(
                                    autofocus: true,
                                    decoration: InputDecoration(hintText: 'Enter a new date'),
                                    onChanged: (value) {
                                      _selectedDate = value;
                                    },
                                  ),
                                  actions: [
                                    FloatingActionButton(
                                      heroTag: null,
                                      backgroundColor:
                                          const Color.fromARGB(255, 65, 174, 69),
                                      onPressed: () {
                                        if (_selectedDate.isNotEmpty) {
                                          setState(() async {
                                            _selectedDate = _selectedDate;
                                            Navigator.pop(context);
                                          });
                                        }
                                      },
                                      child: Text("Submit",
                                          style: TextStyle(color: Colors.white)),
                                    )
                                  ]));
                    },
                  ),
                )
              ],
            ),
            Card(
                color: Colors.white,
                child: SizedBox(
                  width: 300,
                  height: 400,
                  child: ListView.builder(
                    itemCount: widget.inventoryLog.length,
                    itemBuilder: (context, index) {
                      Inv e = widget.inventoryLog[index];
                      String line = "${e.name}: ${e.count} ${e.type}";
                      return ListItem(
                        text: line,
                        color: e.color,
                        callback: widget.callback,
                        index: index,
                      );
                    },
                    padding: EdgeInsets.all(10),
                  ),
                )),
            FloatingActionButton(
                heroTag: null,
                backgroundColor: const Color.fromARGB(255, 65, 174, 69),
                onPressed: () {
                  if (_selectedDate != "Date") {
                    setState(() {
                      List<Inv> copy = List.from(widget.inventoryLog);
                      submit(copy, _selectedDate);
                      widget.inventoryLog.clear();
                    });
                  }
                },
                child: Text(
                  "Submit",
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ));
  }
}

class ListItem extends StatelessWidget {
  const ListItem(
      {required this.text,
      required this.color,
      required this.callback,
      required this.index});
  final String text;
  final Color color;
  final Function callback;
  final int index;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 200,
        height: 75,
        child: Card(
          color: color,
          child: Center(
            child: ListTile(
                title: Text(
                  text,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                trailing: SizedBox(
                    width: 70,
                    child: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        callback(index);
                      },
                    ))),
          ),
        ));
  }
}
