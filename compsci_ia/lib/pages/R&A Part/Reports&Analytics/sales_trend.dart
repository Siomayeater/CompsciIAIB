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
  double minY = 0;
  double maxY = 0;

  @override
  void initState() {
    super.initState();
    _salesDataFuture = _fetchSalesData();
    _dateLabelsFuture = _fetchDateLabels();
  }

  // Fetch sales data (sold quantities over time)
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
        // Ensure there is a 'soldQuantity' field
        if (!doc.data().containsKey('soldQuantity')) {
          print('Skipping document (missing soldQuantity): ${doc.id}');
          continue; // Skip if soldQuantity is missing
        }

        int soldQuantity = doc['soldQuantity'] ?? 0;

        // Track min and max values for Y axis
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

  // Fetch date labels for the sales data
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

  // Export sales trend data to PDF
  Future<void> _exportToPdf(List<FlSpot> salesData, List<String> dateLabels) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text(
                "Sales Trend Report",
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Date', 'Sold Quantity'],
                data: List.generate(
                  salesData.length,
                  (index) => [dateLabels[index], salesData[index].y.toInt()],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
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
                  icon: Icon(Icons.picture_as_pdf),
                  onPressed: () async {
                    var salesData = salesSnapshot.data!;
                    var dateLabels = await _dateLabelsFuture;
                    await _exportToPdf(salesData, dateLabels);
                  },
                );
              }
              return SizedBox.shrink();
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

              var salesData = salesSnapshot.data!;
              var dateLabels = dateSnapshot.data!;

              return Row(
                children: [
                  // Line chart on the left
                  Expanded(
                    flex: 1,
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
                  ),

                  // Descriptive text on the right
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sales Analysis',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 10),
                          Text('This chart represents the number of products sold over time.'),
                          const SizedBox(height: 10),
                          Text('The chart shows the fluctuation in sales across different dates.'),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
