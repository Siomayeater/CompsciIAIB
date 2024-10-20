import 'package:flutter/material.dart';
import 'financial_management.dart';
import 'supplier_information_management.dart';

class SupplierManagement extends StatelessWidget {
  const SupplierManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Management Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5, // Half the width of the screen
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the Financial Management page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FinancialManagement()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20), // Increase button height
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Financial Management'),
              ),
            ),
            const SizedBox(height: 20), // Adds spacing between the buttons
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5, // Half the width of the screen
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the Supplier Information Management page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SupplierInformationManagement()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Supplier Information Management'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
