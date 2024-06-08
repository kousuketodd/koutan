import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  late String _selectedDate = "Date";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection("Logs").get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
          return Center(
            child: Column(children: [
              MenuAnchor(
                  builder: (context, controller, child) {
                    return TextButton(
                        style: TextButton.styleFrom(
                            minimumSize: Size(120, 40),
                            maximumSize: Size(120, 40)),
                        onPressed: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                        child: Text(_selectedDate));
                  },
                  menuChildren: List<MenuItemButton>.generate(
                      documents.length,
                      (int index) => MenuItemButton(
                          onPressed: () {
                            setState(() {
                              _selectedDate = documents[index].id.toString();
                            });
                          },
                          child: Text(documents[index].id.toString())))),
              Card(
                color: Colors.white,
                child: SizedBox(
                  width: 1000,
                  height: 600,
                  child: FutureBuilder(
                    future: FirebaseFirestore.instance.collection("Logs").doc(_selectedDate).get(),
                    builder:(context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }
                      if (snapshot.data!.id == "Date") {
                        return Center(child: Text("Enter a date in the dropdown above!"));
                      }
                      List<CategoryCard> categoryCards = [];
                      final data = snapshot.data!.data() as Map<String, dynamic>;
                      data.forEach((key, value) {
                        if (key != "dummy") {
                          categoryCards.add(CategoryCard(categoryName: key, date: _selectedDate));
                        }
                      });
                      return Center(child: Wrap(children: categoryCards));
                    }, // category cards
                  )
                )
              )
            ]),
          );
        },
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  const CategoryCard(
      {super.key, required this.categoryName, required this.date});
  final String categoryName;
  final String date;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([
          FirebaseFirestore.instance
              .collection("Categories")
              .doc(categoryName)
              .get(),
          FirebaseFirestore.instance
              .collection("Logs")
              .doc(date)
              .get(),
        ]),
        builder: ((context, snapshot) {
          List<Text> names = [Text("Name", style: TextStyle(fontWeight: FontWeight.bold))];
          List<Text> prices = [Text("Prices", style: TextStyle(fontWeight: FontWeight.bold))];
          List<Text> quantity = [Text("Quantity", style: TextStyle(fontWeight: FontWeight.bold))];
          List<Text> itemTotals = [Text("Subtotal", style: TextStyle(fontWeight: FontWeight.bold))];
          num total = 0;

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // get snapshots for each collection
          final categorySnapshot = snapshot.data![0].data() as Map<String, dynamic>;
          final logSnapshot = snapshot.data![1].data() as Map<String, dynamic>;

          logSnapshot[categoryName].forEach(
            (key, value) {
              categorySnapshot.forEach((key1, value1) {
                if (key1 == key) {
                  names.add(Text(key));
                  prices.add(Text(value1["price"].toString()));
                  quantity.add(Text(value.toString()));
                  itemTotals.add(
                      Text((value1["price"] * value).toString()));
                  total += value1["price"] * value;
                }
              });
            },
          );
          double colSpacing = 50;
          return Card(
              color: Color.fromARGB(255, 251, 207, 142),
              child: Container(
                  padding: EdgeInsets.all(30),
                  height: 300,
                  width: 450,
                  child: Column(
                    children: [
                      Row(children: [
                        Column(children: names),
                        SizedBox(width: colSpacing),
                        Column(children: prices),
                        SizedBox(width: colSpacing),
                        Column(children: quantity),
                        SizedBox(width: colSpacing),
                        Column(children: itemTotals),
                      ]),
                      SizedBox(height: 50),
                      Row(
                        children: [
                          SizedBox(width: 275),
                          Text("Total Price: $total"),
                        ],
                      )
                    ],
                  )));
        }));
  }
}
