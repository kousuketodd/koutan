import 'package:flutter/material.dart';
import 'inventory_storage.dart';

class Tabs extends StatefulWidget {
  final Function callback;
  Tabs({Key? key, required this.callback}) : super (key: key);

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> with TickerProviderStateMixin {
  List <Widget> tabList = [];
  List <Widget> pageList = [];
  
  @override
  void initState() {
    super.initState();
    tabList = <InventoryTab> [InventoryTab()];
    pageList = <InventoryStorage> [InventoryStorage(callback: widget.callback,)];
  }


  @override
  Widget build(BuildContext context) {
  // var addButton = AddTab(onPressed: () {
  //   setState(() {
  //     tabList[tabList.length - 1] = InventoryTab();
  //     pageList.add(InventoryStorage());
  //   });
  // });

  // tabList.add(addButton);
  TabController _tabController = TabController(length: tabList.length, vsync: this);
  return Center(
    child: Expanded(
      flex: 2,
      child: Column(
        children: [
          // controls the dimensions of the tab bar
          SizedBox(
            width: 900,
            child: TabBar(
              controller: _tabController,
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
            height: 600,
            child: TabBarView(
              controller: _tabController,
              children: pageList,
            )
          )
          ],
        ),
    ),
  );
  }
}

class InventoryTab extends StatefulWidget {
  const InventoryTab({super.key});

  @override
  State<InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<InventoryTab> {
  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Align(
        alignment: Alignment.center,
        child: Text("InventoryTab")
      )
    );
  }
}

// class AddTab extends StatelessWidget {
//   final VoidCallback onPressed;
//   const AddTab({required this.onPressed});

//   @override
//   Widget build(BuildContext context) {
//     return FilledButton(
//       onPressed: () => onPressed(),
//       child: Icon(Icons.add),
//     );
//   }
// }