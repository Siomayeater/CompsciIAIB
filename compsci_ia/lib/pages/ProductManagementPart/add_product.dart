import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddProduct extends StatefulWidget {
  final String companyID;

  const AddProduct({super.key, required this.companyID});

  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _priceSupplierController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();

  List<String> supplierIds = [];
  List<String> supplierNames = [];
  String? selectedSupplierID;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
  }

  Future<void> _fetchSuppliers() async {
    setState(() {
      isLoading = true;
    });
    try {
      final snapshot = await FirebaseFirestore.instance.collection('suppliers').get();
      setState(() {
        supplierIds = snapshot.docs.map((doc) => doc.id).toList();
        supplierNames = snapshot.docs.map((doc) => doc.data()['supplierName'] as String? ?? 'Unknown').toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching suppliers: $e');
    }
  }

  void addProduct() async {
    if (_nameController.text.isEmpty || _descController.text.isEmpty || selectedSupplierID == null || _locationController.text.isEmpty || _sizeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    try {
      // Add product to the company's products collection
      final productRef = await FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.companyID)
          .collection('products')
          .add({
        'productName': _nameController.text,
        'productDesc': _descController.text,
        'productPrice': double.tryParse(_priceController.text) ?? 0.0,
        'productPriceSupplier': double.tryParse(_priceSupplierController.text) ?? 0.0,
        'supplierID': selectedSupplierID,
        'location': _locationController.text,
        'size': _sizeController.text,
      });

      // Check if product exists in quantityproducts collection and update or add
      final quantityProductRef = FirebaseFirestore.instance.collection('quantityproducts');
      final querySnapshot = await quantityProductRef
          .where('companyID', isEqualTo: widget.companyID)
          .where('productName', isEqualTo: _nameController.text)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Product exists, update quantity
        final doc = querySnapshot.docs.first;
        final currentQuantity = (doc.data()['quantity'] ?? 0) as int;
        await doc.reference.update({'quantity': currentQuantity + 1});
      } else {
        // Product does not exist, create a new entry with quantity 1
        await quantityProductRef.add({
          'companyID': widget.companyID,
          'productName': _nameController.text,
          'quantity': 1,
        });
      }

      // Log action in audit trail
      await FirebaseFirestore.instance.collection('auditTrail').add({
        'action': 'add',
        'productID': productRef.id,
        'timestamp': FieldValue.serverTimestamp(),
        'companyID': widget.companyID,
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding product: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            isLoading
                ? const CircularProgressIndicator()
                : DropdownButton<String>(
                    value: selectedSupplierID,
                    hint: const Text('Select Supplier'),
                    onChanged: (newValue) {
                      setState(() {
                        selectedSupplierID = newValue;
                      });
                    },
                    items: supplierIds.map((supplierID) {
                      final supplierName = supplierNames[supplierIds.indexOf(supplierID)];
                      return DropdownMenuItem<String>(
                        value: supplierID,
                        child: Text(supplierName),
                      );
                    }).toList(),
                  ),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Product Name')),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Product Description')),
            TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'Product Price'), keyboardType: TextInputType.number),
            TextField(controller: _priceSupplierController, decoration: const InputDecoration(labelText: 'Supplier Price'), keyboardType: TextInputType.number),
            TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Location')),
            TextField(controller: _sizeController, decoration: const InputDecoration(labelText: 'Size')),
            const SizedBox(height: 16.0),
            ElevatedButton(onPressed: isLoading ? null : addProduct, child: const Text('Add Product')),
          ],
        ),
      ),
    );
  }
}

