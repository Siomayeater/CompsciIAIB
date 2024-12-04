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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddProduct(companyID: widget.companyID),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
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
                      trailing: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetail(
                                productID: productID,
                                productName: productName,
                                productDesc: productData['productDesc'] ?? '',
                                productPrice: productData['productPrice'] ?? 0.0,
                                productPriceSupplier: productData['productPriceSupplier'] ?? 0.0,
                                supplierID: productData['supplierID'] ?? '',
                              ),
                            ),
                          );
                        },
                        child: const Text('Edit', style: TextStyle(color: Colors.blue)),
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
