import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewSalesPage extends StatelessWidget {
  final String companyID;

  const ViewSalesPage({Key? key, required this.companyID}) : super(key: key);

  Future<List<Map<String, dynamic>>> getTodaySales() async {
    // Get the current date
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    // Convert to Firestore Timestamps
    Timestamp startTimestamp = Timestamp.fromDate(startOfDay);
    Timestamp endTimestamp = Timestamp.fromDate(endOfDay);

    // Query the sales collection for today
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('sales')
        .where('companyID', isEqualTo: companyID)
        .where('date', isGreaterThanOrEqualTo: startTimestamp)
        .where('date', isLessThanOrEqualTo: endTimestamp)
        .get();

    // Return the list of sales
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
        title: const Text('Sales for Today'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getTodaySales(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var sale = snapshot.data![index];
                return ListTile(
                  title: Text('Product: ${sale['productName']}'),
                  subtitle: Text('Quantity Sold: ${sale['soldQuantity']}'),
                  trailing: Text('Date: ${sale['date']}'),
                );
              },
            );
          } else {
            return const Center(child: Text('No sales today.'));
          }
        },
      ),
    );
  }
}
