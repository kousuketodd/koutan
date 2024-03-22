import 'package:flutter/material.dart';
import 'admin_page.dart';

class EditSelect extends StatelessWidget {
  EditSelect({super.key});

  List options = <String>["Inventory", "Edit", "Export"];

  String option = "Inventory";

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 70,
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(top: 30, left: 30),
      child: Card(
        color: Colors.grey,
        child: Center(
          child: MenuAnchor(
              builder: (context, controller, child) {
                return TextButton(
                    style: TextButton.styleFrom(
                        minimumSize: Size(120, 40), maximumSize: Size(120, 40)),
                    onPressed: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                    child: Text(option));
              },
              menuChildren: List<MenuItemButton>.generate(
                  3,
                  (int index) => MenuItemButton(
                      onPressed: () {
                        if (options[index] == "Inventory") {
                          Navigator.pop(context);
                        }
                        else if (options[index] == "Edit") {
                          Navigator.push(context,
                          MaterialPageRoute(builder: (context) => AdminPage()));
                        }
                      },
                      child: Text(options[index])))),
        ),
      ),
    );
  }
}
