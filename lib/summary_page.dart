import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  late String _selectedDate = "期間";
  // Helper function to fetch and calculate everything in one go
  Future<Map<String, dynamic>> _getFullSummary(String date) async {
    final results = await Future.wait([
      FirebaseFirestore.instance.collection("Categories").get(),
      FirebaseFirestore.instance.collection("Logs").doc(date).get(),
    ]);

    final categoryDocs = (results[0] as QuerySnapshot).docs;
    final logSnapshot = results[1] as DocumentSnapshot;
    final logData = logSnapshot.data() as Map<String, dynamic>?;

    num grandTotal = 0;
    List<Map<String, dynamic>> processedCategories = [];

    if (logData != null && logData['entries'] != null) {
      for (var doc in categoryDocs) {
        final catData = doc.data() as Map<String, dynamic>;
        num categorySubtotal = 0;
        List<Map<String, dynamic>> matchedItems = [];

        // Logic to match log entries with category items
        for (var entry in logData['entries']) {
          catData['items'].forEach((key, item) {
            if (entry['itemName'] == item['name']) {
              num sub = item['price'] * entry['quantity'];
              categorySubtotal += sub;
              matchedItems.add({
                'name': item['name'],
                'price': item['price'],
                'quantity': entry['quantity'],
                'subtotal': sub,
              });
            }
          });
        }

        if (matchedItems.isNotEmpty) {
          grandTotal += categorySubtotal;
          processedCategories.add({
            'name': catData['name'],
            'items': matchedItems,
            'total': categorySubtotal,
          });
        }
      }
    }

    return {'categories': processedCategories, 'grandTotal': grandTotal};
  }
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
            return Center(child: Text("エラー: ${snapshot.error}"));
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
                  child: Container(
                      padding: EdgeInsets.all(25),
                      width: 1000,
                      height: 600,
                      child: FutureBuilder(
                        future: _getFullSummary(_selectedDate),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                                child: Text("エラー: ${snapshot.error}"));
                          }
                          if (_selectedDate == "期間") {
                            return Center(
                                child: Text(
                                    "上のドロップダウンに期間を選んでください。"));
                          }
                          final categories = snapshot.data!['categories'] as List;
                          final total = snapshot.data!['grandTotal'];
                          // displays total once it is calculated
                          return Stack(
                            alignment: AlignmentDirectional.topCenter,
                            children: [
                              Wrap(children: categories.map((c) => CategoryCard(data: c)).toList(),),
                              Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Text(
                                    "総計: $total円",
                                    style: TextStyle(fontSize: 30),
                                  ))
                            ],
                          );
                        },
                      )))
            ]),
          );
        },
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const CategoryCard({super.key, required this.data});

  // Helper to build a consistent row layout
  Widget _buildRow(String name, String qty, String price, String sub, {bool isHeader = false}) {
    TextStyle style = TextStyle(
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
      fontSize: isHeader ? 14 : 14,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(name, style: style)),
          Expanded(flex: 2, child: Text(qty, style: style, textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text(price, style: style, textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text(sub, style: style, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 251, 207, 142),
      margin: const EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: 450, // Slightly wider to accommodate columns
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['name'],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // The Header Row
            _buildRow("品名", "数", "値段", "小計", isHeader: true),
            const Divider(color: Colors.black26),
            // The Data Rows
            ... (data['items'] as List).map((item) {
              return _buildRow(
                item['name'].toString(),
                item['quantity'].toString(),
                "${item['price']}円",
                "${item['subtotal']}円",
              );
            }),
            const Divider(),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "合計: ${data['total']}円",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}