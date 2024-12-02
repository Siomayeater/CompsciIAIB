import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

class CostReports extends StatefulWidget {
  const CostReports({super.key});

  @override
  _CostReportsState createState() => _CostReportsState();
}

class _CostReportsState extends State<CostReports> {
  // List to store uploaded cost reports with their URLs (allow dynamic types)
  List<Map<String, dynamic>> costReports = [];

  late FirebaseStorage _storage;
  late FirebaseFirestore _firestore;

  @override
  void initState() {
    super.initState();
    _storage = FirebaseStorage.instance;
    _firestore = FirebaseFirestore.instance;
    _fetchCostReports();
  }

  // Fetch the list of cost reports from Firestore
  Future<void> _fetchCostReports() async {
    try {
      final snapshot = await _firestore.collection('costReports').get();
      final reports = snapshot.docs.map((doc) {
        // Ensure 'name' and 'url' fields exist and are of type String
        return {
          'name': doc['name'] ?? 'Unnamed Report', // Default to 'Unnamed Report' if field is missing
          'url': doc['url'] ?? '', // Default to an empty string if field is missing
        };
      }).toList();

      setState(() {
        costReports = reports; // Now costReports can accept dynamic types
      });
    } catch (e) {
      print('Error fetching cost reports: $e');
    }
  }

  // Function to pick and upload a cost report (PDF)
  Future<void> _uploadCostReport() async {
    // Pick a PDF file from the device
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      // Get the selected file
      var file = result.files.single;

      // Create a reference to Firebase Storage
      String fileName = file.name;
      Reference storageReference = _storage.ref().child('cost_reports/$fileName');

      try {
        // Upload the file to Firebase Storage
        await storageReference.putData(file.bytes!);

        // Get the file's download URL
        String downloadUrl = await storageReference.getDownloadURL();

        // Store the URL and name in Firestore
        await _firestore.collection('costReports').add({
          'name': fileName,
          'url': downloadUrl,
          'timestamp': FieldValue.serverTimestamp(),
        });

        setState(() {
          costReports.add({'name': fileName, 'url': downloadUrl});
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF uploaded successfully!')),
        );
      } catch (e) {
        // Handle errors during upload
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading PDF: $e')),
        );
      }
    } else {
      // User canceled the picker
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected')),
      );
    }
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
                            title: Text(costReports[index]['name'] ?? 'Unnamed Report'),
                            subtitle: Text('Click to download'),
                            onTap: () {
                              // Optionally, you can add functionality to open the PDF when tapped
                            },
                          ),
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadCostReport,
              child: const Text('Upload Cost Report'),
            ),
          ],
        ),
      ),
    );
  }
}
