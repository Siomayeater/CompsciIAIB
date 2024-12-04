import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ProductPerformancePage extends StatefulWidget {
  final String companyID;

  const ProductPerformancePage({Key? key, required this.companyID}) : super(key: key);

  @override
  State<ProductPerformancePage> createState() => _ProductPerformancePageState();
}

class _ProductPerformancePageState extends State<ProductPerformancePage> {
  late Future<Map<String, double>> _productPerformanceFuture;
  double totalRevenue = 0.0;

  @override
  void initState() {
    super.initState();
    _productPerformanceFuture = _fetchProductPerformance();
  }

  Future<Map<String, double>> _fetchProductPerformance() async {
    Map<String, double> productPerformance = {};

    try {
      var salesSnapshot = await FirebaseFirestore.instance
          .collection('sales')
          .where('companyID', isEqualTo: widget.companyID)
          .get();

      var productsSnapshot = await FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.companyID)
          .collection('products')
          .get();

      Map<String, double> productPrices = {};

      for (var doc in productsSnapshot.docs) {
        String productName = doc['productName'];
        double price = doc.data().containsKey('productPrice') && doc['productPrice'] != null
            ? doc['productPrice']
            : 0.0;
        productPrices[productName] = price;
      }

      for (var saleDoc in salesSnapshot.docs) {
        String productName = saleDoc['productName'];
        int soldQuantity = saleDoc['soldQuantity'];

        if (productPrices.containsKey(productName)) {
          double price = productPrices[productName]!;
          double revenue = soldQuantity * price;

          productPerformance[productName] = (productPerformance[productName] ?? 0) + revenue;
          totalRevenue += revenue;
        }
      }
    } catch (e) {
      print("Error fetching product performance: $e");
    }

    return productPerformance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Performance'),
      ),
      body: FutureBuilder<Map<String, double>>(
        future: _productPerformanceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No product performance data available."));
          }

          var performanceData = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSummaryCard(),

                const SizedBox(height: 16),

                _buildPieChart(performanceData),

                const SizedBox(height: 16),

                Expanded(
                  child: _buildProductDetails(performanceData),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard() {
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
          const Text(
            "Performance Summary",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Total Revenue: \$${totalRevenue.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(Map<String, double> performanceData) {
    return Container(
      height: 300,
      child: PieChart(
        PieChartData(
          sections: performanceData.entries.map((entry) {
            double percentage = (entry.value / totalRevenue) * 100;
            return PieChartSectionData(
              value: entry.value,
              title: "${percentage.toStringAsFixed(1)}%",
              radius: 60,
              color: Colors.primaries[
                  performanceData.keys.toList().indexOf(entry.key) % Colors.primaries.length],
              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 50,
        ),
      ),
    );
  }

  Widget _buildProductDetails(Map<String, double> performanceData) {
    return ListView.builder(
      itemCount: performanceData.length,
      itemBuilder: (context, index) {
        String productName = performanceData.keys.toList()[index];
        double revenue = performanceData[productName]!;
        return ListTile(
          title: Text(productName),
          subtitle: Text(
            'Revenue: \$${revenue.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 14),
          ),
          trailing: FutureBuilder<DocumentSnapshot?>(
            future: _getProductDocument(productName),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                return const Text("N/A");
              }

              var productData = snapshot.data!;
              double productPrice = productData.get('productPrice') ?? 0.0;
              return Text(
                '\$${productPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14),
              );
            },
          ),
        );
      },
    );
  }

  Future<DocumentSnapshot?> _getProductDocument(String productName) async {
    try {
      var productsSnapshot = await FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.companyID)
          .collection('products')
          .where('productName', isEqualTo: productName)
          .limit(1)
          .get();

      if (productsSnapshot.docs.isNotEmpty) {
        return productsSnapshot.docs.first;
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching product document: $e");
      return null;
    }
  }
}
