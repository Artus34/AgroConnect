class PriceData {
  final String stateName;
  final String districtName;
  final String marketName;
  final String commodityName;
  final int minPrice;
  final int maxPrice;
  final int modalPrice;

  PriceData({
    required this.stateName,
    required this.districtName,
    required this.marketName,
    required this.commodityName,
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
  });

  factory PriceData.fromJson(Map<String, dynamic> json) {
    return PriceData(
      stateName: json['State'] as String,
      districtName: json['District'] as String,
      marketName: json['Market'] as String,
      commodityName: json['Commodity'] as String,
      
      minPrice: (json['Min Price'] as num).toInt(),
      maxPrice: (json['Max Price'] as num).toInt(),
      modalPrice: (json['Modal Price'] as num).toInt(), 
    );
  }
}