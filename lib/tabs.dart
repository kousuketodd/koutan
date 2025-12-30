// lib/tabs.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'inventory_storage.dart';

class Tabs extends StatelessWidget {
  final Function callback;
  const Tabs({super.key, required this.callback});

  @override
  Widget build(BuildContext context) {
    final categories = FirebaseFirestore.instance.collection('Categories');

    return StreamBuilder<QuerySnapshot>(
      stream: categories.snapshots(),
      builder: (ctx, snap) {
        if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
        if (!snap.hasData)  return Center(child: CircularProgressIndicator());

        final docs = snap.data!.docs;
        if (docs.isEmpty) return Center(child: Text('No categories found.'));

        // Build tabs and pages
        final tabs  = docs.map((d) => Tab(text: (d.data()! as Map)['name'] as String? ?? d.id)).toList();
        final pages = docs.map((d) => InventoryStorage(
          folderId: d.id,
          callback: callback,
        )).toList();

        return DefaultTabController(
          length: tabs.length,
          child: Column(
            children: [
              SizedBox(
                width: 900,
                child: TabBar(
                  isScrollable: true,
                  tabs: tabs,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  indicator: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  width: 900,
                  child: TabBarView(children: pages),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
