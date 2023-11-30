import 'package:flutter/material.dart';
import "add_sub_popup.dart";

class Item extends StatefulWidget {
  final Function callback;
  const Item({Key? key, required this.callback});

  @override
  State<Item> createState() => _ItemState();
}

class _ItemState extends State<Item> {
  String name = "Gyoza";
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 120,
        height: 170,
        child: GestureDetector(
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AddSubPopup(itemName: name, callback: widget.callback,);
                });
          },
          child: Card(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // USE SIZEDBOX FOR SPACING
                children: [
                  Text(name),
                  SizedBox(height: 10),
                  Image(
                    image: AssetImage('assets/gyoza.jpg'),
                  ),
                  SizedBox(height: 10),
                  Text("Price: 50")
                ]),
          ),
        ));
  }
}

// class AddItemButton extends StatelessWidget {
//   final VoidCallback onPressed;
//   AddItemButton({required this.onPressed});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 120,
//       height: 170,
//       child: GestureDetector(
//         onTap: () => onPressed(),
//         child: Card(
//           child: Icon(Icons.add)
//         )
//       )
//     );
//   }
// }
