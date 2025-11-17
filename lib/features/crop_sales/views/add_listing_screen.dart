import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/image_service.dart';
import '../controllers/sales_provider.dart';


class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imageService = ImageService();

  
  static const List<String> _quantityUnits = [
    'kg', 
    'pound', 
    'ton', 
    'quintal', 
    'dozen', 
    'piece',
    'bunch',
  ];

  
  final _productNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  
  

  
  Uint8List? _selectedImageBytes;
  
  
  String? _selectedUnit = _quantityUnits.first; 

  @override
  void dispose() {
    _productNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    
    super.dispose();
  }

  
  Future<void> _pickImage() async {
    final imageBytes = await _imageService.pickImage();
    if (imageBytes != null) {
      setState(() {
        _selectedImageBytes = imageBytes;
      });
    }
  }

  
  Future<void> _submitListing() async {
    FocusScope.of(context).unfocus();
    final isFormValid = _formKey.currentState?.validate() ?? false;
    
    
    if (_selectedUnit == null || _selectedUnit!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a unit of quantity.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
    }
    
    if (!isFormValid) return;

    if (_selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image for your product.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final salesProvider = context.read<SalesProvider>();

    final success = await salesProvider.createListing(
      productName: _productNameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0.0,
      quantity: int.tryParse(_quantityController.text.trim()) ?? 0,
      
      
      unit: _selectedUnit!, 
      
      imageBytes: _selectedImageBytes!,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listing posted successfully!'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(salesProvider.errorMessage ?? 'An unknown error occurred.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Listing'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImagePicker(),
              const SizedBox(height: 24),
              TextFormField(
                controller: _productNameController,
                decoration: const InputDecoration(labelText: 'Product Name', hintText: 'e.g., Organic Tomatoes'),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter a product name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description', hintText: 'e.g., Freshly harvested from our farm...'),
                maxLines: 3,
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price per Unit', prefixText: '₹ '), 
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        if (double.tryParse(value) == null || double.parse(value) <= 0) return 'Invalid price';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: 'Total Quantity'), 
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        if (int.tryParse(value) == null || int.parse(value) <= 0) return 'Invalid number';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Unit of Quantity',
                  border: OutlineInputBorder(),
                ),
                value: _selectedUnit,
                items: _quantityUnits.map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedUnit = newValue;
                  });
                },
                validator: (value) => (value == null || value.isEmpty) ? 'Please select a unit' : null,
              ),
              
              
              const SizedBox(height: 32),
              Consumer<SalesProvider>(
                builder: (context, provider, child) {
                  return provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _submitListing,
                          child: const Text('Post Listing'),
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[400]!),
            image: _selectedImageBytes != null
                ? DecorationImage(
                    image: MemoryImage(_selectedImageBytes!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: _selectedImageBytes == null
              ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Tap to select an image'),
                    ],
                  )
              : null,
        ),
      ),
    );
  }
}