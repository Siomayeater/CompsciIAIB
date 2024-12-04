import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class LowStockLevelReportPage extends StatefulWidget {
  final String companyID;

  const LowStockLevelReportPage({Key? key, required this.companyID}) : super(key: key);

  @override
  State<LowStockLevelReportPage> createState() => _LowStockLevelReportPageState();
}

class _LowStockLevelReportPageState extends State<LowStockLevelReportPage> {
  late Future<Map<String, int>> _stockDataFuture;

  @override
  void initState() {
    super.initState();
    _stockDataFuture = _fetchStockLevels();
  }

  Future<Map<String, int>> _fetchStockLevels() async {
    Map<String, int> stockLevels = {};

    try {
      // Fetch stock quantities
      var quantitySnapshot = await FirebaseFirestore.instance
          .collection('quantityproducts')
          .where('companyID', isEqualTo: widget.companyID)
          .get();

      for (var doc in quantitySnapshot.docs) {
        String productName = doc['productName'];
        int quantity = doc['quantity'];

        stockLevels[productName] = (stockLevels[productName] ?? 0) + quantity;
      }

      // Fetch sales data
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
        title: const Text('Low Stock Level Report'),
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

          var lowStockData = stockData.entries
              .where((entry) => entry.value <= 5)
              .toList();

          if (lowStockData.isEmpty) {
            return const Center(child: Text("No low stock data available."));
          }

          int totalLowStockItems = lowStockData.length;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildBarChart(lowStockData),
                const SizedBox(height: 32),
                _buildKeyStockInformation(totalLowStockItems),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBarChart(List<MapEntry<String, int>> lowStockData) {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          barGroups: lowStockData.map((entry) {
            return BarChartGroupData(
              x: entry.key.hashCode,
              barRods: [
                BarChartRodData(
                  toY: entry.value.toDouble(),
                  color: const Color.fromARGB(255, 84, 58, 56), 
                  width: 15,
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  String title = lowStockData
                      .map((entry) => entry.key)
                      .firstWhere(
                        (key) => key.hashCode == value.toInt(),
                        orElse: () => '',
                      );
                  return Text(
                    title,
                    style: const TextStyle(fontSize: 10),
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildKeyStockInformation(int totalLowStockItems) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Stock Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text('Total Low Stock Items: $totalLowStockItems'),
          const Text('Low stock levels indicate items with quantities ≤ 5.'),
        ],
      ),
    );
  }
}
