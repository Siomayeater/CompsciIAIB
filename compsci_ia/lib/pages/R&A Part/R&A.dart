import 'package:flutter/material.dart';
import 'inventory_report.dart';
import 'sales_analytics.dart';

class ResearchandAnalytics extends StatelessWidget {
  final String companyID;

  const ResearchandAnalytics({super.key, required this.companyID});

  // Helper method to print companyID on button press
  void _printCompanyID() {
    print("Company ID: $companyID");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Research and Analytics'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5, // Half the screen width
              child: ElevatedButton(
                onPressed: () {
                  _printCompanyID();  // Print companyID when this button is pressed
                  // Navigate to the Inventory Report page and pass companyID
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InventoryReport(companyID: companyID),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Inventory Report'),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5, // Half the screen width
              child: ElevatedButton(
                onPressed: () {
                  _printCompanyID();  // Print companyID when this button is pressed
                  // Navigate to the Sales Analytics page and pass companyID
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SalesAnalytics(companyID: companyID),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Sales Analytics'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
