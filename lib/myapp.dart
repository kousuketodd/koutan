import 'package:flutter/material.dart';
import 'tabs.dart';
import 'inventory_log.dart';
import 'edit_selector.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.grey.shade900,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class Inv {
  String name;
  int count;
  String type;
  Color color;
  String category;
  Inv(this.name, this.count, this.type, this.color, this.category);

  @override
  String toString() {
    return "$name: $count";
  }
}

class _HomePageState extends State<HomePage> {
  List<Inv> inventoryLog = [];
  // notified whenever user logs an item or deletes it from the log list
  // this way, it only rebuilds the log and not the whole page
  ValueNotifier<bool> _notifier = ValueNotifier(false);
  void logItem(String name, int count, String category) {
    if (count == 0) {
      return;
    }
    String type = "Received";
    Color color = Colors.green;
    if (count < 0) {
      type = "Expended";
      color = Colors.red;
    }
    count = count.abs();
    inventoryLog.add(Inv(name, count, type, color, category));
    // notify
    _notifier.value = !_notifier.value;
  }

  void deleteListedItem(int index) {
    inventoryLog.removeAt(index);
    // notify
    _notifier.value = !_notifier.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              EditSelect(),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Tabs(
                  callback: logItem,
                ),
                // wrap log in this so that only itself is rebuilt
                ValueListenableBuilder(
                    valueListenable: _notifier,
                    builder: (BuildContext context, bool val, Widget? child) {
                      return Log(
                        inventoryLog: inventoryLog,
                        callback: deleteListedItem,
                      );
                    }),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }
}
