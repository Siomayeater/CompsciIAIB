import 'package:compsci_ia/Login.dart';
import 'package:compsci_ia/pages/R&A%20Part/R&A.dart';
import 'package:compsci_ia/pages/ProductManagementPart/ProductManagement.dart';
import 'package:compsci_ia/pages/AuditTrails.dart';
import 'package:compsci_ia/pages/SupplierManagementPart/SupplierManagement.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Main Menu',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20.0),
        crossAxisCount: 2, // 2 columns
        childAspectRatio: 2, // Aspect ratio of boxes
        children: [
          MenuBox(
            title: 'Reporting & Analytics',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ResearchandAnalytics()),
              );
            },
          ),
          MenuBox(
            title: 'Product Management',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductManagement()),
              );
            },
          ),
          MenuBox(
            title: 'Audit Trails',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Audittrails()),
              );
            },
          ),
          MenuBox(
            title: 'Supplier Management',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SupplierManagement()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class MenuBox extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const MenuBox({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}