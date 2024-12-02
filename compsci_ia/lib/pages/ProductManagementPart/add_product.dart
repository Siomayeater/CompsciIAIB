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
  final TextEditingController _supplierIDController = TextEditingController();

  List<String> supplierIds = [];
  List<String> supplierNames = [];
  String? selectedSupplierID;
  bool isLoading = false;
  String? selectedSupplierName;

  @override
  void initState() {
    super.initState();
    _fetchSupplierIds();
  }

  // Fetch supplier IDs from Firestore
  Future<void> _fetchSupplierIds() async {
    setState(() {
      isLoading = true;
    });
    try {
      final snapshot = await FirebaseFirestore.instance.collection('suppliers').get();
      final supplierList = snapshot.docs.map((doc) => doc.id).toList();
      final supplierNamesList = await _fetchSupplierNames(supplierList);  // Fetch supplier names
      setState(() {
        supplierIds = supplierList;
        supplierNames = supplierNamesList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching suppliers: $e');
    }
  }

  // Fetch supplier names based on the supplier IDs
  Future<List<String>> _fetchSupplierNames(List<String> supplierIds) async {
    List<String> names = [];
    for (String supplierID in supplierIds) {
      try {
        final supplierDoc = await FirebaseFirestore.instance
            .collection('suppliers')
            .doc(supplierID)
            .get();
        if (supplierDoc.exists) {
          names.add(supplierDoc['supplierName'] ?? 'Unknown Supplier');  // Replace with the correct field name
        } else {
          names.add('Unknown Supplier');
        }
      } catch (e) {
        print('Error fetching supplier name: $e');
        names.add('Unknown Supplier');
      }
    }
    return names;
  }

  // Method to add a product to Firestore
  void addProduct() async {
    final productName = _nameController.text;
    final productDesc = _descController.text;
    final productPrice = double.tryParse(_priceController.text) ?? 0.0;
    final productPriceSupplier = double.tryParse(_priceSupplierController.text) ?? 0.0;
    final supplierID = selectedSupplierID ?? _supplierIDController.text;

    if (productName.isNotEmpty && productDesc.isNotEmpty && supplierID.isNotEmpty) {
      try {
        final productRef = await FirebaseFirestore.instance
            .collection('companies')
            .doc(widget.companyID)
            .collection('products')
            .add({
          'productName': productName,
          'productDesc': productDesc,
          'productPrice': productPrice,
          'productPriceSupplier': productPriceSupplier,
          'supplierID': supplierID,
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
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
            // Dropdown for Supplier Name (displaying the supplier name in the dropdown)
            isLoading
                ? const CircularProgressIndicator()  // Show loading until suppliers are fetched
                : supplierIds.isEmpty
                    ? const Text('No suppliers available')  // Handle case with no suppliers
                    : DropdownButton<String>(
                        value: selectedSupplierID,
                        hint: const Text('Select Supplier'),
                        onChanged: (newValue) {
                          setState(() {
                            selectedSupplierID = newValue;
                            selectedSupplierName = supplierNames[supplierIds.indexOf(newValue!)]; // Set the selected supplier name
                          });
                        },
                        items: supplierIds.map((supplierID) {
                          final supplierName = supplierNames[supplierIds.indexOf(supplierID)];
                          return DropdownMenuItem<String>(
                            value: supplierID,
                            child: Text(supplierName),
                          );
                        }).toList(),
                      ),
            // Display the selected supplier's name
            if (selectedSupplierName != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Selected Supplier: $selectedSupplierName',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 16.0),
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
              onPressed: isLoading ? null : addProduct,  // Disable button while loading
              child: const Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
