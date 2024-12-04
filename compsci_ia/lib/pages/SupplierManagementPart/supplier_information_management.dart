import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SupplierInformationManagement extends StatefulWidget {
  const SupplierInformationManagement({super.key, required String companyID});

  @override
  _SupplierInformationManagementState createState() =>
      _SupplierInformationManagementState();
}

class _SupplierInformationManagementState
    extends State<SupplierInformationManagement> {
  // List to store suppliers and their contract details (for displaying)
  List<Map<String, String>> suppliers = [];

  // Controller for the text fields
  final _companyIdController = TextEditingController();
  final _supplierNameController = TextEditingController();
  final _contractDetailsController = TextEditingController();

  // Method to fetch suppliers from Firestore
  Future<void> fetchSuppliers() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('suppliers').get();

      // Map the documents into a list of maps, and ensure correct types for each field
      final supplierList = snapshot.docs.map((doc) {
        // Safely get fields with fallback values if missing
        final companyID = doc.data().containsKey('companyID')
            ? doc['companyID'] as String
            : 'No company ID';
        final supplierName = doc.data().containsKey('supplierName')
            ? doc['supplierName'] as String
            : 'Unnamed Supplier';
        final contractDetails = doc.data().containsKey('contractDetails')
            ? doc['contractDetails'] as String
            : 'No contract details';

        return {
          'id': doc.id, // Document ID (String type)
          'companyID': companyID,
          'supplierName': supplierName,
          'contractDetails': contractDetails,
        };
      }).toList();

      // Update the state with the fetched suppliers
      setState(() {
        suppliers = supplierList;
      });
    } catch (e) {
      print("Error fetching suppliers: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error fetching suppliers: $e'),
      ));
    }
  }

  // Method to add a new supplier to Firestore
  Future<void> addSupplier() async {
    String companyID = _companyIdController.text;
    String supplierName = _supplierNameController.text;
    String contractDetails = _contractDetailsController.text;

    if (companyID.isNotEmpty && supplierName.isNotEmpty && contractDetails.isNotEmpty) {
      try {
        // Add supplier to Firestore
        await FirebaseFirestore.instance.collection('suppliers').add({
          'companyID': companyID, // Store the company ID
          'supplierName': supplierName, // Store the supplier name
          'contractDetails': contractDetails, // Store the contract details
        });

        setState(() {
          suppliers.add({
            'companyID': companyID,
            'supplierName': supplierName,
            'contractDetails': contractDetails,
          });
        });

        // Clear the text fields
        _companyIdController.clear();
        _supplierNameController.clear();
        _contractDetailsController.clear();

        Navigator.pop(context); // Close the dialog
      } catch (e) {
        // Handle any errors during the Firestore operation
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error adding supplier: $e'),
        ));
      }
    } else {
      // Show error message if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill in all fields'),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSuppliers(); // Fetch the suppliers when the screen is loaded
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
                            subtitle: Text(
                                'Contract: ${suppliers[index]['contractDetails'] ?? ''}'),
                          ),
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Show dialog to add a new supplier
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Add New Supplier'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _companyIdController,
                            decoration: const InputDecoration(
                              labelText: 'Company ID',
                            ),
                          ),
                          TextField(
                            controller: _supplierNameController,
                            decoration: const InputDecoration(
                              labelText: 'Supplier Name',
                            ),
                          ),
                          TextField(
                            controller: _contractDetailsController,
                            decoration: const InputDecoration(
                              labelText: 'Contract Details',
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: addSupplier, // Call addSupplier function
                          child: const Text('Add'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Close the dialog
                          },
                          child: const Text('Cancel'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Add New Supplier'),
            ),
          ],
        ),
      ),
    );
  }
}
