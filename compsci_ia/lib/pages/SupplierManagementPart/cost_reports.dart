import 'package:flutter/material.dart';

class CostReports extends StatefulWidget {
  const CostReports({super.key});

  @override
  _CostReportsState createState() => _CostReportsState();
}

class _CostReportsState extends State<CostReports> {
  // List to store uploaded cost reports (for simplicity, using file names)
  List<String> costReports = [];

  void addCostReport() {
    showDialog(
      context: context,
      builder: (context) {
        String newReport = '';
        return AlertDialog(
          title: const Text('Upload New Cost Report'),
          content: TextField(
            onChanged: (value) {
              newReport = value;
            },
            decoration: const InputDecoration(hintText: 'Enter report name or path'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (newReport.isNotEmpty) {
                  setState(() {
                    costReports.add(newReport);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Upload'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cost Reports'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            costReports.isEmpty
                ? const Center(child: Text('No cost reports uploaded yet'))
                : Expanded(
                    child: ListView.builder(
                      itemCount: costReports.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(costReports[index]),
                          ),
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: addCostReport,
              child: const Text('Upload Cost Report'),
            ),
          ],
        ),
      ),
    );
  }
}
