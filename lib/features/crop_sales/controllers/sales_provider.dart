import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/image_service.dart';
import '../../auth/controllers/auth_provider.dart';
import '../models/listing_model.dart';
import '../models/transaction_model.dart';

class SalesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImageService _imageService = ImageService();
  final Uuid _uuid = const Uuid();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  List<ListingModel> _allListings = [];
  List<ListingModel> _myListings = [];
  List<TransactionModel> _myTransactions = [];

  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ListingModel> get allListings => _allListings;
  List<ListingModel> get myListings => _myListings;
  List<TransactionModel> get myTransactions => _myTransactions;

  List<ListingModel> get filteredListings {
    if (_searchQuery.isEmpty) {
      return _allListings;
    } else {
      return _allListings.where((listing) {
        return listing.productName
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  void update(AuthProvider authProvider) {
    _currentUser = authProvider.userModel;
  }

  void updateSearchQuery(String newQuery) {
    _searchQuery = newQuery;
    notifyListeners();
  }

  Future<bool> createListing({
    required String productName,
    required String description,
    required double price,
    required int quantity,
    required String unit,
    required Uint8List imageBytes,
  }) async {
    if (_currentUser == null) {
      _setError("You must be logged in to create a listing.");
      return false;
    }
    _setLoading(true);

    try {
      final String fileName =
          "${_currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}";

      final String? imageUrl = await _imageService.uploadImage(
        imageBytes: imageBytes,
        fileName: fileName,
        folderPath: '/agrolink_listings',
      );

      if (imageUrl == null) {
        throw Exception("Image upload failed. Please try again.");
      }

      final String listingId = _uuid.v4();
      final newListing = ListingModel(
        listingId: listingId,
        productName: productName,
        description: description,
        price: price,
        quantity: quantity,
        unit: unit,
        imageUrl: imageUrl,
        sellerId: _currentUser!.uid,
        sellerName: _currentUser!.name,
        isAvailable: true,
        createdAt: Timestamp.now(),
      );

      await _firestore
          .collection('listings')
          .doc(listingId)
          .set(newListing.toMap());
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> fetchAllListings() async {
    _setLoading(true);
    try {
      final snapshot = await _firestore
          .collection('listings')
          .where('isAvailable', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      _allListings =
          snapshot.docs.map((doc) => ListingModel.fromMap(doc.data())).toList();
    } catch (e) {
      _setError("Failed to fetch listings.");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMyListings() async {
    if (_currentUser == null) {
      _setError("You must be logged in to see your listings.");
      return;
    }
    _setLoading(true);
    try {
      final snapshot = await _firestore
          .collection('listings')
          .where('sellerId', isEqualTo: _currentUser!.uid)
          .orderBy('createdAt', descending: true)
          .get();

      _myListings =
          snapshot.docs.map((doc) => ListingModel.fromMap(doc.data())).toList();
    } catch (e) {
      _setError("Failed to fetch your listings.");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMyTransactions() async {
    if (_currentUser == null) {
      _setError("You must be logged in to see your transaction history.");
      return;
    }
    _setLoading(true);
    try {
      final salesSnapshot = await _firestore
          .collection('transactions')
          .where('sellerId', isEqualTo: _currentUser!.uid)
          .orderBy('timestamp', descending: true)
          .get();
      final purchasesSnapshot = await _firestore
          .collection('transactions')
          .where('buyerId', isEqualTo: _currentUser!.uid)
          .orderBy('timestamp', descending: true)
          .get();

      final List<TransactionModel> transactions = [];
      transactions.addAll(salesSnapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.data())));
      transactions.addAll(purchasesSnapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.data())));

      transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      _myTransactions = transactions;
    } catch (e) {
      _setError("Failed to fetch transaction history.");
    } finally {
      _setLoading(false);
    }
  }

  // --- THIS IS YOUR OLD DUMMY PURCHASE METHOD ---
  Future<bool> purchaseItem(ListingModel listing, int quantityToBuy) async {
    if (_currentUser == null) {
      _setError("You must be logged in to purchase an item.");
      return false;
    }
    if (listing.sellerId == _currentUser!.uid) {
      _setError("You cannot purchase your own item.");
      return false;
    }

    if (quantityToBuy <= 0) {
      _setError("Quantity must be greater than zero.");
      return false;
    }
    if (quantityToBuy > listing.quantity) {
      _setError(
          "Requested quantity exceeds available stock of ${listing.quantity} ${listing.unit}.");
      return false;
    }

    _setLoading(true);
    try {
      final WriteBatch batch = _firestore.batch();
      final Timestamp purchaseTimestamp = Timestamp.now();
      final listingRef =
          _firestore.collection('listings').doc(listing.listingId);

      final int newRemainingQuantity = listing.quantity - quantityToBuy;
      final bool newIsAvailable = newRemainingQuantity > 0;

      final double unitPrice = listing.price;
      final double totalPrice = unitPrice * quantityToBuy;

      batch.update(listingRef, {
        'quantity': newRemainingQuantity,
        'isAvailable': newIsAvailable,
        'buyerId': _currentUser!.uid,
        'buyerName': _currentUser!.name,
        'purchasedAt': purchaseTimestamp,
      });

      final transactionId = _uuid.v4();
      final transaction = TransactionModel(
        transactionId: transactionId,
        listingId: listing.listingId,
        productName: listing.productName,
        imageUrl: listing.imageUrl,
        unit: listing.unit,
        quantityPurchased: quantityToBuy,
        unitPrice: unitPrice,
        totalPrice: totalPrice,
        sellerId: listing.sellerId,
        sellerName: listing.sellerName,
        buyerId: _currentUser!.uid,
        buyerName: _currentUser!.name,
        timestamp: purchaseTimestamp,
        
        // --- NOTE: These fields are missing in your old model ---
        paymentId: 'dummy_payment', // Dummy data
        orderId: 'dummy_order', // Dummy data
        paymentStatus: 'dummy', // Dummy data
      );

      final topLevelTransactionRef =
          _firestore.collection('transactions').doc(transactionId);
      batch.set(topLevelTransactionRef, transaction.toMap());

      await batch.commit();

      _setLoading(false);

      fetchAllListings();
      if (listing.sellerId == _currentUser!.uid) {
        fetchMyListings();
      } else {
        fetchMyTransactions();
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Purchase Error Details: $e");
      }
      _setError("Purchase failed. Please try again.");
      _setLoading(false);
      return false;
    }
  }

  // --- THIS IS THE NEW METHOD CALLED BY PaymentService ---
  Future<void> createTransaction({
    required ListingModel listing,
    required UserModel buyer,
    required int quantityPurchased,
    required double totalPrice,
    required String paymentId,
    required String orderId,
  }) async {
    // Check for self-purchase, which shouldn't be allowed
    if (listing.sellerId == buyer.uid) {
      _setError("You cannot purchase your own item.");
      // In a real app, you would auto-trigger a refund here.
      // For now, we just stop and log an error.
      print(
          "CRITICAL: Payment processed for self-purchase. Needs manual refund. PaymentID: $paymentId");
      return;
    }

    _setLoading(true);

    try {
      final listingRef = _firestore.collection('listings').doc(listing.listingId);
      final transactionId = _uuid.v4();
      final transactionRef =
          _firestore.collection('transactions').doc(transactionId);
      final Timestamp purchaseTimestamp = Timestamp.now();

      // We use a Firestore Transaction to safely read and then write.
      // This prevents you from selling stock you don't have (race condition).
      await _firestore.runTransaction((firestoreTransaction) async {
        // 1. Read the listing's current state from the database
        final listingSnapshot = await firestoreTransaction.get(listingRef);

        if (!listingSnapshot.exists) {
          throw Exception("This listing no longer exists.");
        }

        final int currentStock = listingSnapshot.get('quantity') as int;

        // 2. Validate if the stock is still available
        if (quantityPurchased > currentStock) {
          throw Exception(
              "Sorry, the requested quantity ($quantityPurchased) is no longer available. Current stock: $currentStock.");
        }

        // 3. Prepare the new values
        final int newRemainingQuantity = currentStock - quantityPurchased;
        final bool newIsAvailable = newRemainingQuantity > 0;

        // 4. Create the new TransactionModel with all payment details
        final newTransaction = TransactionModel(
          transactionId: transactionId,
          listingId: listing.listingId,
          productName: listing.productName,
          imageUrl: listing.imageUrl,
          unit: listing.unit,
          quantityPurchased: quantityPurchased,
          unitPrice: listing.price, // This is the correct unit price
          totalPrice: totalPrice,   // This is the calculated total
          sellerId: listing.sellerId,
          sellerName: listing.sellerName,
          buyerId: buyer.uid,
          buyerName: buyer.name,
          timestamp: purchaseTimestamp,

          // Add the new Razorpay fields
          paymentId: paymentId,
          orderId: orderId,
          paymentStatus: 'completed',
        );

        // 5. Commit the writes *within* the transaction
        // Update the listing's stock
        firestoreTransaction.update(listingRef, {
          'quantity': newRemainingQuantity,
          'isAvailable': newIsAvailable,
        });

        // Create the new transaction document
        firestoreTransaction.set(transactionRef, newTransaction.toMap());
      });

      // If the transaction succeeds:
      _setLoading(false);

      // Refresh the UI
      fetchAllListings();
      fetchMyTransactions();
      
    } catch (e) {
      if (kDebugMode) {
        print("Transaction Error Details: $e");
      }
      _setError("Transaction failed: ${e.toString()}. Please contact support.");
      // CRITICAL: In a real app, you MUST log this failure (e.g., to a
      // separate 'failed_transactions' collection in Firebase) with the
      // paymentId and orderId so you can manually verify and issue a refund.
      _setLoading(false);
    }
  }

  // --- END OF NEW METHOD ---

  Future<void> deleteListing(String listingId) async {
    _setLoading(true);
    try {
      await _firestore.collection('listings').doc(listingId).delete();

      _myListings.removeWhere((listing) => listing.listingId == listingId);
    } catch (e) {
      _setError("Failed to delete the listing. Please try again.");
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    if (kDebugMode) {
      print("SalesProvider Error: $_errorMessage");
    }
    notifyListeners();
  }
}