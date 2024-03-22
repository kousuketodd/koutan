import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  final Stream<QuerySnapshot> categories = FirebaseFirestore.instance.collection('Categories').snapshots();
  final db = FirebaseFirestore.instance.collection('Categories');
  void createFolder(String name) async {
    final folderName = name;
    final Map<String, dynamic> dummy = {
      "name" : "",
      "price": "",
    };
    await db.doc(folderName).set({"dummy" : dummy});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            FloatingActionButton.extended(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return FolderPopup(
                          addCallback: createFolder,
                        );
                      });
                },
                label: Text("Add Category")),
            SizedBox(height: 30),
            SizedBox(
                width: 1000,
                height: 600,
                child: Card(
                    color: Colors.white,
                    child: StreamBuilder<QuerySnapshot>(stream: categories, builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text("Something went wrong!");
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text("Loading...");
                      }

                      final data = snapshot.requireData;
                      return ListView.builder(
                        itemCount: data.size,
                        itemBuilder: (context, index) {
                          return Folder(name: data.docs[index].id);
                        },
                      );
                    },)
                    ))
          ],
        ));
  }
}

class FolderPopup extends StatelessWidget {
  FolderPopup({super.key, required this.addCallback});
  final Function addCallback;

  String name = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      content: SizedBox(
        height: 150,
        width: 200,
        child: Column(
          children: [
            Row(
              children: [
                Text("Name"),
                SizedBox(width: 25),
                Container(
                    height: 50,
                    width: 120,
                    color: Colors.grey,
                    child: TextField(
                      onChanged: (value) => name = value,
                    ))
              ],
            ),
            SizedBox(height: 25),
            FloatingActionButton.extended(
                onPressed: () {
                  if (name == "") {
                    return;
                  }
                  Navigator.pop(context);
                  addCallback(name);
                },
                label: Text("Submit"))
          ],
        ),
      ),
    );
  }
}

class Folder extends StatefulWidget {
  Folder({super.key, required this.name});
  final String name;

  @override
  State<Folder> createState() => _FolderState();
}

// -------------------- READ ITEM LIST --------------------------
class _FolderState extends State<Folder> {
  List<Item> itemList = [];
  List<Item> visibleItemList = [];
  final db = FirebaseFirestore.instance;
  final categories = FirebaseFirestore.instance.collection("Categories");
  //final Stream<QuerySnapshot> categories = FirebaseFirestore.instance.collection('Categories').snapshots();

  void addItem(String name, String price) async {
    final String folderName = widget.name;
    final Map<String, dynamic> itemData = {
      "name": name,
      "price": price
    };
    await db.collection("Categories").doc(folderName).set({name:itemData}, SetOptions(merge: true));
  }

  Icon arrow = Icon(Icons.arrow_right);
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    final docRef = categories.doc(widget.name);
    docRef.get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        // prevents items being duplicated each time
        itemList.clear();
        data.forEach((key, value) {
          if (value["name"] != "" && value["name"] is String && value["price"] != "" && value["price"] is String) {
            Item item = Item(name: value["name"], price: value["price"]);
            itemList.add(item);
          }
        });
      }
    );
    if (isOpen) {
      visibleItemList = itemList;
      arrow = Icon(Icons.arrow_drop_down);
    } else {
      visibleItemList = [];
      arrow = Icon(Icons.arrow_right);
    }
    return Column(
      children: [
        ListTile(
            leading: IconButton(
                onPressed: () => setState(() => isOpen = !isOpen), icon: arrow),
            title: Text(widget.name),
            trailing: IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ItemPopup(addCallback: addItem);
                      });
                },
                icon: Icon(Icons.add))),
        Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(children: visibleItemList))
      ],
    );
  }
}

class Item extends StatelessWidget {
  const Item({super.key, required this.name, required this.price});
  final String name;
  final String price;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 50,
        width: 200,
        child:
            Row(children: [Text(name), SizedBox(width: 50), Text("$price円")]));
  }
}

class ItemPopup extends StatelessWidget {
  ItemPopup({super.key, required this.addCallback});
  String name = "";
  String price = "";
  final Function addCallback;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        backgroundColor: Colors.white,
        content: SizedBox(
            height: 220,
            width: 200,
            child: Column(
              children: [
                Row(children: [
                  Text("Name"),
                  SizedBox(width: 30),
                  Container(
                      height: 50,
                      width: 120,
                      color: Colors.grey,
                      child: TextField(onChanged: (value) => name = value))
                ]),
                SizedBox(height: 30),
                Row(children: [
                  Text("Price"),
                  SizedBox(width: 30),
                  Container(
                      height: 50,
                      width: 120,
                      color: Colors.grey,
                      child: TextField(onChanged: (value) => price = value))
                ]),
                SizedBox(height: 30),
                FloatingActionButton.extended(
                    onPressed: () {
                      addCallback(name, price);
                      Navigator.pop(context);
                    },
                    label: Text("Submit"))
              ],
            )));
  }
}
