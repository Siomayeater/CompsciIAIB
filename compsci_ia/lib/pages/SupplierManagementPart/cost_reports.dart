import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';  // Import url_launcher for opening URLs

class CostReports extends StatefulWidget {
  const CostReports({super.key});

  @override
  _CostReportsState createState() => _CostReportsState();
}

class _CostReportsState extends State<CostReports> {
  // List to store uploaded cost reports with their URLs
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
        var data = doc.data();  // Fetch document data

        // Debug log to see what data is being fetched
        print("Fetched document data: $data");

        return {
          'name': data['name'] ?? 'Unnamed Report',  // Default if the 'name' field is missing
          'url': data['url'] ?? '',  // Default if the 'url' field is missing
          'description': data['description'] ?? 'No description provided',  // Default if 'description' field is missing
        };
      }).toList();

      setState(() {
        costReports = reports;
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
      var file = result.files.single;
      String fileName = file.name;

      // Create a reference to Firebase Storage
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
          'description': 'Description for $fileName',  // Example description, you can modify this
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

  // Function to open the document URL in the browser or PDF viewer
  void launchURL(String url) async {
    final Uri uri = Uri.parse(url);  // Convert the string URL to a Uri object
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);  // Launch the URL
    } else {
      throw 'Could not launch $url';  // Error handling if the URL cannot be launched
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
                              // Launch the URL to open the PDF
                              launchURL(costReports[index]['url']);
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
