import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetail extends StatefulWidget {
  final String productID;
  final String companyID;

  const ProductDetail({super.key, required this.productID, required this.companyID});

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  bool isEditing = false;
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _priceSupplierController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();

  List<String> supplierIds = [];
  List<String> supplierNames = [];
  String? selectedSupplierID;

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
    _loadProductDetails();
  }

  Future<void> _fetchSuppliers() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('suppliers').get();
      setState(() {
        supplierIds = snapshot.docs.map((doc) => doc.id).toList();
        supplierNames = snapshot.docs.map((doc) => doc.data()['supplierName'] as String? ?? 'Unknown').toList();
      });
    } catch (e) {
      print('Error fetching suppliers: $e');
    }
  }

  Future<void> _loadProductDetails() async {
    setState(() => isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.companyID)
          .collection('products')
          .doc(widget.productID)
          .get();
      
      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['productName'];
        _descController.text = data['productDesc'];
        _priceController.text = data['productPrice'].toString();
        _priceSupplierController.text = data['productPriceSupplier'].toString();
        _locationController.text = data['location'];
        _sizeController.text = data['size'];
        selectedSupplierID = data['supplierID'];
      }
    } catch (e) {
      print('Error loading product details: $e');
    }
    setState(() => isLoading = false);
  }

  void updateProduct() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.companyID)
          .collection('products')
          .doc(widget.productID)
          .update({
        'productName': _nameController.text,
        'productDesc': _descController.text,
        'productPrice': double.tryParse(_priceController.text) ?? 0.0,
        'productPriceSupplier': double.tryParse(_priceSupplierController.text) ?? 0.0,
        'supplierID': selectedSupplierID,
        'location': _locationController.text,
        'size': _sizeController.text,
      });
      
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product updated successfully!')));
      setState(() => isEditing = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating product: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: isEditing ? updateProduct : () => setState(() => isEditing = true),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: isEditing
                  ? Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: selectedSupplierID,
                            hint: const Text('Select Supplier'),
                            onChanged: (newValue) => setState(() => selectedSupplierID = newValue),
                            items: supplierIds.map((supplierID) {
                              final supplierName = supplierNames[supplierIds.indexOf(supplierID)];
                              return DropdownMenuItem<String>(
                                value: supplierID,
                                child: Text(supplierName),
                              );
                            }).toList(),
                          ),
                          TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Product Name'), validator: (value) => value!.isEmpty ? 'Enter product name' : null),
                          TextFormField(controller: _descController, decoration: const InputDecoration(labelText: 'Description')), 
                          TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
                          TextFormField(controller: _priceSupplierController, decoration: const InputDecoration(labelText: 'Supplier Price'), keyboardType: TextInputType.number),
                          TextFormField(controller: _locationController, decoration: const InputDecoration(labelText: 'Location')),
                          TextFormField(controller: _sizeController, decoration: const InputDecoration(labelText: 'Size')),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Product Name: ${_nameController.text}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Description: ${_descController.text}'),
                        Text('Price: \$${_priceController.text}'),
                        Text('Supplier Price: \$${_priceSupplierController.text}'),
                        Text('Supplier: ${supplierNames[supplierIds.indexOf(selectedSupplierID ?? '')] ?? 'Unknown'}'),
                        Text('Location: ${_locationController.text}'),
                        Text('Size: ${_sizeController.text}'),
                      ],
                    ),
            ),
    );
  }
}
