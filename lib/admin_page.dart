// lib/admin_page.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AdminPage extends StatelessWidget {
  static final _categories = FirebaseFirestore.instance.collection('Categories');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Categories')),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.add),
        label: Text('Add Category'),
        onPressed: () => showDialog(
          context: context,
          builder: (_) => _CategoryDialog(
            onSubmit: (name) => _categories.add({'name': name, 'items': {}}),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _categories.snapshots(),
        builder: (ctx, snap) {
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          if (!snap.hasData)  return Center(child: CircularProgressIndicator());

          final docs = snap.data!.docs;
          if (docs.isEmpty) return Center(child: Text('No categories yet.'));

          return ListView(
            padding: const EdgeInsets.all(12),
            children: docs.map((doc) {
              final data = doc.data()! as Map<String, dynamic>;
              final catId   = doc.id;
              final catName = data['name'] as String? ?? '';
              final items   = Map<String, dynamic>.from(data['items'] ?? {});

              return _CategoryTile(
                categoryId: catId,
                categoryName: catName,
                items: items,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

/// --- CATEGORY TILE (EXPANSION) ---
class _CategoryTile extends StatelessWidget {
  final String categoryId;
  final String categoryName;
  final Map<String, dynamic> items;
  static final _categories = AdminPage._categories;

  const _CategoryTile({
    required this.categoryId,
    required this.categoryName,
    required this.items,
  });

  Future<void> _deleteCategory(BuildContext ctx) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text('Delete Category'),
        content: Text('Are you sure you want to delete “$categoryName”?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),  child: Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) await _categories.doc(categoryId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ExpansionTile(
        title: Text(categoryName, style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.orange),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => _CategoryDialog(
                  initialName: categoryName,
                  onSubmit: (newName) => _categories.doc(categoryId).update({'name': newName}),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteCategory(context),
            ),
          ],
        ),
        children: [
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('No items yet.', style: TextStyle(fontStyle: FontStyle.italic)),
            ),
          ...items.entries.map((e) {
            final itemId   = e.key;
            final data     = e.value as Map<String, dynamic>;
            return _ItemTile(
              categoryId: categoryId,
              itemId: itemId,
              data: data,
            );
          }),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: Icon(Icons.add),
              label: Text('Add Item'),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => _ItemDialog(
                  onSubmit: (name, price, imageFile, downloadUrl, storagePath) async {
                    await _categories.doc(categoryId).update({
                      'items.${DateTime.now().millisecondsSinceEpoch}': {
                        'name': name,
                        'price': price,
                        'url': downloadUrl,
                        'path': storagePath,
                      }
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// --- ITEM TILE ---
class _ItemTile extends StatelessWidget {
  final String categoryId;
  final String itemId;
  final Map<String, dynamic> data;
  static final _categories = AdminPage._categories;

  const _ItemTile({
    required this.categoryId,
    required this.itemId,
    required this.data,
  });

  Future<void> _deleteItem() async {
    await _categories.doc(categoryId).update({
      'items.$itemId': FieldValue.delete(),
    });
    // Optionally delete from storage:
    if (data['path'] != null && (data['path'] as String).isNotEmpty) {
      await FirebaseStorage.instance.ref(data['path']).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final name  = data['name']  as String? ?? '';
    final price = data['price'] as int?    ?? 0;
    final url   = data['url']   as String? ?? '';
    final path  = data['path']  as String? ?? '';

    return ListTile(
      leading: url.isNotEmpty
          ? Image.network(url, width: 56, height: 56, fit: BoxFit.cover)
          : SizedBox(width: 56, height: 56),
      title: Text(name),
      subtitle: Text('¥$price'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.orange),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => _ItemDialog(
                initialName: name,
                initialPrice: price,
                initialUrl: url,
                initialPath: path,
                onSubmit: (newName, newPrice, newFile, newUrl, newPath) async {
                  // if a newFile was chosen, delete old and upload new
                  String finalUrl = newUrl;
                  String finalPath = newPath;
                  if (newFile != null) {
                    // delete old
                    if (path.isNotEmpty) await FirebaseStorage.instance.ref(path).delete();
                    // upload new
                    final unique = DateTime.now().millisecondsSinceEpoch.toString();
                    final ref = FirebaseStorage.instance.ref('images/$unique');
                    await ref.putFile(File(newFile.path));
                    finalUrl = await ref.getDownloadURL();
                    finalPath = 'images/$unique';
                  }
                  await _categories.doc(categoryId).update({
                    'items.$itemId': {
                      'name': newName,
                      'price': newPrice,
                      'url': finalUrl,
                      'path': finalPath,
                    }
                  });
                },
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteItem,
          ),
        ],
      ),
    );
  }
}

/// --- CATEGORY ADD/EDIT DIALOG ---
class _CategoryDialog extends StatefulWidget {
  final String? initialName;
  final Future<void> Function(String name) onSubmit;
  const _CategoryDialog({this.initialName, required this.onSubmit});

  @override
  __CategoryDialogState createState() => __CategoryDialogState();
}

class __CategoryDialogState extends State<_CategoryDialog> {
  late TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName ?? '');
  }

  void _submit() {
    final txt = _controller.text.trim();
    if (txt.isEmpty) {
      setState(() => _error = 'Please enter a name.');
      return;
    }
    widget.onSubmit(txt).then((_) => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialName == null ? 'New Category' : 'Edit Category'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_error != null) Text(_error!, style: TextStyle(color: Colors.red)),
          TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: 'Name'),
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
        ElevatedButton(onPressed: _submit, child: Text('Submit')),
      ],
    );
  }
}

/// --- ITEM ADD/EDIT DIALOG ---
class _ItemDialog extends StatefulWidget {
  final String? initialName;
  final int?    initialPrice;
  final String? initialUrl;
  final String? initialPath;
  final Future<void> Function(
    String name,
    int price,
    XFile? imageFile,
    String url,
    String path,
  ) onSubmit;

  const _ItemDialog({
    this.initialName,
    this.initialPrice,
    this.initialUrl,
    this.initialPath,
    required this.onSubmit,
  });

  @override
  __ItemDialogState createState() => __ItemDialogState();
}

class __ItemDialogState extends State<_ItemDialog> {
  final _picker = ImagePicker();
  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  XFile? _picked;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameCtrl  = TextEditingController(text: widget.initialName ?? '');
    _priceCtrl = TextEditingController(text: widget.initialPrice?.toString() ?? '');
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    setState(() => _picked = file);
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    final price = int.tryParse(_priceCtrl.text.trim());
    if (name.isEmpty || price == null || (widget.initialUrl == null && _picked == null)) {
      setState(() => _error = 'Enter name, valid price, and select an image.');
      return;
    }
    widget.onSubmit(
      name,
      price,
      _picked,
      widget.initialUrl ?? '',
      widget.initialPath ?? '',
    ).then((_) => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    final hasPreview = _picked != null || (widget.initialUrl?.isNotEmpty ?? false);
    final previewUrl = _picked?.path ?? widget.initialUrl;

    return AlertDialog(
      title: Text(widget.initialName == null ? 'Add Item' : 'Edit Item'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            if (_error != null) Text(_error!, style: TextStyle(color: Colors.red)),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _priceCtrl,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            if (hasPreview)
              Image(
                image: _picked != null
                    ? FileImage(File(previewUrl!))
                    : NetworkImage(previewUrl!) as ImageProvider,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            TextButton.icon(
              icon: Icon(Icons.image),
              label: Text(hasPreview ? 'Change Image' : 'Pick Image'),
              onPressed: _pickImage,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
        ElevatedButton(onPressed: _submit, child: Text('Submit')),
      ],
    );
  }
}
