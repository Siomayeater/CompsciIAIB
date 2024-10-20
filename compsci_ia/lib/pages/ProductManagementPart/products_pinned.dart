import 'package:flutter/material.dart';

class ProductsPinned extends StatefulWidget {
  const ProductsPinned({super.key, required this.pinnedItems});

  final List<String> pinnedItems;

  @override
  _ProductsPinnedState createState() => _ProductsPinnedState();
}

class _ProductsPinnedState extends State<ProductsPinned> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products Pinned'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.pinnedItems.isEmpty
            ? const Center(
                child: Text('No pinned products yet!'),
              )
            : ListView.builder(
                itemCount: widget.pinnedItems.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(widget.pinnedItems[index]),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
