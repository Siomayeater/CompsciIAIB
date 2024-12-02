import 'package:compsci_ia/pages/R&A%20Part/Reports&Analytics/low_stock_level_report.dart';
import 'package:compsci_ia/pages/R&A%20Part/Reports&Analytics/stock_level_report.dart';
import 'package:flutter/material.dart';

class InventoryReport extends StatelessWidget {
  final String companyID;

  const InventoryReport({super.key, required this.companyID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Report'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Stock Level Report Button
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5, // Half the screen width
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the Stock Level Report page with the companyID
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StockLevelReportPage(companyID: companyID),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Stock Level Report'),
              ),
            ),
            const SizedBox(height: 20),
            // Low Stock Level Report Button
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5, // Half the screen width
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the Low Stock Level Report page with the companyID
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LowStockLevelReportPage(companyID: companyID), // Pass companyID here
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Low Stock Level Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
