import 'package:flutter/material.dart';

class SalesTrend extends StatelessWidget {
  const SalesTrend({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Trend'),
      ),
      body: const Center(
        child: Text('Welcome to Sales Trend!'),
      ),
    );
  }
}
