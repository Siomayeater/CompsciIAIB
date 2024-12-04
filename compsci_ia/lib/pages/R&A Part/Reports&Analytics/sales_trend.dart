import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class SalesTrendReportPage extends StatefulWidget {
  final String companyID;

  const SalesTrendReportPage({Key? key, required this.companyID}) : super(key: key);

  @override
  State<SalesTrendReportPage> createState() => _SalesTrendReportPageState();
}

class _SalesTrendReportPageState extends State<SalesTrendReportPage> {
  late Future<List<FlSpot>> _salesDataFuture;
  late Future<List<String>> _dateLabelsFuture;
  late Future<Map<String, int>> _trendSummaryFuture;

  double minY = 0;
  double maxY = 0;

  @override
  void initState() {
    super.initState();
    _salesDataFuture = _fetchSalesData();
    _dateLabelsFuture = _fetchDateLabels();
    _trendSummaryFuture = _calculateTrendSummary();
  }

  Future<List<FlSpot>> _fetchSalesData() async {
    List<FlSpot> salesData = [];
    try {
      var salesSnapshot = await FirebaseFirestore.instance
          .collection('sales')
          .where('companyID', isEqualTo: widget.companyID)
          .orderBy('date')
          .get();

      int index = 0;
      for (var doc in salesSnapshot.docs) {
        int soldQuantity = doc['soldQuantity'] ?? 0;

        minY = index == 0 ? soldQuantity.toDouble() : minY;
        maxY = index == 0 ? soldQuantity.toDouble() : maxY;

        salesData.add(FlSpot(index.toDouble(), soldQuantity.toDouble()));

        if (soldQuantity < minY) minY = soldQuantity.toDouble();
        if (soldQuantity > maxY) maxY = soldQuantity.toDouble();

        index++;
      }

      double padding = (maxY - minY) * 0.1;
      minY -= padding;
      maxY += padding;
    } catch (e) {
      print("Error fetching sales data: $e");
    }
    return salesData;
  }

  Future<List<String>> _fetchDateLabels() async {
    List<String> dateLabels = [];
    try {
      var salesSnapshot = await FirebaseFirestore.instance
          .collection('sales')
          .where('companyID', isEqualTo: widget.companyID)
          .orderBy('date')
          .get();

      for (var doc in salesSnapshot.docs) {
        DateTime date = (doc['date'] as Timestamp).toDate();
        dateLabels.add(DateFormat('MM/dd').format(date));
      }
    } catch (e) {
      print("Error fetching date labels: $e");
    }
    return dateLabels;
  }

  Future<Map<String, int>> _calculateTrendSummary() async {
    Map<String, int> summary = {'weekly': 0, 'monthly': 0, 'total': 0};

    try {
      var salesSnapshot = await FirebaseFirestore.instance
          .collection('sales')
          .where('companyID', isEqualTo: widget.companyID)
          .get();

      DateTime now = DateTime.now();
      for (var doc in salesSnapshot.docs) {
        int soldQuantity = doc['soldQuantity'] ?? 0;
        DateTime date = (doc['date'] as Timestamp).toDate();

        summary['total'] = (summary['total'] ?? 0) + soldQuantity;

        if (date.isAfter(now.subtract(const Duration(days: 7)))) {
          summary['weekly'] = (summary['weekly'] ?? 0) + soldQuantity;
        }
        if (date.isAfter(DateTime(now.year, now.month - 1))) {
          summary['monthly'] = (summary['monthly'] ?? 0) + soldQuantity;
        }
      }
    } catch (e) {
      print("Error calculating sales trends: $e");
    }
    return summary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Trend Report'),
        actions: [
          FutureBuilder<List<FlSpot>>(
            future: _salesDataFuture,
            builder: (context, salesSnapshot) {
              if (salesSnapshot.connectionState == ConnectionState.done &&
                  salesSnapshot.hasData &&
                  salesSnapshot.data!.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  onPressed: () async {
                    var salesData = salesSnapshot.data!;
                    var dateLabels = await _dateLabelsFuture;
                    await _exportToPdf(salesData, dateLabels);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<FlSpot>>(
        future: _salesDataFuture,
        builder: (context, salesSnapshot) {
          if (salesSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (salesSnapshot.hasError) {
            return Center(child: Text("Error: ${salesSnapshot.error}"));
          }
          if (!salesSnapshot.hasData || salesSnapshot.data!.isEmpty) {
            return const Center(child: Text("No sales data available."));
          }

          return FutureBuilder<List<String>>(
            future: _dateLabelsFuture,
            builder: (context, dateSnapshot) {
              if (dateSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (dateSnapshot.hasError) {
                return Center(child: Text("Error: ${dateSnapshot.error}"));
              }
              if (!dateSnapshot.hasData || dateSnapshot.data!.isEmpty) {
                return const Center(child: Text("No date labels available."));
              }

              return FutureBuilder<Map<String, int>>(
                future: _trendSummaryFuture,
                builder: (context, summarySnapshot) {
                  if (summarySnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (summarySnapshot.hasError) {
                    return Center(child: Text("Error: ${summarySnapshot.error}"));
                  }
                  if (!summarySnapshot.hasData) {
                    return const Center(child: Text("No trend summary available."));
                  }

                  var salesData = salesSnapshot.data!;
                  var dateLabels = dateSnapshot.data!;
                  var trendSummary = summarySnapshot.data!;

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildLineChart(salesData, dateLabels),
                        const SizedBox(height: 32),
                        _buildTrendSummary(trendSummary),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLineChart(List<FlSpot> salesData, List<String> dateLabels) {
    return SizedBox(
      height: 300,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            minY: minY,
            maxY: maxY,
            lineBarsData: [
              LineChartBarData(
                spots: salesData,
                isCurved: true,
                color: Colors.blue,
                barWidth: 4,
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.3),
                      Colors.blue.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            ],
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: (salesData.length / 5).ceil().toDouble(),
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index >= 0 && index < dateLabels.length) {
                      return Text(
                        dateLabels[index],
                        style: const TextStyle(fontSize: 12),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendSummary(Map<String, int> trendSummary) {
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
            "Sales Summary",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text("Weekly Sales: ${trendSummary['weekly']} items"),
          Text("Monthly Sales: ${trendSummary['monthly']} items"),
          Text("Total Sales: ${trendSummary['total']} items"),
        ],
      ),
    );
  }
}

_exportToPdf(List<FlSpot> salesData, List<String> dateLabels) {
}
