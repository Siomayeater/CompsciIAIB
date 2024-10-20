import 'package:compsci_ia/pages/R&A%20Part/Reports&Analytics/low_stock_level_report.dart';
import 'package:compsci_ia/pages/R&A%20Part/Reports&Analytics/stock_level_report.dart';
import 'package:flutter/material.dart';

class InventoryReport extends StatelessWidget {
  const InventoryReport({super.key});

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
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5, // Half the screen width
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the Stock Level Report page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StockLevelReport()),
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
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5, // Half the screen width
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the Low Stock Level Report page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LowStockLevelReport()),
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