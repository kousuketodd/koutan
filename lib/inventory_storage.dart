// lib/inventory_storage.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:koutan/add_sub_popup.dart';

class InventoryStorage extends StatelessWidget {
  final String folderId;
  final Function callback;
  const InventoryStorage({
    super.key,
    required this.folderId,
    required this.callback,
  });

  @override
  Widget build(BuildContext context) {
    final docRef = FirebaseFirestore.instance.collection('Categories').doc(folderId);

    return StreamBuilder<DocumentSnapshot>(
      stream: docRef.snapshots(),
      builder: (ctx, snap) {
        if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
        if (!snap.hasData || !snap.data!.exists) {
          return Center(child: Text('No data for this category.'));
        }

        final data = snap.data!.data() as Map<String, dynamic>;
        final itemsMap = Map<String, dynamic>.from(data['items'] ?? {});

        if (itemsMap.isEmpty) {
          return Center(child: Text('No items in this category.'));
        }

        final itemEntries = itemsMap.entries.toList();

        return Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            itemCount: itemEntries.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 3/4,
            ),
            itemBuilder: (ctx, i) {
              final itemId = itemEntries[i].key;
              final item   = itemEntries[i].value as Map<String, dynamic>;
              final name   = item['name']  as String? ?? '';
              final price  = item['price'] as int?    ?? 0;
              final url    = item['url']   as String? ?? '';

              return Card(
                elevation: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: url.isNotEmpty
                        ? Image.network(url, fit: BoxFit.cover)
                        : Container(color: Colors.grey[200]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('¥$price'),
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.orange),
                          onPressed: () {
                            // wire up edit callback (e.g. showDialog with item form)
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AddSubPopup(
                                  itemName: name,
                                  callback: callback,
                                  category: folderId,
                                );
                              });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
