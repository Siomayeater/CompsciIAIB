import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuditTrailPage extends StatelessWidget {
  final String companyID;

  const AuditTrailPage({super.key, required this.companyID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audit Trail')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('auditTrail')
            .where('companyID', isEqualTo: companyID)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // Print the status of the snapshot for debugging
          if (!snapshot.hasData) {
            print("Loading... No data yet.");
            return const Center(child: CircularProgressIndicator());
          }

          // Handle errors if any
          if (snapshot.hasError) {
            print("Error: ${snapshot.error}");
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final logs = snapshot.data!.docs;

          // Debug: Check the snapshot data
          print("Fetched logs: ${logs.length}");

          if (logs.isEmpty) {
            print("No logs found.");
            return const Center(child: Text('No audit trail logs available.'));
          }

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index].data() as Map<String, dynamic>;

              // Debugging: Check the log data
              print("Log data: ${log}");

              return ListTile(
                title: Text('Action: ${log['action']}'),
                subtitle: Text('Product: ${log['productName']}'),
                trailing: Text(log['timestamp'].toDate().toString()),
              );
            },
          );
        },
      ),
    );
  }
}
