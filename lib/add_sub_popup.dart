import 'package:flutter/material.dart';

class AddSubPopup extends StatefulWidget {
  final String itemName;
  final Function callback;
  const AddSubPopup({Key? key, required this.itemName, required this.callback}) : super (key: key);

  @override
  State<AddSubPopup> createState() => _AddSubPopupState();
}

class _AddSubPopupState extends State<AddSubPopup> {
  int count = 0;
  void _incrementCounter(int num) {
    setState(() {
      count += num;
    });
  }

  void _decrementCounter(int num) {
    setState(() {
      count -= num;
    });
  }

  InputBox box = InputBox();

  @override
  Widget build(BuildContext context) {
    if (count > 999) {
      count = 999;
    } else if (count < -999) {
      count = -999;
    }
    return AlertDialog(
      backgroundColor: Colors.grey,
      content: SizedBox(
          width: 400,
          height: 350,
          child: Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.itemName,
                      style: TextStyle(fontSize: 40),
                    ),
                    ItemCounter(count: count),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ItemDecrement(
                          onPressed: () => _decrementCounter(box.itemvalue),
                        ),
                        SizedBox(width: 50),
                        box,
                        SizedBox(width: 50),
                        ItemIncrement(
                          onPressed: () => _incrementCounter(box.itemvalue),
                        )
                      ],
                    ),
                    ItemEnterButton(callback: widget.callback, count: count, name: widget.itemName)
                  ],
                ),
              ))),
    );
  }
}

class ItemDecrement extends StatelessWidget {
  final VoidCallback onPressed;
  ItemDecrement({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.large(
        shape: CircleBorder(),
        foregroundColor: const Color.fromARGB(255, 255, 129, 129),
        backgroundColor: Colors.red,
        onPressed: () => onPressed(),
        child: Icon(Icons.remove, color: Colors.white));
  }
}

class ItemIncrement extends StatelessWidget {
  final VoidCallback onPressed;
  ItemIncrement({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.large(
        shape: CircleBorder(),
        foregroundColor: const Color.fromARGB(255, 160, 255, 209),
        backgroundColor: Colors.green,
        onPressed: () => onPressed(),
        child: Icon(Icons.add, color: Colors.white));
  }
}

class InputBox extends StatelessWidget {
  int itemvalue = 1;
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 50,
        height: 50,
        color: const Color.fromARGB(255, 194, 194, 194),
        child: TextField(
          onSubmitted: (value) {
            try {
              itemvalue = int.parse(value).abs();
            } catch (e) {
              itemvalue = 1;
            }
          },
          decoration:
              InputDecoration(border: OutlineInputBorder(), labelText: '入力'),
        ));
  }
}

class ItemCounter extends StatelessWidget {
  final int count;

  ItemCounter({Key? key, required this.count}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 100,
        height: 100,
        child: FittedBox(
          child: Text(
            count.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 70),
          ),
        ));
  }
}

class ItemEnterButton extends StatelessWidget {
  final Function callback;
  final int count;
  final String name;
  const ItemEnterButton({Key? key, required this.callback, required this.count, required this.name});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
        onPressed: () {
          // closes the popup
          callback(name, count);
          Navigator.of(context).pop();
        },
        label: Text("Enter"),
        backgroundColor: Colors.blue);
  }
}
