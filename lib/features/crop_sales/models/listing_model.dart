import 'package:cloud_firestore/cloud_firestore.dart';



class ListingModel {
  final String listingId;
  final String productName;
  final String description;
  final double price;
  final int quantity;
  final String unit; 
  final String imageUrl;

  
  final String sellerId;
  final String sellerName;

  
  final bool isAvailable;
  final Timestamp createdAt;

  
  final String? buyerId;
  final String? buyerName;
  final Timestamp? purchasedAt;

  ListingModel({
    required this.listingId,
    required this.productName,
    required this.description,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.imageUrl,
    required this.sellerId,
    required this.sellerName,
    required this.isAvailable,
    required this.createdAt,
    this.buyerId,
    this.buyerName,
    this.purchasedAt,
  });

  
  factory ListingModel.fromMap(Map<String, dynamic> map) {
    return ListingModel(
      listingId: map['listingId'] ?? '',
      productName: map['productName'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 0,
      unit: map['unit'] ?? 'kg',
      imageUrl: map['imageUrl'] ?? '',
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      isAvailable: map['isAvailable'] ?? false,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      
      buyerId: map['buyerId'],
      buyerName: map['buyerName'],
      purchasedAt: map['purchasedAt'],
    );
  }

  
  Map<String, dynamic> toMap() {
    return {
      'listingId': listingId,
      'productName': productName,
      'description': description,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'imageUrl': imageUrl,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'isAvailable': isAvailable,
      'createdAt': createdAt,
      
      'buyerId': buyerId,
      'buyerName': buyerName,
      'purchasedAt': purchasedAt,
    };
  }
}