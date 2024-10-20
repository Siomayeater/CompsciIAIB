import 'package:flutter/material.dart';

class KeyDocumentation extends StatefulWidget {
  const KeyDocumentation({super.key});

  @override
  _KeyDocumentationState createState() => _KeyDocumentationState();
}

class _KeyDocumentationState extends State<KeyDocumentation> {
  // List to store uploaded PDFs (for simplicity, using file names)
  List<String> pdfFiles = [];

  void addPdf() {
    showDialog(
      context: context,
      builder: (context) {
        String newPdf = '';
        return AlertDialog(
          title: const Text('Upload New PDF'),
          content: TextField(
            onChanged: (value) {
              newPdf = value;
            },
            decoration: const InputDecoration(hintText: 'Enter PDF name or path'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (newPdf.isNotEmpty) {
                  setState(() {
                    pdfFiles.add(newPdf);
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
                            title: Text(pdfFiles[index]),
                          ),
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: addPdf,
              child: const Text('Upload PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
