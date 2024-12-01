import 'package:flutter/material.dart';
import 'package:compsci_ia/pages/R&A%20Part/R&A.dart';
import 'package:compsci_ia/pages/ProductManagementPart/ProductManagement.dart';
import 'package:compsci_ia/pages/AuditTrails.dart';
import 'package:compsci_ia/pages/SupplierManagementPart/SupplierManagement.dart';

class HomePage extends StatelessWidget {
  final String company;
  final String companyID;  // Define companyID to pass to other pages

  const HomePage({super.key, required this.company, required this.companyID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to the Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Your Company: $company',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 30),

            // Buttons for navigation
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ResearchandAnalytics()), // Navigate to R&A page
                );
              },
              child: const Text('Reports & Analytics'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductManagement(companyID: companyID), // Pass companyID to ProductManagement
                  ),
                );
              },
              child: const Text('Product Management'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SupplierManagement()), // Navigate to Supplier Management
                );
              },
              child: const Text('Supplier Management'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Audittrails()), // Navigate to Audit Trails
                );
              },
              child: const Text('Audit Trails'),
            ),
          ],
        ),
      ),
    );
  }
}
