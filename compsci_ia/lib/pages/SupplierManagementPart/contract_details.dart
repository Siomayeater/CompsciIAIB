import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContractDetails extends StatefulWidget {
  const ContractDetails({super.key});

  @override
  _ContractDetailsState createState() => _ContractDetailsState();
}

class _ContractDetailsState extends State<ContractDetails> {
  final List<Map<String, String>> suppliers = [];
  List<String> supplierIds = [];  
  String? selectedSupplierID;
  final _supplierNameController = TextEditingController();
  final _contactController = TextEditingController();

  Future<void> _fetchSuppliers() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('suppliers').get();
      final supplierList = snapshot.docs.map((doc) => doc.id).toList();
      setState(() {
        supplierIds = supplierList;
      });
    } catch (e) {
      print('Error fetching suppliers: $e');
    }
  }

  // Method to add a new supplier
  void addSupplier() {
    String supplierName = '';
    String contact = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Supplier'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _supplierNameController,
                onChanged: (value) {
                  supplierName = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Supplier Name',
                ),
              ),
              TextField(
                controller: _contactController,
                onChanged: (value) {
                  contact = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Contact Information',
                ),
              ),
              const SizedBox(height: 10),
              supplierIds.isEmpty
                  ? const CircularProgressIndicator()  // Show loading until suppliers are fetched
                  : DropdownButton<String>(
                      value: selectedSupplierID,
                      hint: const Text('Select Supplier'),
                      onChanged: (newValue) {
                        setState(() {
                          selectedSupplierID = newValue;
                        });
                      },
                      items: supplierIds.map((supplierID) {
                        return DropdownMenuItem<String>(
                          value: supplierID,
                          child: Text(supplierID),  // Display the supplier ID (you can customize this)
                        );
                      }).toList(),
                    ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (supplierName.isNotEmpty && contact.isNotEmpty && selectedSupplierID != null) {
                  // Add supplier to Firestore with companyID, supplierName, and contact
                  try {
                    // Add supplier to Firestore
                    await FirebaseFirestore.instance.collection('suppliers').add({
                      'companyID': selectedSupplierID!,  // Store the selected supplierID as companyID
                      'supplierName': supplierName,
                      'contact': contact,
                    });

                    setState(() {
                      suppliers.add({
                        'supplierName': supplierName,
                        'contact': contact,
                        'supplierID': selectedSupplierID!,
                      });
                    });

                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Error adding supplier: $e'),
                    ));
                  }
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
  void initState() {
    super.initState();
    _fetchSuppliers();  // Fetch supplier IDs when the screen is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contract Details'),
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
                            subtitle: Text(suppliers[index]['contact'] ?? ''),
                            trailing: Text(suppliers[index]['supplierID'] ?? 'No ID'),
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
