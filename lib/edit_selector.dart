import 'package:flutter/material.dart';

class EditSelect extends StatefulWidget {
  const EditSelect({super.key});

  @override
  State<EditSelect> createState() => _EditSelectState();
}

class _EditSelectState extends State<EditSelect> {
  List options = <String>["Inventory", "Edit", "Export"];
  String option = "Inventory";
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 70,
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(
        top: 30,
        left: 30
        ),
      child: Card(
        color: Colors.grey,
        child: Center(
          child: MenuAnchor(
            builder:(context, controller, child) {
              return TextButton(
                style: TextButton.styleFrom(
                  minimumSize: Size(120, 40),
                  maximumSize: Size(120, 40)
                ),
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                }, 
                child: Text(option)
                );
            },
            menuChildren: List<MenuItemButton>.generate(
              3,
              (int index) => MenuItemButton(
                onPressed: () =>
                setState(() => option = options[index]),
                child: Text(options[index])
              ))
          ),
        ),
      ),
    );
  }
}