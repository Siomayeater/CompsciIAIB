import 'package:flutter/material.dart';

class Audittrails extends StatelessWidget {
  const Audittrails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit'),
      ),
      body: const Center(
        child: Text('This is the audit part'),
      ),
    );
  }
}
