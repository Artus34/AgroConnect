import 'package:cloud_firestore/cloud_firestore.dart';

class CropCycleModel {
  final String cycleId;
  final String userId; // <<< RENAMED FROM farmerId
  final String plantType;
  final String displayName;
  final Timestamp plantingDate;
  final String status;
  final List<Map<String, dynamic>> planProgress;

  CropCycleModel({
    required this.cycleId,
    required this.userId, // <<< RENAMED FROM farmerId
    required this.plantType,
    required this.displayName,
    required this.plantingDate,
    required this.status,
    required this.planProgress,
  });

  // --- fromMap ---
  factory CropCycleModel.fromMap(Map<String, dynamic> map) {
    return CropCycleModel(
      cycleId: map['cycleId'] ?? '',
      userId: map['userId'] ?? '', // <<< RENAMED FROM farmerId
      plantType: map['plantType'] ?? '',
      displayName: map['displayName'] ?? '',
      plantingDate: map['plantingDate'] ?? Timestamp.now(),
      status: map['status'] ?? 'Unknown',
      planProgress: map['planProgress'] != null
          ? List<Map<String, dynamic>>.from(map['planProgress'])
          : [],
    );
  }

  // --- toMap ---
  Map<String, dynamic> toMap() {
    return {
      'cycleId': cycleId,
      'userId': userId, // <<< RENAMED FROM farmerId
      'plantType': plantType,
      'displayName': displayName,
      'plantingDate': plantingDate,
      'status': status,
      'planProgress': planProgress,
    };
  }
}

