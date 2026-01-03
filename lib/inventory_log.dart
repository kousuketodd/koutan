import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:koutan/myapp.dart';

// void submit(List<Inv> items, String date) async {
//   var docRef = FirebaseFirestore.instance.collection("Logs").doc(date);
//   var docSnapshot = await docRef.get();
//   if (!docSnapshot.exists) {
//     await docRef.set({"dummy": {"name": 5}});
//     docSnapshot = await docRef.get();
//   }
//   Map<String, dynamic> categories = docSnapshot.data()!;
//   for (Inv item in items) {
//     num count = item.count;
//     if (item.type == "Expended") {
//       count = -count;
//     }
//     // create a copy of items
//     /*
//     Food
//       Gyoza : 50
//       Ramen : 25
//     */
//     Map<String, dynamic> items = categories[item.category] ?? {};

//     items[item.name] = (items[item.name] ?? 0) + count;

//     categories[item.category] = items;
//   }
//   await docRef.update(categories);
// }

class Log extends StatefulWidget {
  Log({required this.inventoryLog, required this.callback});
  final List<Inv> inventoryLog;
  final Function callback;

  @override
  State<Log> createState() => _LogState();
}

class _LogState extends State<Log> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("📒 履歴",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: ListView.builder(
              itemCount: widget.inventoryLog.length,
              itemBuilder: (_, index) {
                final entry = widget.inventoryLog[index];
                return ListTile(
                    title: Text(entry.name), trailing: Text("×${entry.count}"));
              },
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                await _submitLogsToFirestore(context, widget.inventoryLog);
                setState(() {
                  widget.inventoryLog.clear();
                });
              },
              child: const Text("Enter"),
            ),
          )
        ],
      ),
    );
  }
}

Future<void> _submitLogsToFirestore(
    BuildContext context, List<Inv> items) async {
  if (items.isEmpty) return;

  String selectedTimeFrame = await _promptForTimeFrame(context);
  final logDoc =
      FirebaseFirestore.instance.collection('Logs').doc(selectedTimeFrame);
  final snapshot = await logDoc.get();

  List<dynamic> existingEntries = [];

  if (snapshot.exists) {
    existingEntries = snapshot.data()?['entries'] ?? [];
  }

  for (final e in items) {
    final index = existingEntries.indexWhere((entry) =>
        entry['itemName'] == e.name && entry['category'] == e.category);

    if (index != -1) {
      // Update existing entry by incrementing the quantity
      existingEntries[index]['quantity'] += e.count;
    } else {
      // Add new entry
      existingEntries.add({
        'itemName': e.name,
        'quantity': e.count,
        'category': e.category,
      });
    }
  }

  await logDoc.set({'entries': existingEntries});
}

Future<String> _promptForTimeFrame(BuildContext context) async {
  String? inputFrame;
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('期限を入力してください'),
      content: TextField(
        decoration: const InputDecoration(hintText: 'e.g. 2025-06'),
        onChanged: (value) => inputFrame = value,
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('やめる')),
        ElevatedButton(
            onPressed: () {
              if (inputFrame?.trim().isNotEmpty ?? false) {
                Navigator.pop(context);
              }
            },
            child: const Text('EnteEnter'))
      ],
    ),
  );

  return inputFrame ??
      '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
}
