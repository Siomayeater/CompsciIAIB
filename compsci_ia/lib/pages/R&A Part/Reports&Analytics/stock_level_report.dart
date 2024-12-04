import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class StockLevelReportPage extends StatefulWidget {
  final String companyID;

  const StockLevelReportPage({Key? key, required this.companyID}) : super(key: key);

  @override
  State<StockLevelReportPage> createState() => _StockLevelReportPageState();
}

class _StockLevelReportPageState extends State<StockLevelReportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<Map<String, int>> _stockDataFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('Stock LVL Report'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
            Tab(text: 'Quarterly'),
            Tab(text: 'Yearly'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportPage(),
          _buildReportPage(),
          _buildReportPage(),
          _buildReportPage(),
        ],
      ),
    );
  }

  Widget _buildReportPage() {
    return FutureBuilder<Map<String, int>>(
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
        int totalStock = stockData.values.fold(0, (sum, value) => sum + value);
        int lowStockCount =
            stockData.values.where((quantity) => quantity <= 5).length;
        int highStockCount =
            stockData.values.where((quantity) => quantity > 20).length;

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildBarChart(stockData),
              const SizedBox(height: 32),
              _buildKeyStockInformation(totalStock, lowStockCount, highStockCount),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBarChart(Map<String, int> stockData) {
    return SizedBox(
      height: 250,
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
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  String title = stockData.keys.firstWhere(
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

  Widget _buildKeyStockInformation(int totalStock, int lowStockCount, int highStockCount) {
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
          Text('Total Stock: $totalStock'),
          Text('Low Stock (≤5): $lowStockCount'),
          Text('High Stock (>20): $highStockCount'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
