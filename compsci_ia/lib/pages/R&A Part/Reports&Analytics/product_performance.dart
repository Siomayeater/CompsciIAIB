import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class ProductPerformancePage extends StatefulWidget {
  final String companyID;

  const ProductPerformancePage({Key? key, required this.companyID}) : super(key: key);

  @override
  State<ProductPerformancePage> createState() => _ProductPerformancePageState();
}

class _ProductPerformancePageState extends State<ProductPerformancePage> {
  late Future<Map<String, double>> _productPerformanceFuture;

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

      // Fetch the product prices
      for (var doc in productsSnapshot.docs) {
        String productName = doc['productName'];
        // Check if productPrice exists and is a valid number
        double price = doc.data().containsKey('productPrice') && doc['productPrice'] != null
            ? doc['productPrice']
            : 0.0; // Use 0.0 if price is missing or null
        productPrices[productName] = price;
      }

      // Calculate the revenue for each product
      for (var saleDoc in salesSnapshot.docs) {
        String productName = saleDoc['productName'];
        int soldQuantity = saleDoc['soldQuantity'];

        if (productPrices.containsKey(productName)) {
          double price = productPrices[productName]!;
          double revenue = soldQuantity * price;

          productPerformance[productName] = (productPerformance[productName] ?? 0) + revenue;
        }
      }
    } catch (e) {
      print("Error fetching product performance: $e");
    }

    return productPerformance;
  }

  Future<DocumentSnapshot?> _getProductDocument(String productName) async {
    try {
      var productsSnapshot = await FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.companyID)
          .collection('products')
          .where('productName', isEqualTo: productName) // Filter by product name
          .limit(1) // Get a single product document
          .get();

      if (productsSnapshot.docs.isNotEmpty) {
        return productsSnapshot.docs[0];
      } else {
        return null; // No product found
      }
    } catch (e) {
      print("Error fetching product document: $e");
      return null;
    }
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
                // Pie Chart - takes up half the screen
                Container(
                  height: MediaQuery.of(context).size.height / 2, // Half of the screen height
                  child: PieChart(
                    PieChartData(
                      sections: performanceData.entries.map((entry) {
                        return PieChartSectionData(
                          value: entry.value,
                          title: entry.key,
                          radius: 50,
                          color: Colors.primaries[performanceData.keys.toList().indexOf(entry.key) % Colors.primaries.length],
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Product Details Section - takes up the other half of the screen
                Expanded(
                  child: ListView.builder(
                    itemCount: performanceData.length,
                    itemBuilder: (context, index) {
                      String productName = performanceData.keys.toList()[index];
                      double revenue = performanceData[productName]!;
                      return FutureBuilder<DocumentSnapshot?>(
                        future: _getProductDocument(productName), // Get product document based on productName
                        builder: (context, productSnapshot) {
                          if (productSnapshot.connectionState == ConnectionState.waiting) {
                            return const ListTile(
                              title: Text('Loading...'),
                            );
                          }

                          if (productSnapshot.hasError) {
                            return ListTile(
                              title: Text('Error: ${productSnapshot.error}'),
                            );
                          }

                          if (!productSnapshot.hasData || productSnapshot.data == null) {
                            return ListTile(
                              title: Text('No Product Data for: $productName'),
                            );
                          }

                          var productData = productSnapshot.data!;
                          try {
                            double productPrice = productData.get('productPrice') ?? 0.0;

                            return ListTile(
                              title: Text(productName),
                              subtitle: Text(
                                  'Price: \$${productPrice.toStringAsFixed(2)}\nRevenue: \$${revenue.toStringAsFixed(2)}'),
                            );
                          } catch (e) {
                            return ListTile(
                              title: Text('Price not availaable for $productName'),
                            );
                          }
                        },
                      );
                    },
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

