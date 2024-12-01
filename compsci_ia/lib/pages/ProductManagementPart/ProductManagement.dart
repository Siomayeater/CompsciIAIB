import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'product_detail.dart'; // Import the ProductDetail page
import 'products_pinned.dart'; // Import the ProductsPinned page
import 'add_product.dart'; // Import AddProduct page

class ProductManagement extends StatefulWidget {
  final String companyID; // Expect companyID as a parameter

  const ProductManagement({super.key, required this.companyID});

  @override
  _ProductManagementState createState() => _ProductManagementState();
}

class _ProductManagementState extends State<ProductManagement> {
  List<DocumentSnapshot> products = []; // Store the list of products
  String searchQuery = ''; // For filtering products based on search query

  @override
  void initState() {
    super.initState();
    fetchProducts(); // Fetch products after the widget is initialized
  }

  // Method to fetch products based on companyID
  void fetchProducts() async {
    try {
      final QuerySnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.companyID) // Use companyID to fetch products from the correct company
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

  // Method to log audit trail for actions (view, pin, delete)
  void logAuditTrail(String action, String productID, String productName, String companyID) async {
    try {
      await FirebaseFirestore.instance.collection('auditTrail').add({
        'action': action,
        'productID': productID,
        'productName': productName,
        'timestamp': FieldValue.serverTimestamp(),
        'user': 'userID', // Replace with the actual user ID
        'companyID': companyID,
      });
    } catch (e) {
      print('Error logging audit trail: $e');
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
            // Loading indicator while fetching products
            products.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        final productData = product.data() as Map<String, dynamic>;
                        final productID = product.id;
                        final productName = productData['productName'];
                        final productDesc = productData['productDesc'];
                        final productPrice = productData['productPrice'] ?? 0.0;
                        final productPriceSupplier = productData['productPriceSupplier'] ?? 0.0;
                        final supplierID = productData['supplierID'] ?? '';

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(productName),
                            subtitle: Text(productDesc),
                            onTap: () {
                              // Log viewing of product in audit trail
                              logAuditTrail('view', productID, productName, widget.companyID);

                              // Navigate to ProductDetail page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetail(
                                    productID: productID,
                                    productName: productName,
                                    productDesc: productDesc,
                                    productPrice: productPrice,
                                    productPriceSupplier: productPriceSupplier,
                                    supplierID: supplierID,
                                  ),
                                ),
                              );
                            },
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.push_pin),
                                  onPressed: () {
                                    // Log pinning of product in audit trail
                                    logAuditTrail('pin', productID, productName, widget.companyID);

                                    // Pin the product and navigate to ProductsPinned page
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductsPinned(
                                          productID: productID,
                                          productName: productName,
                                          productDesc: productDesc,
                                          productPrice: productPrice,
                                          productPriceSupplier: productPriceSupplier,
                                          supplierID: supplierID,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    // Log deleting of product in audit trail
                                    logAuditTrail('delete', productID, productName, widget.companyID);

                                    // Delete product
                                    deleteProduct(productID);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 16.0),
            // Add Product Button
            ElevatedButton(
              onPressed: () {
                // Navigate to Add Product Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddProduct(companyID: widget.companyID),
                  ),
                );
              },
              child: const Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }

  // Method to delete a product
  Future<void> deleteProduct(String productID) async {
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(widget.companyID) // Use companyID for the correct company
        .collection('products')
        .doc(productID)
        .delete();
    fetchProducts(); // Re-fetch products after deletion
  }
}
