import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddProduct extends StatefulWidget {
  final String companyID;

  const AddProduct({super.key, required this.companyID});

  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _priceSupplierController = TextEditingController();

  // Method to add a product to Firestore
  void addProduct() async {
    final productName = _nameController.text;
    final productDesc = _descController.text;
    final productPrice = double.tryParse(_priceController.text) ?? 0.0;
    final productPriceSupplier = double.tryParse(_priceSupplierController.text) ?? 0.0;

    if (productName.isNotEmpty && productDesc.isNotEmpty) {
      try {
        // Add product to Firestore
        final productRef = await FirebaseFirestore.instance
            .collection('companies')
            .doc(widget.companyID)
            .collection('products')
            .add({
          'productName': productName,
          'productDesc': productDesc,
          'productPrice': productPrice,
          'productPriceSupplier': productPriceSupplier,
          'supplierID': 'some_supplier_id', // Adjust supplier logic if needed
        });

        // Log the action to the audit trail after product is successfully added
        await FirebaseFirestore.instance.collection('auditTrail').add({
          'action': 'add',
          'productID': productRef.id,
          'productName': productName,
          'timestamp': FieldValue.serverTimestamp(),
          'user': 'userID', // Replace with actual user ID from Firebase Auth
          'companyID': widget.companyID,
        });

        // Navigate back to the previous page after adding the product
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding product: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Product Description'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Product Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _priceSupplierController,
              decoration: const InputDecoration(labelText: 'Supplier Price'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: addProduct,
              child: const Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
