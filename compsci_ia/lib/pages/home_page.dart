import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compsci_ia/pages/ViewSalesPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:compsci_ia/pages/ProductManagementPart/ProductManagement.dart';
import 'package:compsci_ia/pages/R&A%20Part/R&A.dart';
import 'package:compsci_ia/pages/SupplierManagementPart/SupplierManagement.dart';
import 'package:compsci_ia/pages/AuditTrails.dart';

class HomePage extends StatelessWidget {
  final String company;
  final String companyID;

  const HomePage({
    Key? key,
    required this.company,
    required this.companyID,
  }) : super(key: key);

  // Helper method to print companyID on button press
  void _printCompanyID() {
    print("Company ID: $companyID");
  }

  Future<void> addProduct(BuildContext context) async {
    TextEditingController productNameController = TextEditingController();
    TextEditingController quantityController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Product"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('companies')
                    .doc(companyID)
                    .collection('products')
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text("No products found for this company");
                  }
                  List<DropdownMenuItem<String>> items = [];
                  for (var doc in snapshot.data!.docs) {
                    items.add(DropdownMenuItem<String>(
                      value: doc['productName'],
                      child: Text(doc['productName']),
                    ));
                  }
                  return DropdownButton<String>(
                    hint: const Text('Select Product'),
                    items: items,
                    onChanged: (value) {
                      productNameController.text = value ?? '';
                    },
                    value: productNameController.text.isEmpty
                        ? null
                        : productNameController.text,
                  );
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(hintText: "Quantity"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String productName = productNameController.text.trim();
                int? quantity = int.tryParse(quantityController.text);

                if (productName.isNotEmpty && quantity != null && quantity > 0) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('quantityproducts')
                        .add({
                          'companyID': companyID,
                          'productName': productName,
                          'quantity': quantity,
                        });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Product added successfully!")),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    print("Error adding product: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to add product: $e")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Invalid input. Please try again.")),
                  );
                }
              },
              child: const Text("Add"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Future<void> recordSale(BuildContext context) async {
    TextEditingController productNameController = TextEditingController();
    TextEditingController soldQuantityController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Record Sale"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('companies')
                    .doc(companyID)
                    .collection('products')
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text("No products found for this company");
                  }
                  List<DropdownMenuItem<String>> items = [];
                  for (var doc in snapshot.data!.docs) {
                    items.add(DropdownMenuItem<String>(
                      value: doc['productName'],
                      child: Text(doc['productName']),
                    ));
                  }
                  return DropdownButton<String>(
                    hint: const Text('Select Product'),
                    items: items,
                    onChanged: (value) {
                      productNameController.text = value ?? '';
                    },
                    value: productNameController.text.isEmpty
                        ? null
                        : productNameController.text,
                  );
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: soldQuantityController,
                decoration: const InputDecoration(hintText: "Sold Quantity"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String productName = productNameController.text.trim();
                int? soldQuantity = int.tryParse(soldQuantityController.text);

                if (productName.isNotEmpty && soldQuantity != null && soldQuantity > 0) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('sales')
                        .add({
                          'companyID': companyID,
                          'productName': productName,
                          'soldQuantity': soldQuantity,
                          'date': Timestamp.now(),
                        });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Sale recorded successfully!")),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    print("Error recording sale: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to record sale: $e")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Invalid input. Please try again.")),
                  );
                }
              },
              child: const Text("Record"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
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
        title: Text('Welcome, $company'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Company: $company', style: const TextStyle(fontSize: 18)),
            Text('Company ID: $companyID', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _printCompanyID();  // Print companyID when this button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductManagement(companyID: companyID),
                  ),
                );
              },
              child: const Text('Go to Product Management'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _printCompanyID();  // Print companyID when this button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ResearchandAnalytics(companyID: companyID)),
                );
              },
              child: const Text('Go to Research & Analytics'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _printCompanyID();  // Print companyID when this button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SupplierManagement(companyID: companyID)),
                );
              },
              child: const Text('Go to Supplier Management'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _printCompanyID();  // Print companyID when this button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AuditTrailPage(companyID: companyID),
                  ),
                );
              },
              child: const Text('Go to Audit Trail'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _printCompanyID();  // Print companyID when this button is pressed
                addProduct(context);
              },
              child: const Text("Add Product"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _printCompanyID();  // Print companyID when this button is pressed
                recordSale(context);
              },
              child: const Text("Record Sale"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _printCompanyID();  // Print companyID when this button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewSalesPage(companyID: companyID)),
                );
              },
              child: const Text("View Sales"),
            ),
          ],
        ),
      ),
    );
  }
}
