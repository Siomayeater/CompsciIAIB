import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductDetail extends StatelessWidget {
  final String productID;
  final String productName;
  final String productDesc;
  final double productPrice;
  final double productPriceSupplier;
  final String supplierID;

  const ProductDetail({
    Key? key,
    required this.productID,
    required this.productName,
    required this.productDesc,
    required this.productPrice,
    required this.productPriceSupplier,
    required this.supplierID,
  }) : super(key: key);

  // Method to log the audit trail when viewing product details
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
    // Log the viewing of the product in the audit trail when this page is loaded
    logAuditTrail('view', productID, productName, 'companyID'); // Pass companyID dynamically as needed

    return Scaffold(
      appBar: AppBar(
        title: Text(productName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product Name: $productName', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8.0),
            Text('Description: $productDesc'),
            const SizedBox(height: 8.0),
            Text('Price: \$${productPrice.toStringAsFixed(2)}'),
            const SizedBox(height: 8.0),
            Text('Supplier Price: \$${productPriceSupplier.toStringAsFixed(2)}'),
            const SizedBox(height: 8.0),
            Text('Supplier ID: $supplierID'),
          ],
        ),
      ),
    );
  }
}
