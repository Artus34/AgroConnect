import 'package:agrolink/app/theme/app_colors.dart';
import 'package:agrolink/features/auth/controllers/auth_provider.dart'; // Keep for potential future use (checking role)
import 'package:agrolink/features/my_crops/controllers/my_crops_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddCropCycleScreen extends StatefulWidget {
  const AddCropCycleScreen({super.key});

  @override
  State<AddCropCycleScreen> createState() => _AddCropCycleScreenState();
}

class _AddCropCycleScreenState extends State<AddCropCycleScreen> {
  String? _selectedPlantType;
  final _displayNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  // --- UPDATED METHOD - REMOVED farmerId LOGIC ---
  Future<void> _startCycle() async {
    // 1. Validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Read the provider
    final provider = context.read<MyCropsProvider>();
    // Optional: Check if user is logged in via provider._currentUser if needed

    debugPrint("Starting cycle for plant: $_selectedPlantType");

    // 3. Call the provider - NO farmerId needed here
    bool success = false;
    String? errorMessage;

    // Show loading indicator on button
    setState(() {}); // Trigger rebuild to show loading

    try {
      success = await provider.startNewCropCycle(
        plantType: _selectedPlantType!,
        displayName: _displayNameController.text.trim(),
        // No farmerId needed here, provider gets it internally
      );
      if (!success) {
        // If startNewCropCycle returned false, get the error message
        errorMessage = provider.errorMessage ?? "Unknown error occurred.";
      }
    } catch (e) {
      debugPrint("Error calling startNewCropCycle: $e");
      errorMessage = e.toString();
      success = false;
    } finally {
      // Hide loading indicator
      if (mounted) {
        setState(() {}); // Trigger rebuild to hide loading
      }
    }

    // 4. Go back or show error
    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New crop cycle started!'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start cycle: ${errorMessage ?? "Unknown error"}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }
  // --- END OF UPDATED METHOD ---


  @override
  Widget build(BuildContext context) {
    // Use Consumer to get the list of plans
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start New Crop Cycle'),
      ),
      body: Consumer<MyCropsProvider>(
        builder: (context, provider, child) {
          final availablePlans = provider.getAvailablePlanNames();
          // Get loading state directly from provider for button
          final bool isLoading = provider.isLoading;


          if (availablePlans.isEmpty && provider.isLoading) {
            // Show loading indicator only if plans haven't loaded yet
            return const Center(child: CircularProgressIndicator());
          }
           if (availablePlans.isEmpty && !provider.isLoading) {
            // Show error if plans failed to load
            return const Center(child: Text("Could not load crop plans."));
          }

          // Initialize dropdown if not selected
          if (_selectedPlantType == null && availablePlans.isNotEmpty) {
            _selectedPlantType = availablePlans[0];
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView( // Use ListView for scrollability
                children: [
                  // --- Dropdown for selecting plant ---
                  DropdownButtonFormField<String>(
                    value: _selectedPlantType,
                    decoration: const InputDecoration(
                      labelText: 'Select Crop',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.grass),
                    ),
                    items: availablePlans.map((String plantName) {
                      return DropdownMenuItem<String>(
                        value: plantName,
                        child: Text(plantName),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedPlantType = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a crop type';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // --- Text field for custom name ---
                  TextFormField(
                    controller: _displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Cycle Name (e.g., Backyard Plot)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.label_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name for this cycle';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // --- Start Cycle Button ---
                  ElevatedButton(
                    // Disable button while loading or if no plant type selected
                    onPressed: isLoading || _selectedPlantType == null ? null : _startCycle,
                    style: ElevatedButton.styleFrom(
                       padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading // Use isLoading from provider
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Start Cycle'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

