import 'package:flutter/material.dart';
import 'package:koutan/add_sub_popup.dart';
import 'package:koutan/myapp.dart';
import 'package:provider/provider.dart';

class Log extends StatelessWidget {
  Log({Key? key, required this.inventoryLog}) : super(key: key);
  List<Inv> inventoryLog = [];

  @override
  Widget build(BuildContext context) {
    print("log rebuild");
    //var listener = context.watch<LogController>();
    print(inventoryLog);
    return Flexible(
      flex: 2,
      child: Container(
          margin: EdgeInsets.only(top: 45),
          width: 250,
          height: 600,
          child: Card(
              color: Colors.white,
              child: ListView(
                padding: EdgeInsets.all(10),
                children: inventoryLog.map((e) {
                  String type = "Received";
                  Color color = Colors.green;
                  var count = e.count;
                  if (count < 0) {
                    type = "Expended";
                    color = Colors.red;
                  }
                  count = count.abs();
                  String line = "${e.name}: $count $type";
                  return (SizedBox(
                      width: 200,
                      height: 75,
                      child: Card(
                        color: color,
                        child: Center(
                          child: Text(
                            line,
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )));
                }).toList(),
              ))),
    );
  }
}
