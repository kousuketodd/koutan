import 'package:flutter/material.dart';
import 'items.dart';


class InventoryStorage extends StatefulWidget {
  final Function callback;
  InventoryStorage({Key? key, required this.callback});

  @override
  State<InventoryStorage> createState() => _InventoryStorageState();
}

class _InventoryStorageState extends State<InventoryStorage> {
  List <Item> items = [];
  @override
  void initState() {
    super.initState();
    items = [Item(callback: widget.callback,)];

  }
  @override
  Widget build(BuildContext context) {
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
              children: items,
            )
            ],
          ),
        ),
      );
    }
}