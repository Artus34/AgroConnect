import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';

class FarmerProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<UserModel> _farmers = [];
  bool _isLoading = false;
  String? _errorMessage;

  // --- Getter is named 'farmers' ---
  List<UserModel> get farmers => _farmers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;


  Future<void> fetchTopFarmers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'farmer')
          // --- CHANGED LIMIT FROM 10 to 5 ---
          .limit(5)
          // --- END CHANGE ---
          .get();

      _farmers = snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      if (_farmers.isEmpty) {
        _errorMessage = "No farmers found.";
      }

    } on FirebaseException catch (e) {
      _errorMessage = "Failed to load farmers: ${e.message}";
      _farmers = [];
    } catch (e) {
      _errorMessage = "An unexpected error occurred.";
      _farmers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}