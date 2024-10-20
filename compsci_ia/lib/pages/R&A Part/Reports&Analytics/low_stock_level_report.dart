import 'package:flutter/material.dart';

class LowStockLevelReport extends StatelessWidget {
  const LowStockLevelReport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Low Stock Level Report'),
      ),
      body: const Center(
        child: Text('Welcome to Low Stock Level Report!'),
      ),
    );
  }
}
