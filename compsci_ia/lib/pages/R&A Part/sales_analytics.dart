import 'package:compsci_ia/pages/R&A%20Part/Reports&Analytics/Product_performance.dart';
import 'package:compsci_ia/pages/R&A%20Part/Reports&Analytics/Sales_Trend.dart';
import 'package:flutter/material.dart';


class SalesAnalytics extends StatelessWidget {
  const SalesAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Analytics'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5, // Half the screen width
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the Product Performance page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProductPerformance()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Product Performance'),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5, // Half the screen width
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the Sales Trend page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SalesTrend()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Sales Trend'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
