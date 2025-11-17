import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/models/user_model.dart'; // --- IMPORT ADDED ---
import '../../../core/services/payment_service.dart'; // --- IMPORT ADDED ---
import '../../auth/controllers/auth_provider.dart';
import '../controllers/sales_provider.dart';
import '../models/listing_model.dart';

class ViewListingScreen extends StatefulWidget {
  final ListingModel listing;
  const ViewListingScreen({super.key, required this.listing});

  @override
  State<ViewListingScreen> createState() => _ViewListingScreenState();
}

class _ViewListingScreenState extends State<ViewListingScreen> {
  int _selectedQuantity = 1;

  // --- PAYMENT SERVICE INITIALIZATION ---
  late PaymentService _paymentService;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService();
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }
  // --- END OF PAYMENT SERVICE INITIALIZATION ---

  // --- UPDATED LOGIC TO CALL RAZORPAY ---
  Future<void> _buyNow(BuildContext context) async {
    // 1. Validate quantity
    if (_selectedQuantity <= 0 || _selectedQuantity > widget.listing.quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a valid quantity.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 2. Get the buyer's information
    final authProvider = context.read<AuthProvider>();
    final UserModel? buyer = authProvider.userModel;

    if (buyer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to make a purchase.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 3. Calculate total price
    final double totalPrice = widget.listing.price * _selectedQuantity;

    // 4. Call the PaymentService to open the Razorpay checkout
    // This replaces your old 'salesProvider.purchaseItem' call
    _paymentService.openCheckout(
      context: context,
      listing: widget.listing,
      buyer: buyer,
      quantity: _selectedQuantity,
      totalPrice: totalPrice,
    );

    // We remove the old success/error logic from here.
    // The PaymentService's listeners (_handlePaymentSuccess, _handlePaymentError)
    // will automatically handle showing snackbars and saving the transaction.
  }
  // --- END OF UPDATED LOGIC ---

  Widget _buildQuantitySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Quantity to Buy:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            width: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildQuantityButton(
                  icon: Icons.remove,
                  onPressed: _selectedQuantity > 1
                      ? () {
                          setState(() {
                            _selectedQuantity--;
                          });
                        }
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    '$_selectedQuantity',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildQuantityButton(
                  icon: Icons.add,
                  onPressed: _selectedQuantity < widget.listing.quantity
                      ? () {
                          setState(() {
                            _selectedQuantity++;
                          });
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({required IconData icon, VoidCallback? onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: onPressed != null
            ? AppColors.primaryGreen.withOpacity(0.1)
            : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon),
        color: onPressed != null ? AppColors.primaryGreen : Colors.grey.shade600,
        onPressed: onPressed,
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.all(4.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.userModel?.uid;
    final bool isMyListing = widget.listing.sellerId == currentUserId;

    if (_selectedQuantity > widget.listing.quantity) {
      _selectedQuantity =
          widget.listing.quantity > 0 ? widget.listing.quantity : 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listing.productName),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'listing_image_${widget.listing.listingId}',
              child: Image.network(
                widget.listing.imageUrl,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 300,
                  color: Colors.grey[200],
                  child: const Center(
                      child: Icon(Icons.image_not_supported,
                          size: 80, color: Colors.grey)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.listing.productName,
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unit Price: ₹${widget.listing.price.toStringAsFixed(2)} / ${widget.listing.unit}',
                    style: const TextStyle(
                        fontSize: 22,
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Available Quantity: ${widget.listing.quantity} ${widget.listing.unit}',
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.listing.quantity > 0
                          ? Colors.black54
                          : Colors.red,
                      fontWeight: widget.listing.quantity > 0
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  if (!isMyListing && widget.listing.isAvailable)
                    _buildQuantitySelector(),
                  if (!isMyListing && widget.listing.isAvailable)
                    const Divider(),
                  if (!isMyListing && widget.listing.isAvailable)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Total Price: ₹${(widget.listing.price * _selectedQuantity).toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen),
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.listing.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Seller Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(widget.listing.sellerName),
                    subtitle: Text(
                        'Posted on: ${DateFormat('dd MMM, yyyy').format(widget.listing.createdAt.toDate())}'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, isMyListing),
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isMyListing) {
    bool canPurchase = widget.listing.isAvailable &&
        !isMyListing &&
        widget.listing.quantity > 0;

    String buttonText = 'Buy Now';
    VoidCallback? onPressedAction = canPurchase ? () => _buyNow(context) : null;

    if (!widget.listing.isAvailable || widget.listing.quantity <= 0) {
      buttonText = 'Sold Out';
      onPressedAction = null;
    } else if (isMyListing) {
      buttonText = 'This is your listing';
      onPressedAction = null;
    }

    return Container(
      padding: const EdgeInsets.all(16.0)
          .copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Consumer<SalesProvider>(
        builder: (context, provider, child) {
          return provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: onPressedAction,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    backgroundColor: onPressedAction == null
                        ? Colors.grey
                        : AppColors.primaryGreen,
                  ),
                  child: Text(buttonText),
                );
        },
      ),
    );
  }
}