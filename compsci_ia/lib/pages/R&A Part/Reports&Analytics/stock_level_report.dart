import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class StockLevelReportPage extends StatefulWidget {
  final String companyID;

  const StockLevelReportPage({Key? key, required this.companyID}) : super(key: key);

  @override
  State<StockLevelReportPage> createState() => _StockLevelReportPageState();
}

class _StockLevelReportPageState extends State<StockLevelReportPage> {
  late Future<Map<String, int>> _stockDataFuture;

  @override
  void initState() {
    super.initState();
    _stockDataFuture = _fetchStockLevels();
  }

  Future<Map<String, int>> _fetchStockLevels() async {
    Map<String, int> stockLevels = {};

    try {
      var quantitySnapshot = await FirebaseFirestore.instance
          .collection('quantityproducts')
          .where('companyID', isEqualTo: widget.companyID)
          .get();

      for (var doc in quantitySnapshot.docs) {
        String productName = doc['productName'];
        int quantity = doc['quantity'];

        stockLevels[productName] = (stockLevels[productName] ?? 0) + quantity;
      }

      var salesSnapshot = await FirebaseFirestore.instance
          .collection('sales')
          .where('companyID', isEqualTo: widget.companyID)
          .get();

      for (var doc in salesSnapshot.docs) {
        String productName = doc['productName'];
        int soldQuantity = doc['soldQuantity'];

        stockLevels[productName] = (stockLevels[productName] ?? 0) - soldQuantity;
      }
    } catch (e) {
      print("Error fetching stock levels: $e");
    }

    return stockLevels;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Level Report'),
      ),
      body: FutureBuilder<Map<String, int>>(
        future: _stockDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No stock data available."));
          }

          var stockData = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Adjust the height of the BarChart
                Container(
                  height: 400,  // Adjust the height as necessary
                  child: BarChart(
                    BarChartData(
                      barGroups: stockData.entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key.hashCode,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.toDouble(),
                              color: entry.value <= 5
                                  ? const Color.fromARGB(255, 84, 58, 56)
                                  : Colors.blue,
                              width: 15,
                            ),
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,  // Adds space for labels
                            getTitlesWidget: (double value, TitleMeta meta) {
                              // Get the product name based on its hash code
                              String title = stockData.keys.firstWhere(
                                (key) => key.hashCode == value.toInt(),
                                orElse: () => '',
                              );

                              return Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,  // Adds space for labels on the left
                            getTitlesWidget: (double value, TitleMeta meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(show: false),  // Hides grid lines
                      borderData: FlBorderData(show: false),  // Hides the chart border
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
