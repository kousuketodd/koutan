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
  Inv(this.name, this.count, this.type, this.color);

  @override
  String toString() {
    return "$name: $count";
  }
}

class _HomePageState extends State<HomePage> {
  List<Inv> inventoryLog = [];
  void logItem(String name, int count) {
    setState(() {
      String type = "Received";
      Color color = Colors.green;
      if (count < 0) {
        type = "Expended";
        color = Colors.red;
      }
      count = count.abs();
      inventoryLog.add(Inv(name, count, type, color));
    });
    print(inventoryLog);
  }

  @override
  Widget build(BuildContext context) {
    print('rebuilding');
    return Scaffold(
      body: Column(
        children: [
          EditSelect(),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Tabs(
              callback: logItem,
            ),
            Log(
              inventoryLog: inventoryLog,
            )
          ]),
        ],
      ),
    );
  }
}
