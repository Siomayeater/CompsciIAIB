import 'package:flutter/material.dart';
import 'inventory_report.dart';
import 'sales_analytics.dart';

class ResearchandAnalytics extends StatelessWidget {
  const ResearchandAnalytics({super.key});

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
                  // Navigate to the Inventory Report page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const InventoryReport()),
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
                  // Navigate to the Sales Analytics page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SalesAnalytics()),
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
