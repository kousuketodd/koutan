import 'package:flutter/material.dart';
import 'inventory_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Tabs extends StatefulWidget {
  final Function callback;
  Tabs({Key? key, required this.callback}) : super(key: key);

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> with TickerProviderStateMixin {
  List<InventoryTab> tabList = [];
  List<InventoryStorage> pageList = [];
  int tabLength = 0;

  @override
  Widget build(BuildContext context) {
    final categories = FirebaseFirestore.instance.collection('Categories');
    // populate tabs and their corresponding pages
    categories.get().then((querySnapshot) {});
    return FutureBuilder<QuerySnapshot>(
        // future builder lets the code wait until the data is retrieved
        future: FirebaseFirestore.instance.collection("Categories").get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final querySnapshot = snapshot.data!;
          tabList.clear();
          pageList.clear();
          for (var docSnaphot in querySnapshot.docs) {
            tabList.add(InventoryTab(name: docSnaphot.id));
            pageList.add(InventoryStorage(
              callback: widget.callback,
              folderName: docSnaphot.id,
            ));
          }
          TabController tabController =
              TabController(length: tabList.length, vsync: this);
          return Center(
            child: Column(
              children: [
                // controls the dimensions of the tab bar
                SizedBox(
                  width: 900,
                  child: TabBar(
                    controller: tabController,
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorColor: Colors.transparent,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      color: Colors.grey,
                    ),
                    tabs: tabList,
                  ),
                ),
                // controls the dimensions of the pagelist
                SizedBox(
                    width: 925,
                    height: 500,
                    child: TabBarView(
                      controller: tabController,
                      children: pageList,
                    ))
              ],
            ),
          );
        });
  }
}

class InventoryTab extends StatelessWidget {
  const InventoryTab({super.key, required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Tab(child: Align(alignment: Alignment.center, child: Text(name)));
  }
}
