import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  

class AuditTrailPage extends StatelessWidget {
  final String companyID;

  const AuditTrailPage({super.key, required this.companyID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Trails'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                print('Search query: $value');
              },
            ),
            const SizedBox(height: 16.0),

            Row(
              children: const [
                Expanded(flex: 2, child: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text('User', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text('Product ID', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            const Divider(),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('auditTrail')
                    .where('companyID', isEqualTo: companyID)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    print('Loading data...');
                    return const Center(child: CircularProgressIndicator());
                  }


                  if (snapshot.hasError) {
                    print('Error fetching audit trail: ${snapshot.error}');
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    print('No logs available for company: $companyID');
                    return const Center(child: Text('No audit trail logs available.'));
                  }

                  final logs = snapshot.data!.docs;
                  print('Fetched ${logs.length} logs for company: $companyID');

                  return ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index].data() as Map<String, dynamic>;
                      final timestamp = (log['timestamp'] as Timestamp).toDate();
                      final user = log['user'] ?? 'Unknown';
                      final action = log['action'] ?? 'No action';
                      final productID = log['productID'] ?? 'N/A'; 
                      final formattedTime = DateFormat('dd/MM/yyyy HH:mm:ss').format(timestamp);

                      print('Log $index - Timestamp: $formattedTime, User: $user, Action: $action, Product ID: $productID');

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: Text(formattedTime)), 
                            Expanded(flex: 1, child: Text(user)),
                            Expanded(flex: 2, child: Text(action)),
                            Expanded(flex: 1, child: Text(productID)),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
