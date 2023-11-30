import 'package:flutter/material.dart';
import 'package:koutan/add_sub_popup.dart';
import 'package:provider/provider.dart';

class Log extends StatelessWidget {
  Log({Key? key, required this.inventoryLog}) : super (key: key);
  List<Widget> inventoryLog = [];

  @override
  Widget build(BuildContext context) {
    //var listener = context.watch<LogController>();
    return Flexible(
      flex: 2,
      child: Container(
        margin: EdgeInsets.only(
          top: 45
        ),
        width: 250,
        height: 600,
        child: Card(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.all(10),
            children: inventoryLog,
          )
        )
      ),
    );
  }
}