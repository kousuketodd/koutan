import 'package:flutter/material.dart';
import 'package:koutan/myapp.dart';

class Log extends StatelessWidget {
  Log({required this.inventoryLog, required this.callback});
  final List<Inv> inventoryLog;
  final Function callback;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: Container(
          margin: EdgeInsets.only(top: 45, right: 10),
          width: 400,
          height: 600,
          child: Card(
              color: Colors.white,
              child: ListView.builder(
                itemCount: inventoryLog.length,
                itemBuilder: (context, index) {
                  Inv e = inventoryLog[index];
                  String line = "${e.name}: ${e.count} ${e.type}";
                  return ListItem(text: line, color: e.color, callback: callback, index: index,);
                },
                padding: EdgeInsets.all(10),
              ))),
    );
  }
}

class ListItem extends StatelessWidget {
  const ListItem({required this.text, required this.color, required this.callback, required this.index});
  final String text;
  final Color color;
  final Function callback;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: SizedBox(
          width: 200,
          height: 75,
          child: Card(
            color: color,
            child: Center(
              child: ListTile(
                  title: Text(
                    text,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  trailing: SizedBox(
                    width: 70,
                    child: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        callback(index);
                      },
                    )
                  )),
            ),
          )),
    );
  }
}
