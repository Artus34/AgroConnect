import 'package:agrolink/config.dart';
import 'package:agrolink/core/models/user_model.dart';
import 'package:agrolink/features/crop_sales/controllers/sales_provider.dart';
import 'package:agrolink/features/crop_sales/models/listing_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

// A helper class to show snackbars.
class PaymentUtils {
  static void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }
}

class PaymentService {
  late Razorpay _razorpay;

  // These variables will temporarily hold the data needed to create a transaction
  // after the payment is successful.
  BuildContext? _context;
  SalesProvider? _salesProvider;
  ListingModel? _listing;
  UserModel? _buyer;
  int? _quantity;
  double? _totalPrice;

  // 1. Initialize the service
  PaymentService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // 2. Dispose the service
  void dispose() {
    _razorpay.clear(); // Removes all listeners
  }

  // 3. Open the checkout
  void openCheckout({
    required BuildContext context,
    required ListingModel listing,
    required UserModel buyer,
    required int quantity,
    required double totalPrice,
  }) {
    // Store all the necessary data in member variables
    _context = context;
    _listing = listing;
    _buyer = buyer;
    _quantity = quantity;
    _totalPrice = totalPrice;
    // Get the SalesProvider from the context
    _salesProvider = context.read<SalesProvider>();

    // --- Create Payment Options ---

    // Razorpay requires the amount in the smallest currency unit (paise)
    // 1600.0 * 100 = 160000
    int amountInPaise = (totalPrice * 100).round();

    var options = {
      'key': Config.razorpayTestKey,
      'amount': amountInPaise,
      'name': 'AgroLink',
      'description': 'Payment for ${listing.productName}',
      'prefill': {
        // We'll assume your UserModel has 'email' and 'phone' fields
        'email': buyer.email, // Use the buyer's email
      },
      'notes': {
        'listingId': listing.listingId,
        'buyerId': buyer.uid,
        'sellerId': listing.sellerId,
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Error opening Razorpay: $e");
      if (_context != null) {
        PaymentUtils.showSnackBar(_context!, "Error: ${e.toString()}",
            isError: true);
      }
    }
  }

  // --- Event Handlers ---

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (_context == null ||
        _salesProvider == null ||
        _listing == null ||
        _buyer == null ||
        _quantity == null ||
        _totalPrice == null) {
      // This should not happen if openCheckout was called correctly
      debugPrint("Error: Payment context is lost.");
      return;
    }

    PaymentUtils.showSnackBar(_context!, "Payment Successful!");

    // Call the SalesProvider to create the real transaction in Firebase
    _salesProvider!.createTransaction(
      listing: _listing!,
      buyer: _buyer!,
      quantityPurchased: _quantity!,
      totalPrice: _totalPrice!,
      paymentId: response.paymentId ?? '',
      orderId: response.orderId ?? '',
    );

    // Optional: Navigate to the transaction history or a success screen
    // Navigator.of(_context!).pop(); // Go back from the listing page
    // Navigator.of(_context!).push(...); // Go to transaction history
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Show an error message to the user
    if (_context != null) {
      String msg = "Payment Failed: ${response.message}";
      PaymentUtils.showSnackBar(_context!, msg, isError: true);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // You can just log this, or show a processing message
    debugPrint("External Wallet Selected: ${response.walletName}");
  }
}