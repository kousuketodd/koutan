import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

void deleteItem(String folderName, String itemName, String path) async {
  // only delete image if it's not a dummy
  if (itemName != "dummy") {
    // obtain storage reference
    Reference referenceRoot = FirebaseStorage.instance.ref();
    // delete image from storage
    await referenceRoot.child(path).delete();
  }
  // delete firestore field
  await FirebaseFirestore.instance
      .collection("Categories")
      .doc(folderName)
      .update({itemName: FieldValue.delete()});
}

void deleteFolder(String name) async {
  final ref =
      await FirebaseFirestore.instance.collection("Categories").doc(name).get();
  final data = ref.data();
  data!.forEach((key, value) {
    deleteItem(name, value["name"], value["path"] ?? "");
  });
  await FirebaseFirestore.instance.collection("Categories").doc(name).delete();
}

class AdminPage extends StatelessWidget {
  final categories = FirebaseFirestore.instance.collection('Categories');
  final obtainedCategories =
      FirebaseFirestore.instance.collection('Categories').get();
  void createFolder(String name) async {
    final Map<String, dynamic> dummy = {
      "name": "",
      "price": "",
    };
    await categories.doc(name).set({"dummy": dummy});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              FloatingActionButton.extended(
                  backgroundColor: Colors.blue,
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return FolderPopup(
                            addCallback: createFolder,
                          );
                        });
                  },
                  label: Text("Add Category",
                      style: TextStyle(color: Colors.white))),
              SizedBox(height: 30),
              SizedBox(
                  width: 1000,
                  height: 600,
                  child: Card(
                      color: Colors.white,
                      child: FutureBuilder<QuerySnapshot>(
                        // can't obtain future here so that it can refresh on change
                        future: obtainedCategories,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text("${snapshot.error}");
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }

                          final data = snapshot.requireData;
                          return ListView.builder(
                            itemCount: data.size,
                            itemBuilder: (context, index) {
                              return Folder(name: data.docs[index].id);
                            },
                          );
                        },
                      )))
            ],
          ),
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
      title: Text("Name"),
      content: TextField(
          decoration: InputDecoration(hintText: "Enter a category name"),
          onChanged: (value) => name = value),
      actions: [
        FloatingActionButton.extended(
            backgroundColor: const Color.fromARGB(255, 65, 174, 69),
            onPressed: () {
              if (name != "") {
                addCallback(name);
                Navigator.pop(context);
              }
            },
            label: Text(
              "Submit",
              style: TextStyle(color: Colors.white),
            ))
      ],
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

  void addItem(String name, int price, XFile? file) async {
    final String folderName = widget.name;
    String imageUrl = '';
    if (file == null) {
      return;
    }

    // 2. upload to firebase storage
    // generate a unique name using the current date
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    // get a reference to storage root
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('images');

    // create a reference for the image to be stored
    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);
    // handle errors
    try {
      // store the file
      await referenceImageToUpload.putFile(File(file.path));
      // get download url
      imageUrl = await referenceImageToUpload.getDownloadURL();
    } catch (error) {
      return;
    }
    if (imageUrl.isEmpty) {
      return;
    }
    final Map<String, dynamic> itemData = {
      "name": name,
      "price": price,
      // used for fetching image from storage
      "image": imageUrl,
      // used for delete reference
      "path": "images/$uniqueFileName"
    };
    await db
        .collection("Categories")
        .doc(folderName)
        .set({name: itemData}, SetOptions(merge: true));
  }

  Icon arrow = Icon(Icons.arrow_right);
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
        future: categories.doc(widget.name).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;
          // add items to item list
          itemList.clear();
          data.forEach((key, value) {
            if (key != "dummy") {
              Item item = Item(
                name: value["name"],
                price: value["price"],
                url: value["image"],
                folderName: widget.name,
                path: value["path"],
              );

              itemList.add(item);
            }
          });
          // make list visible and change arrow icon
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
                      onPressed: () => setState(() => isOpen = !isOpen),
                      icon: arrow),
                  title: Text(widget.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return ItemPopup(addCallback: addItem);
                                });
                          },
                          icon: Icon(Icons.add)),
                      IconButton(
                          onPressed: () {
                            deleteFolder(widget.name);
                          },
                          icon: Icon(Icons.delete))
                    ],
                  )),
              Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(children: visibleItemList))
            ],
          );
        });
  }
}

class Item extends StatelessWidget {
  const Item(
      {super.key,
      required this.name,
      required this.price,
      required this.url,
      required this.folderName,
      required this.path});
  final String name;
  final int price;
  final String url;
  final String folderName;
  final String path;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(name),
        subtitle: Text("$price円"),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => deleteItem(folderName, name, path),
              icon: Icon(Icons.delete),
            ),
            Container(
              margin: EdgeInsets.only(left: 50),
              height: 80,
              width: 80,
              child: Image.network(url),
            ),
          ],
        ));
  }
}

class ItemPopup extends StatelessWidget {
  ItemPopup({super.key, required this.addCallback});
  final Function addCallback;

  Future<XFile?> addImage() async {
    // 1. pick image
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    XFile? file;
    String name = "";
    int price = 0;
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text("Name and Price"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
              decoration: InputDecoration(hintText: "Enter item name"),
              autofocus: true,
              onChanged: (value) => name = value),
          TextField(
              decoration: InputDecoration(hintText: "Enter item price"),
              autofocus: true,
              onChanged: (value) => price = int.parse(value)),
          SizedBox(height: 25),
          FloatingActionButton.extended(
              onPressed: () async {
                file = await addImage();
              },
              label: Row(
                children: [Icon(Icons.image), Icon(Icons.add)],
              ))
        ],
      ),
      actions: [
        FloatingActionButton(
            backgroundColor: const Color.fromARGB(255, 65, 174, 69),
            onPressed: () {
              if (name != "" && price != 0) {
                addCallback(name, price, file);
                Navigator.pop(context);
              }
            },
            child: Text("Submit", style: TextStyle(color: Colors.white)))
      ],
    );
  }
}
