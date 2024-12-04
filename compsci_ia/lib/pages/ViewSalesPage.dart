import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 

class ViewSalesPage extends StatelessWidget {
  final String companyID;

  const ViewSalesPage({Key? key, required this.companyID}) : super(key: key);

  Future<List<Map<String, dynamic>>> getTodaySales() async {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    Timestamp startTimestamp = Timestamp.fromDate(startOfDay);
    Timestamp endTimestamp = Timestamp.fromDate(endOfDay);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('sales')
        .where('companyID', isEqualTo: companyID)
        .where('date', isGreaterThanOrEqualTo: startTimestamp)
        .where('date', isLessThanOrEqualTo: endTimestamp)
        .get();

    return snapshot.docs.map((doc) {
      return {
        'productName': doc['productName'],
        'soldQuantity': doc['soldQuantity'],
        'date': doc['date'].toDate(),
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Sales'),
        backgroundColor: Colors.blueAccent, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: getTodaySales(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Sales Overview',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                  ),
                  const SizedBox(height: 16.0),
                  // Sales List
                  Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var sale = snapshot.data![index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              child: Text(
                                sale['soldQuantity'].toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              sale['productName'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Sold: ${sale['soldQuantity']}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: Text(
                              DateFormat('MM/dd/yyyy').format(sale['date']),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            } else {
              return const Center(
                child: Text(
                  'No sales recorded today.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
