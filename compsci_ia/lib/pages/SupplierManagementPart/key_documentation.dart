import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:path/path.dart';

class KeyDocumentation extends StatefulWidget {
  const KeyDocumentation({super.key});

  @override
  _KeyDocumentationState createState() => _KeyDocumentationState();
}

class _KeyDocumentationState extends State<KeyDocumentation> {
  // List to store uploaded PDFs with associated supplierIDs
  List<Map<String, String>> pdfFiles = [];

  Future<void> addPdf(BuildContext context) async {
    // Pick the PDF file using file_picker
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    
    if (result != null) {
      // Get the file from the result
      File file = File(result.files.single.path!);
      String fileName = basename(file.path);
      
      String supplierID = '';
      
      // Show dialog to get supplier ID
      showDialog(
        context: context,  // Pass context to the dialog
        builder: (context) {
          return AlertDialog(
            title: const Text('Upload New PDF'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    supplierID = value;
                  },
                  decoration: const InputDecoration(hintText: 'Enter Supplier ID'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (supplierID.isNotEmpty) {
                    try {
                      // Upload the file to Firebase Storage
                      final storageRef = FirebaseStorage.instance.ref().child('pdfs/$fileName');
                      await storageRef.putFile(file);

                      // Get the download URL of the uploaded PDF
                      String downloadUrl = await storageRef.getDownloadURL();

                      // Add the PDF to Firestore with supplier ID and download URL
                      await FirebaseFirestore.instance.collection('pdfs').add({
                        'pdfName': fileName,
                        'supplierID': supplierID,
                        'downloadUrl': downloadUrl,
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                      // Update the UI with the new PDF details
                      setState(() {
                        pdfFiles.add({
                          'pdfName': fileName,
                          'supplierID': supplierID,
                          'downloadUrl': downloadUrl,
                        });
                      });

                      Navigator.pop(context); // Close dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PDF uploaded successfully!')),
                      );
                    } catch (e) {
                      print('Error uploading PDF: $e');
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error uploading PDF: $e')),
                      );
                    }
                  } else {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Supplier ID is required')),
                    );
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Key Documentation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            pdfFiles.isEmpty
                ? const Center(child: Text('No PDFs uploaded yet'))
                : Expanded(
                    child: ListView.builder(
                      itemCount: pdfFiles.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(pdfFiles[index]['pdfName'] ?? ''),
                            subtitle: Text('Supplier ID: ${pdfFiles[index]['supplierID']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.download),
                              onPressed: () async {
                                String url = pdfFiles[index]['downloadUrl']!;
                                // You can now use the URL to open the PDF, for example, using url_launcher or a webview
                                print('Download URL: $url');
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => addPdf(context),  // Pass context to addPdf method
              child: const Text('Upload PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
