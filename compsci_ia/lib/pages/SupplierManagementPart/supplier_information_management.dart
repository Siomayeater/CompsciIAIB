import 'package:flutter/material.dart';

class SupplierInformationManagement extends StatefulWidget {
  const SupplierInformationManagement({super.key});

  @override
  _SupplierInformationManagementState createState() => _SupplierInformationManagementState();
}

class _SupplierInformationManagementState extends State<SupplierInformationManagement> {
  // List to store suppliers and their contract details
  final List<Map<String, String>> suppliers = [];

  void addSupplier() {
    String supplierName = '';
    String contractDetails = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Supplier'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  supplierName = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Supplier Name',
                ),
              ),
              TextField(
                onChanged: (value) {
                  contractDetails = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Contract Details',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (supplierName.isNotEmpty && contractDetails.isNotEmpty) {
                  setState(() {
                    suppliers.add({
                      'supplierName': supplierName,
                      'contractDetails': contractDetails,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier Information Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            suppliers.isEmpty
                ? const Center(child: Text('No suppliers added yet'))
                : Expanded(
                    child: ListView.builder(
                      itemCount: suppliers.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(suppliers[index]['supplierName'] ?? ''),
                            subtitle: Text('Contract: ${suppliers[index]['contractDetails'] ?? ''}'),
                          ),
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: addSupplier,
              child: const Text('Add New Supplier'),
            ),
          ],
        ),
      ),
    );
  }
}
