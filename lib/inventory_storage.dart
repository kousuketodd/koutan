import 'package:flutter/material.dart';
import 'items.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryStorage extends StatefulWidget {
  final Function callback;
  final String folderName;
  InventoryStorage(
      {Key? key, required this.callback, required this.folderName});

  @override
  State<InventoryStorage> createState() => _InventoryStorageState();
}

class _InventoryStorageState extends State<InventoryStorage> {
  List<Item> itemList = [];
  final categories = FirebaseFirestore.instance.collection('Categories');
  @override
  Widget build(BuildContext context) {
    categories.doc(widget.folderName).get().then((DocumentSnapshot doc) {});
    return FutureBuilder<DocumentSnapshot>(
      // future builder lets the code wait until the data is retrieved
      future: FirebaseFirestore.instance
          .collection("Categories")
          .doc(widget.folderName)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        final docSnapshot = snapshot.data!.data() as Map<String, dynamic>;
        // prevents items being duplicated each time
        itemList.clear();
        docSnapshot.forEach((key, value) {
          if (value["name"] != "" &&
              value["name"] is String &&
              value["price"] != "" &&
              value["price"] is String) {
            Item item = Item(
                name: value["name"],
                price: value["price"],
                callback: widget.callback);
            itemList.add(item);
          }
        });
        return Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          child: Card(
            color: Colors.grey,
            child: ListView(
              padding: EdgeInsets.all(50),
              children: [
                Wrap(
                  spacing: 20,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 20,
                  // inventory storage
                  children: itemList,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
