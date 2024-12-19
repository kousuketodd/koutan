import 'package:flutter/material.dart';
import "add_sub_popup.dart";

class Item extends StatelessWidget {
  final Function callback;
  final String name;
  final int price;
  final String category;
  final String url;
  const Item(
      {Key? key,
      required this.callback,
      required this.name,
      required this.price,
      required this.category,
      required this.url});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 200,
        height: 200,
        child: GestureDetector(
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AddSubPopup(
                    itemName: name,
                    callback: callback,
                    category: category,
                  );
                });
          },
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // USE SIZEDBOX FOR SPACING
              children: [
                Image.network(url),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Text(name),
                  SizedBox(width: 10),
                  Text("$price円")
                ],)
              ]),
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
