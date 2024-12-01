import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductManagement extends StatefulWidget {
  final String companyID;  // Add companyID as a required parameter

  // Update constructor to accept companyID
  const ProductManagement({super.key, required this.companyID});

  @override
  _ProductManagementState createState() => _ProductManagementState();
}

class _ProductManagementState extends State<ProductManagement> {
  List<DocumentSnapshot> products = [];  // Stores the list of products
  String searchQuery = '';  // For filtering products based on search query

  // Form controllers for adding a product
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productDescController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _productPriceSupplierController = TextEditingController();
  final TextEditingController _supplierIDController = TextEditingController();

  // Method to fetch products from Firestore
  void fetchProducts() async {
    final QuerySnapshot productSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .get();

    setState(() {
      products = productSnapshot.docs;
    });
  }

  // Method to display product info
  String getProductInfo(DocumentSnapshot product) {
    final productData = product.data() as Map<String, dynamic>;

    return 'Product Name: ${productData['productName']}\n'
        'Description: ${productData['productDesc']}\n'
        'Price: \$${productData['productPrice']}\n'
        'Supplier Price: \$${productData['productPriceSupplier']}\n'
        'Supplier ID: ${productData['supplierID']}';
  }

  // Method to add a new product
  Future<void> addProduct() async {
    final productName = _productNameController.text;
    final productDesc = _productDescController.text;
    final productPrice = double.tryParse(_productPriceController.text) ?? 0.0;
    final productPriceSupplier = double.tryParse(_productPriceSupplierController.text) ?? 0.0;
    final supplierID = _supplierIDController.text;

    if (productName.isNotEmpty && productDesc.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('products').add({
          'productName': productName,
          'productDesc': productDesc,
          'productPrice': productPrice,
          'productPriceSupplier': productPriceSupplier,
          'supplierID': supplierID,
          'companyID': widget.companyID,  // Add companyID to associate with the product
        });
        fetchProducts();  // Re-fetch the products after adding
        Navigator.pop(context);  // Close the dialog
      } catch (e) {
        print('Error adding product: $e');
      }
    } else {
      // Show an error if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();  // Fetch products when the page loads
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
            // List of Products
            Expanded(
              child: ListView.builder(
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  final productData = product.data() as Map<String, dynamic>;
                  final productID = product.id;
                  final productName = productData['productName'];
                  final productDesc = productData['productDesc'];
                  final productPrice = productData['productPrice'];
                  final productPriceSupplier = productData['productPriceSupplier'];
                  final supplierID = productData['supplierID'];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(productName),
                      subtitle: Text(productDesc),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          // Call a function to delete the product
                          deleteProduct(productID);
                        },
                      ),
                      onTap: () {
                        // Show product info in a dialog when tapped
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(productName),
                              content: Text(getProductInfo(product)),  // Show product details
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Close'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            // Add Product Button
            ElevatedButton(
              onPressed: () {
                // Show a dialog to add a new product
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Add New Product'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _productNameController,
                            decoration: const InputDecoration(labelText: 'Product Name'),
                          ),
                          TextField(
                            controller: _productDescController,
                            decoration: const InputDecoration(labelText: 'Product Description'),
                          ),
                          TextField(
                            controller: _productPriceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Product Price'),
                          ),
                          TextField(
                            controller: _productPriceSupplierController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Supplier Price'),
                          ),
                          TextField(
                            controller: _supplierIDController,
                            decoration: const InputDecoration(labelText: 'Supplier ID'),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);  // Close the dialog
                          },
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: addProduct,
                          child: const Text('Add Product'),
                        ),
                      ],
                    );
                  },
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
        .collection('products')
        .doc(productID)
        .delete();
    fetchProducts();  // Re-fetch the products after deletion
  }
}
