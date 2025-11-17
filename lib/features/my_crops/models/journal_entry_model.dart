import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntryModel {
  final String entryId;
  final String cycleId; // Links to the CropCycleModel
  final Timestamp date;
  final String notes;
  final String? imageUrl; // Optional image URL

  JournalEntryModel({
    required this.entryId,
    required this.cycleId,
    required this.date,
    required this.notes,
    this.imageUrl,
  });

  /// Converts this [JournalEntryModel] object to a [Map] for Firebase.
  Map<String, dynamic> toMap() {
    return {
      'entryId': entryId,
      'cycleId': cycleId,
      'date': date,
      'notes': notes,
      'imageUrl': imageUrl,
    };
  }

  /// Creates a [JournalEntryModel] object from a Firebase [Map].
  factory JournalEntryModel.fromMap(Map<String, dynamic> map) {
    return JournalEntryModel(
      entryId: map['entryId'] ?? '',
      cycleId: map['cycleId'] ?? '',
      date: map['date'] ?? Timestamp.now(),
      notes: map['notes'] ?? '',
      imageUrl: map['imageUrl'], // This can be null, so no '??'
    );
  }
}
