import 'package:flutter/material.dart';
import 'key_documentation.dart';
import 'cost_reports.dart';

class FinancialManagement extends StatelessWidget {
  const FinancialManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Management'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to the Key Documentation page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const KeyDocumentation()),
                );
              },
              child: const Text('Key Documentation'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the Cost Reports page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CostReports()),
                );
              },
              child: const Text('Cost Reports'),
            ),
          ],
        ),
      ),
    );
  }
}
