import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String transactionId;
  final String listingId;
  final String productName;
  final String imageUrl;

  final String unit;

  final int quantityPurchased;

  final double unitPrice;

  final double totalPrice;

  final String sellerId;
  final String sellerName;
  final String buyerId;
  final String buyerName;

  final Timestamp timestamp;

  // --- FIELDS ADDED FOR RAZORPAY ---
  final String paymentId;
  final String orderId;
  final String paymentStatus;

  TransactionModel({
    required this.transactionId,
    required this.listingId,
    required this.productName,
    required this.imageUrl,
    required this.unit,
    required this.quantityPurchased,
    required this.unitPrice,
    required this.totalPrice,
    required this.sellerId,
    required this.sellerName,
    required this.buyerId,
    required this.buyerName,
    required this.timestamp,
    
    // --- FIELDS ADDED FOR RAZORPAY ---
    required this.paymentId,
    required this.orderId,
    required this.paymentStatus,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    double safeParseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return TransactionModel(
      transactionId: map['transactionId'] ?? '',
      listingId: map['listingId'] ?? '',
      productName: map['productName'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      unit: map['unit'] ?? 'units',
      quantityPurchased: map['quantityPurchased'] ?? 0,
      unitPrice: safeParseDouble(map['unitPrice'] ?? 0.0),
      totalPrice: safeParseDouble(map['totalPrice'] ?? 0.0),
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      buyerId: map['buyerId'] ?? '',
      buyerName: map['buyerName'] ?? '',
      timestamp: map['timestamp'] ?? Timestamp.now(),
      
      // --- FIELDS ADDED FOR RAZORPAY ---
      // We add default empty strings for safety, just like your other fields.
      paymentId: map['paymentId'] ?? '',
      orderId: map['orderId'] ?? '',
      paymentStatus: map['paymentStatus'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'listingId': listingId,
      'productName': productName,
      'imageUrl': imageUrl,
      'unit': unit,
      'quantityPurchased': quantityPurchased,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'timestamp': timestamp,
      
      // --- FIELDS ADDED FOR RAZORPAY ---
      'paymentId': paymentId,
      'orderId': orderId,
      'paymentStatus': paymentStatus,
    };
  }
}