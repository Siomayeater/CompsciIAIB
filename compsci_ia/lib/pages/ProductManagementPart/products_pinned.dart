import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductsPinned extends StatelessWidget {
  final String productID;
  final String productName;
  final String productDesc;
  final double productPrice;
  final double productPriceSupplier;
  final String supplierID;

  const ProductsPinned({
    Key? key,
    required this.productID,
    required this.productName,
    required this.productDesc,
    required this.productPrice,
    required this.productPriceSupplier,
    required this.supplierID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pinned: $productName'),
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
