import 'package:flutter/material.dart';

class ProductDetail extends StatelessWidget {
  final String productName;

  const ProductDetail({super.key, required this.productName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(productName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Name: $productName',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            // Add any additional information related to the product here
            Text(
              'This is a detailed page about $productName.',
              style: const TextStyle(fontSize: 18),
            ),
            // You can add more fields like product description, price, etc.
          ],
        ),
      ),
    );
  }
}
