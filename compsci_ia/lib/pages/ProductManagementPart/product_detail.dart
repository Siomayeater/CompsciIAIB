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

  void logAuditTrail(String action, String productID, String productName, String companyID) async {
    try {
      await FirebaseFirestore.instance.collection('auditTrail').add({
        'action': action,
        'productID': productID,
        'productName': productName,
        'timestamp': FieldValue.serverTimestamp(),
        'user': 'userID', 
        'companyID': companyID,
      });
    } catch (e) {
      print('Error logging audit trail: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    logAuditTrail('view', productID, productName, 'companyID'); 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8.0),
                      Text('Size: N/A'),
                      const SizedBox(height: 4.0),
                      Text('Stock Amount: N/A'),
                      const SizedBox(height: 4.0),
                      Text('Location: N/A'),
                    ],
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Center(
                      child: Text(
                        'IMG',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Divider(),
            const SizedBox(height: 8.0),

            Text(
              'Other Product Details:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
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
