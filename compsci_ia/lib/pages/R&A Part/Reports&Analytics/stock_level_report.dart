import 'package:flutter/material.dart';

class StockLevelReport extends StatelessWidget {
  const StockLevelReport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Level Report'),
      ),
      body: const Center(
        child: Text('Welcome to Stock Level Report!'),
      ),
    );
  }
}
