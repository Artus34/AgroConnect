import 'dart:typed_data';

import 'package:agrolink/core/services/image_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/user_model.dart';

/// Represents the possible states during the initial authentication check.
enum AuthState {
  unknown, // Still checking Firebase if the user is logged in
  loggedIn, // User is logged in
  loggedOut, // User is logged out
}

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImageService _imageService = ImageService();

  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  // ⭐️ ADDED: Dedicated flag for the initial asynchronous check
  bool _isCheckingInitialAuth = true; 
  
  AuthState _authState = AuthState.unknown; 

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ⭐️ ADDED GETTER: Expose the initial loading state
  bool get isCheckingInitialAuth => _isCheckingInitialAuth;

  /// Returns the current authentication state (unknown, loggedIn, loggedOut).
  AuthState get authState => _authState;

  // Constructor subscribes immediately, which is the standard best practice.
  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  /// Called whenever the Firebase Auth state changes (login, logout, initial check).
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    // 1. Determine Target State
    if (firebaseUser == null) {
      _userModel = null;
      _authState = AuthState.loggedOut;
    } else {
      // 2. Wait for Firestore data fetch to COMPLETE before updating state
      await _fetchUser(firebaseUser.uid); 
      // 3. ONLY NOW, after data is ready, set the final state.
      _authState = AuthState.loggedIn;
    }
    
    // ⭐️ FIX: Mark the initial check as complete AFTER all logic runs.
    if (_isCheckingInitialAuth) {
        _isCheckingInitialAuth = false;
    }

    // This transitions the AuthWrapper from the initial loading state to the final screen.
    notifyListeners();
  }

  /// Fetches user details from the 'users' collection in Firestore.
  Future<void> _fetchUser(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        _userModel = UserModel.fromMap(docSnapshot.data()!);
      } else {
        // Handle case where user exists in Auth but not Firestore
        _userModel = null;
        print("Warning: User $uid exists in Auth but not in Firestore 'users' collection.");
      }
    } catch (e) {
      _errorMessage = "Error fetching user data.";
      print("Error fetching user: $e");
      _userModel = null;
    }
  }

  /// Logs in a user with email and password.
  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);

    // Track the start time to enforce a minimum duration
    final startTime = DateTime.now();
    const minDelay = Duration(milliseconds: 1500); // 1.5 seconds minimum delay

    try {
      // 1. Perform the actual login operation
      await _auth.signInWithEmailAndPassword(email: email, password: password); 

      // 2. Calculate time elapsed and enforce minimum delay
      final elapsed = DateTime.now().difference(startTime);

      if (elapsed < minDelay) {
        // Wait for the remaining duration to ensure the spinner is visible
        await Future.delayed(minDelay - elapsed);
      }
      
      // 3. Set loading false and return success
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      // Also apply minimum delay on error, so the user sees the spinner before the error appears
      final elapsed = DateTime.now().difference(startTime);
      if (elapsed < minDelay) {
        await Future.delayed(minDelay - elapsed);
      }

      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      final elapsed = DateTime.now().difference(startTime);
      if (elapsed < minDelay) {
        await Future.delayed(minDelay - elapsed);
      }
      
      _setError('An unknown error occurred during login.');
      _setLoading(false);
      return false;
    }
  }

    /// Updates the user's profile image URL in ImageKit and Firestore.
  Future<bool> updateProfileImage(Uint8List imageBytes) async {
    if (_userModel == null) return false;
    _setLoading(true);

    try {
      final String uid = _userModel!.uid;
      final String role = _userModel!.role;

      // Determine folder based on role
      final String folderPath = role == 'farmer' ? '/farmer_profile' : '/user_profile';
      final String fileName = '$uid.jpg'; // Consistent file name

      // Upload image
      final String? downloadUrl = await _imageService.uploadImage(
        imageBytes: imageBytes,
        fileName: fileName,
        folderPath: folderPath,
      );

      if (downloadUrl == null) {
        _setError('Image upload failed.');
        _setLoading(false); // Make sure loading stops on failure
        return false;
      }

      // Update Firestore
      final updatedUser = _userModel!.copyWith(profileImageUrl: downloadUrl);
      await _firestore.collection('users').doc(uid).update({
        'profileImageUrl': downloadUrl,
      });

      // Update local state
      _userModel = updatedUser;
      _setLoading(false);
      notifyListeners(); // Notify UI about the updated user model
      return true;
    } catch (e) {
      _setError('Failed to update profile image.');
      print("Error updating profile image: $e");
      _setLoading(false);
      return false;
    }
  }


  /// Signs up a new user and saves their details to Firestore.
  Future<void> signup(
      {required String name, required String email, required String password, required String role}) async {
    _setLoading(true);
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final User? user = userCredential.user;
      if (user != null) {
        // Create UserModel
        final newUser = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          role: role,
          // Initialize other fields if necessary, e.g., profileImageUrl: ''
        );
        // Save to Firestore
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        // _onAuthStateChanged will automatically pick up the user and fetch their data.
      }
    } on FirebaseAuthException catch (e) {
      _setError(e.message);
      _setLoading(false); // Ensure loading stops on error
      throw e; // Re-throw to let the UI handle signup errors
    } catch (e) {
      _setError('An unknown error occurred during signup.');
        _setLoading(false); // Ensure loading stops on error
      throw e; // Re-throw
    }
  }

  /// Updates the user's name in Firestore and locally.
  Future<bool> updateUserName(String newName) async {
    if (_userModel == null) return false;
    _setLoading(true);
    try {
      // Create updated model locally
      final updatedUser = _userModel!.copyWith(name: newName);

      // Update Firestore
      // Only update the 'name' field for efficiency
      await _firestore.collection('users').doc(_userModel!.uid).update({'name': newName});

      // Update local state
      _userModel = updatedUser;
      _setLoading(false);
      notifyListeners(); // Notify UI about the change
      return true;
    } catch (e) {
      _setError('Failed to update profile name.');
      print("Error updating user name: $e");
      _setLoading(false);
      return false;
    }
  }

  /// Signs the user out of Firebase.
  Future<void> signOut() async {
    // _onAuthStateChanged will handle setting _userModel to null
    await _auth.signOut();
  }

  // --- Helper Methods ---
  void _setLoading(bool loading) {
    if (_isLoading == loading) return; // Avoid unnecessary rebuilds
    _isLoading = loading;
    if (loading) _errorMessage = null; // Clear error when loading starts
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message ?? 'An unknown error occurred.';
    // No need to set isLoading false here, the calling function should do that.
    notifyListeners();
  }
}
