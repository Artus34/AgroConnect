import 'dart:convert';
import 'package:agrolink/features/auth/controllers/auth_provider.dart';
import 'package:agrolink/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:uuid/uuid.dart';
import '../models/crop_cycle_model.dart';
import '../models/journal_entry_model.dart';

class MyCropsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // State from AuthProvider
  UserModel? _currentUser;

  // Internal State
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic> _allCropPlans = {};
  List<CropCycleModel> _myCycles = [];
  List<JournalEntryModel> _currentJournalEntries = [];

  // Getters for the UI
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<CropCycleModel> get myCycles => _myCycles;
  List<JournalEntryModel> get currentJournalEntries => _currentJournalEntries;

  /// Constructor: Immediately starts loading the crop plans from JSON.
  MyCropsProvider() {
    _loadCropPlans();
  }

  /// Called by ChangeNotifierProxyProvider when AuthProvider updates.
  void update(AuthProvider authProvider) {
    if (authProvider.userModel != _currentUser) {
      _currentUser = authProvider.userModel;
      if (_currentUser != null) {
        // User just logged in, fetch their data.
        fetchMyCropCycles(); // Use the getter which now uses the correct userId
      } else {
        // User just logged out, clear their data.
        _myCycles = [];
        _currentJournalEntries = [];
        notifyListeners();
      }
    }
  }

  // --- 1. Load Plan Templates from JSON ---
  Future<void> _loadCropPlans() async {
    _setLoading(true);
    try {
      final String jsonString =
          await rootBundle.loadString('assets/crop_plans.json');
      _allCropPlans = json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      _setError("Failed to load crop plans: $e");
    }
    _setLoading(false); // Done loading, whether success or fail
  }

  // --- 2. Get List of Plans for UI ---
  /// Returns a list of all available crop plan names (e.g., "Pearl Millet (Bajra)")
  List<String> getAvailablePlanNames() {
    final keys = _allCropPlans.keys.toList();
    keys.sort(); // Sort them alphabetically for a clean UI
    return keys;
  }

  // --- 3. Start a New Crop Cycle ---
  /// Creates a new crop cycle, saves it to Firebase, and adds it to the local list.
  Future<bool> startNewCropCycle({
    required String plantType, // e.g., "Pearl Millet (Bajra)"
    required String displayName, // e.g., "Backyard Plot"
  }) async {
    if (_currentUser == null) {
      _setError("You must be logged in to start a cycle.");
      return false;
    }
    // --- OPTIONAL ROLE CHECK ---
    // Uncomment this if you only want farmers to create cycles
    // if (_currentUser!.role != 'farmer') {
    //   _setError("Only users with role 'farmer' can start crop cycles.");
    //   return false;
    // }
    // --- END ROLE CHECK ---

    _setLoading(true);

    try {
      final planTemplate = _allCropPlans[plantType];
      if (planTemplate == null) {
        throw Exception("No plan template found for $plantType");
      }

      // Deep copy the plan and add 'isCompleted' to each step
      List<Map<String, dynamic>> planProgress =
          List<Map<String, dynamic>>.from(planTemplate['plan'] as List);

      for (var step in planProgress) {
        step['isCompleted'] = false;
      }

      final newCycle = CropCycleModel(
        cycleId: _uuid.v4(),
        userId: _currentUser!.uid, // <<< Use uid here
        plantType: plantType,
        displayName: displayName.trim(),
        plantingDate: Timestamp.now(),
        status: 'Growing',
        planProgress: planProgress,
      );

      // Save to Firebase (new collection)
      await _firestore
          .collection('crop_cycles')
          .doc(newCycle.cycleId)
          .set(newCycle.toMap());

      // Add to local list and notify UI
      _myCycles.insert(0, newCycle); // Add to the front of the list
      _setLoading(false);
      return true;
    } catch (e) {
      _setError("Failed to start new cycle: $e");
      _setLoading(false);
      return false;
    }
  }

  // --- 4. Fetch All of a User's Cycles ---
  /// Fetches all cycles for the current user from Firebase.
  Future<void> fetchMyCropCycles() async {
    if (_currentUser == null) {
      _myCycles = []; // Clear list if no user
      notifyListeners();
      return;
    }
    _setLoading(true);

    try {
      final snapshot = await _firestore
          .collection('crop_cycles')
          .where('userId', isEqualTo: _currentUser!.uid) // <<< Use 'userId' in query
          .orderBy('plantingDate', descending: true)
          .get();

      _myCycles =
          snapshot.docs.map((doc) => CropCycleModel.fromMap(doc.data())).toList();
    } catch (e) {
      _setError("Failed to fetch your crop cycles: $e");
    }
    _setLoading(false);
  }

  // --- 5. Mark a Step as Complete ---
  /// Toggles the 'isCompleted' status of a plan step.
  Future<void> togglePlanStep(String cycleId, int stepIndex) async {
    try {
      // Find the cycle in the local list
      final cycleIndex = _myCycles.indexWhere((c) => c.cycleId == cycleId);
      if (cycleIndex == -1) {
        throw Exception("Local cycle not found.");
      }

      final cycle = _myCycles[cycleIndex];

      // Ensure stepIndex is valid
      if (stepIndex < 0 || stepIndex >= cycle.planProgress.length) {
         throw Exception("Invalid step index: $stepIndex");
      }


      // Get current status and flip it
      final bool currentStatus = cycle.planProgress[stepIndex]['isCompleted'] ?? false; // Default to false if null
      cycle.planProgress[stepIndex]['isCompleted'] = !currentStatus;

      // Update just the local list first for instant UI response
      notifyListeners();

      // Then update Firebase in the background
      await _firestore
          .collection('crop_cycles')
          .doc(cycleId)
          .update({'planProgress': cycle.planProgress});
    } catch (e) {
      _setError("Failed to update step: $e");
      // Optionally, you could revert the change here if Firebase fails
      // Consider fetching the cycle again to ensure local state matches DB
    }
  }

  // --- 6. Journal Methods (To be implemented later) ---

  /// Fetches all journal entries for a specific crop cycle.
  Future<void> fetchJournalEntries(String cycleId) async {
    _setLoading(true);
    _currentJournalEntries = [];
    try {
      final snapshot = await _firestore
          .collection('journal_entries') // A new collection for entries
          .where('cycleId', isEqualTo: cycleId)
          .orderBy('date', descending: true)
          .get();
      _currentJournalEntries = snapshot.docs
          .map((doc) => JournalEntryModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      _setError("Failed to fetch journal entries: $e");
    }
    _setLoading(false);
  }

  /// Adds a new text-based journal entry.
  Future<bool> addJournalEntry({
    required String cycleId,
    required String notes,
    // You can add 'Uint8List? imageBytes' here for image uploads
  }) async {
    if (_currentUser == null) {
      _setError("You must be logged in.");
      return false;
    }
    _setLoading(true);

    try {
      // TODO: If (imageBytes != null), upload to ImageService
      // String? imageUrl = await _imageService.uploadImage(...);

      final newEntry = JournalEntryModel(
        entryId: _uuid.v4(),
        cycleId: cycleId,
        date: Timestamp.now(),
        notes: notes,
        // imageUrl: imageUrl,
      );

      // Save to Firebase
      await _firestore
          .collection('journal_entries')
          .doc(newEntry.entryId)
          .set(newEntry.toMap());

      // Add to the list shown in the UI if it matches the currently viewed cycle
      // Check if _currentJournalEntries is for the same cycleId before adding
      _currentJournalEntries.insert(0, newEntry);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError("Failed to add journal entry: $e");
      _setLoading(false);
      return false;
    }
  }

  // --- State Management Helpers ---
  void _setLoading(bool loading) {
    if (_isLoading == loading) return; // Avoid unnecessary rebuilds
    _isLoading = loading;
    _errorMessage = null; // Clear error when loading
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false; // Stop loading on error
    if (kDebugMode) {
      print("MyCropsProvider Error: $message");
    }
    notifyListeners();
  }
}

