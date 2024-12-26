import 'package:compsci_ia/LoginFirebase.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compsci_ia/pages/ViewSalesPage.dart';
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

  Future<void> updateProductQuantity(BuildContext context) async {
    TextEditingController productNameController = TextEditingController();
    TextEditingController quantityController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Product Quantity"),
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
                decoration: const InputDecoration(hintText: "Quantity to Add"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String productName = productNameController.text.trim();
                int? quantityToAdd = int.tryParse(quantityController.text);

                if (productName.isNotEmpty && quantityToAdd != null && quantityToAdd > 0) {
                  try {
                    var productQuerySnapshot = await FirebaseFirestore.instance
                        .collection('quantityproducts')
                        .where('companyID', isEqualTo: companyID)
                        .where('productName', isEqualTo: productName)
                        .get();

                    if (productQuerySnapshot.docs.isNotEmpty) {
                      var productDoc = productQuerySnapshot.docs.first;
                      int currentQuantity = productDoc['quantity'] ?? 0;

                      await productDoc.reference.update({
                        'quantity': currentQuantity + quantityToAdd,
                      });

                      await FirebaseFirestore.instance.collection('auditTrail').add({
                        'action': 'Update Product Quantity',
                        'companyID': companyID,
                        'productName': productName,
                        'quantityAdded': quantityToAdd,
                        'timestamp': Timestamp.now(),
                        'userID': FirebaseAuth.instance.currentUser?.uid,
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Product quantity updated successfully!")),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Product not found.")),
                      );
                    }
                  } catch (e) {
                    print("Error updating product quantity: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to update product quantity: $e")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Invalid input. Please try again.")),
                  );
                }
              },
              child: const Text("Update"),
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
                    await FirebaseFirestore.instance.collection('sales').add({
                      'companyID': companyID,
                      'productName': productName,
                      'soldQuantity': soldQuantity,
                      'date': Timestamp.now(),
                    });

                    await FirebaseFirestore.instance.collection('auditTrail').add({
                      'action': 'Record Sale',
                      'companyID': companyID,
                      'productName': productName,
                      'soldQuantity': soldQuantity,
                      'timestamp': Timestamp.now(),
                      'userID': FirebaseAuth.instance.currentUser?.uid,
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
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => LoginView()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDashboardButton(
              context,
              icon: Icons.bar_chart,
              label: 'Reporting & Analytics',
              color: Colors.teal,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResearchandAnalytics(companyID: companyID),
                ),
              ),
            ),
            _buildDashboardButton(
              context,
              icon: Icons.inventory_2,
              label: 'Product Management',
              color: Colors.orange,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductManagement(companyID: companyID),
                ),
              ),
            ),
            _buildDashboardButton(
              context,
              icon: Icons.rule,
              label: 'Audit Trails',
              color: Colors.blueAccent,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AuditTrailPage(companyID: companyID),
                ),
              ),
            ),
            _buildDashboardButton(
              context,
              icon: Icons.shopping_cart,
              label: 'View Sales',
              color: Colors.purple,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewSalesPage(companyID: companyID),
                ),
              ),
            ),
            _buildDashboardButton(
              context,
              icon: Icons.add_shopping_cart,
              label: 'Add Quantity Product',
              color: Colors.green,
              onPressed: () => updateProductQuantity(context),
            ),
            _buildDashboardButton(
              context,
              icon: Icons.add_shopping_cart,
              label: 'Record Sales',
              color: Colors.lightGreen,
              onPressed: () => recordSale(context),
            ),
            _buildDashboardButton(
              context,
              icon: Icons.people,
              label: 'Supplier Management',
              color: Colors.purple,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SupplierManagement(companyID: companyID),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardButton(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onPressed}) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
