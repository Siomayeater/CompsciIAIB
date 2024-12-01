import 'package:compsci_ia/pages/AuditTrails.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:compsci_ia/pages/ProductManagementPart/ProductManagement.dart';
import 'package:compsci_ia/pages/R&A%20Part/R&A.dart';
import 'package:compsci_ia/pages/SupplierManagementPart/SupplierManagement.dart';

class HomePage extends StatelessWidget {
  final String company;
  final String companyID;

  const HomePage({
    Key? key,
    required this.company,
    required this.companyID,
  }) : super(key: key);

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
              Navigator.pushReplacementNamed(context, '/login'); // Navigate back to login page
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Display company and companyID
            Text(
              'Company: $company',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Company ID: $companyID',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            // Buttons to navigate to different pages
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductManagement(companyID: companyID), // Pass companyID
                  ),
                );
              },
              child: const Text('Go to Product Management'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ResearchandAnalytics(),
                  ),
                );
              },
              child: const Text('Go to Research & Analytics'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SupplierManagement(),
                  ),
                );
              },
              child: const Text('Go to Supplier Management'),
            ),
            const SizedBox(height: 10),
            // Button to navigate to Audit Trail
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AuditTrailPage(companyID: companyID), // Pass companyID to the AuditTrailPage
                  ),
                );
              },
              child: const Text('Go to Audit Trail'),
            ),
          ],
        ),
      ),
    );
  }
}
