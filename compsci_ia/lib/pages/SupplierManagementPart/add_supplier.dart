import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContractDetails extends StatefulWidget {
  final String companyID;  // Added companyID to the constructor

  const ContractDetails({super.key, required this.companyID});

  @override
  _ContractDetailsState createState() => _ContractDetailsState();
}

class _ContractDetailsState extends State<ContractDetails> {
  final List<Map<String, String>> suppliers = [];
  final _supplierNameController = TextEditingController();
  final _contactController = TextEditingController();  

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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (supplierName.isNotEmpty && contact.isNotEmpty) {
                  // Get the current user ID
                  String userId = FirebaseAuth.instance.currentUser!.uid;

                  try {
                    // Add supplier to Firestore with companyID, supplierName, and contact
                    await FirebaseFirestore.instance.collection('suppliers').add({
                      'companyID': widget.companyID,  // Store the company ID
                      'supplierName': supplierName,
                      'contact': contact,
                      'userId': userId, // Add the userId to reference the creator
                    });

                    setState(() {
                      suppliers.add({
                        'supplierName': supplierName,
                        'contact': contact,
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

  Future<void> getSuppliers() async {
    try {
      // Fetch suppliers for the given companyID from Firestore
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('suppliers')
          .where('companyID', isEqualTo: widget.companyID)  // Filter by companyID
          .get();

      setState(() {
        suppliers.clear();
        snapshot.docs.forEach((doc) {
          suppliers.add({
            'supplierName': doc['supplierName'],
            'contact': doc['contact'],
          });
        });
      });
    } catch (e) {
      print("Error fetching suppliers: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getSuppliers();
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
