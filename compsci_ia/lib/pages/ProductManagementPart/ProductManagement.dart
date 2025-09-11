import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'product_detail.dart'; 
import 'products_pinned.dart'; 
import 'add_product.dart'; 

class ProductManagement extends StatefulWidget {
  final String companyID; 

  const ProductManagement({super.key, required this.companyID});

  @override
  _ProductManagementState createState() => _ProductManagementState();
}

class _ProductManagementState extends State<ProductManagement> {
  List<DocumentSnapshot> products = []; 
  String searchQuery = ''; 

  @override
  void initState() {
    super.initState();
    fetchProducts(); 
  }

  void fetchProducts() async {
    try {
      final QuerySnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.companyID)
          .collection('products')
          .get();

      setState(() {
        products = productSnapshot.docs;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching products: $e')),
      );
    }
  }

  void deleteProduct(String productID) async {
    try {
      await FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.companyID)
          .collection('products')
          .doc(productID)
          .delete();

      fetchProducts();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting product: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = products.where((product) {
      final productData = product.data() as Map<String, dynamic>;
      return productData['productName']
          .toString()
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddProduct(companyID: widget.companyID),
                ),
              );
              if (result == true) {
                fetchProducts();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                final productData = product.data() as Map<String, dynamic>;
                final productID = product.id;
                final productName = productData['productName'];

                return Column(
                  children: [
                    ListTile(
                      title: Text(productName),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                              builder: (context) => ProductDetail(
                                companyID: widget.companyID,
                                productID: productID,
                              ),
                                ),
                              );
                              if (result == true) {
                                fetchProducts();
                              }
                            },
                            child: const Text('Details', style: TextStyle(color: Colors.blue)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Product'),
                                  content: const Text('Are you sure you want to delete this product?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        deleteProduct(productID);
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
