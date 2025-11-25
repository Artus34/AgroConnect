import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/payment_service.dart';
import '../controllers/sales_provider.dart';
import '../models/listing_model.dart';

class AddressInputScreen extends StatefulWidget {
  final ListingModel listing;
  final UserModel buyer;
  final int quantity;
  final double totalPrice;

  const AddressInputScreen({
    super.key,
    required this.listing,
    required this.buyer,
    required this.quantity,
    required this.totalPrice,
  });

  @override
  State<AddressInputScreen> createState() => _AddressInputScreenState();
}

class _AddressInputScreenState extends State<AddressInputScreen> {
  // Form Key for validation
  final _formKey = GlobalKey<FormState>();

  // Text Controllers for input fields
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  late PaymentService _paymentService;

  @override
  void initState() {
    super.initState();
    // Initialize Payment Service
    _paymentService = PaymentService();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _paymentService.dispose();
    super.dispose();
  }

  // --- Core Logic: Initiate Payment ---
  void _proceedToPayment() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, get the data
      final String shippingAddress = _addressController.text.trim();
      final String city = _cityController.text.trim();
      final String state = _stateController.text.trim();
      final String postalCode = _postalCodeController.text.trim();

      // Launch the payment gateway with all details, including address
      _paymentService.openCheckout(
        context: context,
        listing: widget.listing,
        buyer: widget.buyer,
        quantity: widget.quantity,
        totalPrice: widget.totalPrice,
        shippingAddress: shippingAddress,
        city: city,
        state: state,
        postalCode: postalCode,
      );
    }
  }

  // --- Reusable Text Input Widget ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        validator: validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the $labelText';
              }
              return null;
            },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to SalesProvider to show loading state if transaction is being processed
    final salesProvider = context.watch<SalesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Shipping Address'),
      ),
      body: salesProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product: ${widget.listing.productName}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      'Total: ₹${widget.totalPrice.toStringAsFixed(2)} for ${widget.quantity} ${widget.listing.unit}',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: AppColors.primaryGreen),
                    ),
                    const Divider(height: 32),

                    // Full Address Field
                    _buildTextField(
                      controller: _addressController,
                      labelText: 'Full Street Address',
                      maxLines: 3,
                    ),

                    // City Field
                    _buildTextField(
                      controller: _cityController,
                      labelText: 'City / District',
                    ),

                    // State Field
                    _buildTextField(
                      controller: _stateController,
                      labelText: 'State',
                    ),

                    // Postal Code Field
                    _buildTextField(
                      controller: _postalCodeController,
                      labelText: 'Postal Code (Pincode)',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the postal code';
                        }
                        // Basic Pincode validation (e.g., 6 digits for India)
                        if (value.length < 5) {
                          return 'Postal code must be at least 5 digits.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Proceed Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.payment),
                        label: const Text('Proceed to Payment'),
                        onPressed: _proceedToPayment,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.primaryGreen,
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}