import 'package:flutter/material.dart';
import 'product_detail.dart';
import 'products_pinned.dart';

class ProductManagement extends StatefulWidget {
  const ProductManagement({super.key});

  @override
  _ProductManagementState createState() => _ProductManagementState();
}

class _ProductManagementState extends State<ProductManagement> {
  List<String> items = [
    'Product 1',
    'Product 2',
    'Product 3',
    'Product 4',
    'Product 5',
  ];

  List<String> pinnedItems = [];

  String searchQuery = '';

  void addItem() {
    showDialog(
      context: context,
      builder: (context) {
        String newItem = '';
        return AlertDialog(
          title: const Text('Add New Product'),
          content: TextField(
            onChanged: (value) {
              newItem = value;
            },
            decoration: const InputDecoration(hintText: 'Enter product name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (newItem.isNotEmpty) {
                  setState(() {
                    items.add(newItem);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void pinItem(String item) {
    setState(() {
      if (!pinnedItems.contains(item)) {
        pinnedItems.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = items.where((item) => item.toLowerCase().contains(searchQuery.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.push_pin),
            onPressed: () {
              // Navigate to Products Pinned page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductsPinned(pinnedItems: pinnedItems),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Search Products',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16.0),
            // List of Items
            Expanded(
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(filteredItems[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.push_pin_outlined),
                        onPressed: () {
                          pinItem(filteredItems[index]);
                        },
                      ),
                      onTap: () {
                        // Navigate to the Product Detail page when the product is tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetail(
                              productName: filteredItems[index],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            // Add Item Button
            ElevatedButton(
              onPressed: addItem,
              child: const Text('Add New Product'),
            ),
          ],
        ),
      ),
    );
  }
}
