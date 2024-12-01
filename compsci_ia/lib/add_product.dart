import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'dart:developer' as developer;

class AddProductView extends StatefulWidget {
  const AddProductView({super.key});

  @override
  State<AddProductView> createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  late final TextEditingController _ProductID;
  late final TextEditingController _ProductName;
  late final TextEditingController _ProductDesc;
  late final TextEditingController _ProductPrice;
  late final TextEditingController _ProductCostSupplier;
  late final TextEditingController _SupplierID;

  @override
  void initState() {
    _ProductID = TextEditingController();
    _ProductName = TextEditingController();
    _ProductDesc = TextEditingController();
    _ProductPrice = TextEditingController();
    _ProductCostSupplier = TextEditingController();
    _SupplierID = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _ProductID.dispose();
    _ProductName.dispose();
    _ProductDesc.dispose();
    _ProductPrice.dispose();
    _ProductCostSupplier.dispose();
    _SupplierID.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register Product"),
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField(_ProductID, "Product ID", TextInputType.number),
                  _buildTextField(_ProductName, "Product Name", TextInputType.text),
                  _buildTextField(_ProductDesc, "Product Description", TextInputType.text),
                  _buildTextField(_ProductPrice, "Product Price", TextInputType.number),
                  _buildTextField(_ProductCostSupplier, "Product Cost Supplier", TextInputType.number),
                  _buildTextField(_SupplierID, "Supplier ID", TextInputType.number),
                  TextButton(
                    onPressed: _registerProduct,
                    child: const Text("Register"),
                  ),
                ],
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  TextField _buildTextField(TextEditingController controller, String hintText, TextInputType keyboardType) {
    return TextField(
      controller: controller,
      enableSuggestions: false,
      autocorrect: false,
      keyboardType: keyboardType,
      decoration: InputDecoration(hintText: hintText),
    );
  }

  Future<void> _registerProduct() async {
    developer.log('Register Button Clicked');
    
    // Get product data from the controllers
    final String ProductID = _ProductID.text;
    final String ProductName = _ProductName.text;
    final String ProductDesc = _ProductDesc.text;
    final String ProductPrice = _ProductPrice.text;
    final String ProductCostSupplier = _ProductCostSupplier.text;
    final String SupplierID = _SupplierID.text;

    // Firestore instance
    final db = FirebaseFirestore.instance;

    // Prepare product data to be saved
    final data = {
      'ProductID': ProductID,
      'ProductName': ProductName,
      'ProductDesc': ProductDesc,
      'ProductPrice': ProductPrice,
      'ProductCostSupplier': ProductCostSupplier,
      'SupplierID': SupplierID,
    };

    try {
      // Add product to Firestore collection
      await db.collection("products").add(data).then((value) {
        developer.log("Inserted into collection ID: ${value.id}");
      });

      // Optionally, you can clear the fields after registration
      _clearFields();
      
    } catch (e) {
      developer.log("Error: $e");
    }
  }

  void _clearFields() {
    _ProductID.clear();
    _ProductName.clear();
    _ProductDesc.clear();
    _ProductPrice.clear();
    _ProductCostSupplier.clear();
    _SupplierID.clear();
  }
}
