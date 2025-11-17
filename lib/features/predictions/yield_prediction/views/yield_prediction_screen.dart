import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../controllers/yield_prediction_provider.dart';

class YieldPredictionScreen extends StatefulWidget {
  YieldPredictionScreen({super.key});

  @override
  State<YieldPredictionScreen> createState() => _YieldPredictionScreenState();
}

class _YieldPredictionScreenState extends State<YieldPredictionScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedCrop;
  String? _selectedSeason;
  final _yearController = TextEditingController();
  final _areaController = TextEditingController();

  void _resetPrediction(YieldPredictionProvider provider) {
    if (provider.predictedYield != null) {
      provider.resetPrediction();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<YieldPredictionProvider>(context);

    // ⬅️ ADDED: Container for background image
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/farm.jpg'), 
          fit: BoxFit.cover,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // ⬅️ CHANGED: Make Scaffold transparent
        appBar: AppBar(
          title: const Text(
            'Yield Prediction',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          backgroundColor: Colors.transparent, // ⬅️ CHANGED: Make AppBar transparent
          elevation: 0, // Optional: Remove app bar shadow
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppColors.textPrimary,
            onPressed: () {
              // ⭐️ FIX: Changed from pushReplacementNamed('/home') 
              // to the correct method for returning to the previous screen (Predictions Screen).
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Card(
                  color: AppColors.lightCard.withOpacity(0.9), // ⬅️ Optional: Added opacity to card
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Yield Prediction',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Enter the details below to predict crop yield for a specific area.',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildFormFields(context),
                          const SizedBox(height: 32),
                          Consumer<YieldPredictionProvider>(
                            builder: (context, provider, child) {
                              if (provider.isLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(color: AppColors.primaryGreen),
                                );
                              }
                              if (provider.errorMessage != null) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Text(
                                    provider.errorMessage!,
                                    style: const TextStyle(color: Colors.redAccent),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }
                              if (provider.predictedYield != null) {
                                return _buildPredictionResultCard(provider.predictedYield!);
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          Center(
                            child: ElevatedButton(
                              onPressed: () => _submitForm(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Predict Yield',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.fontPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildPredictionResultCard(String yieldValue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Prediction Results',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Based on your input, the estimated yield is:',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: AppColors.lightCard.withOpacity(0.9), // ⬅️ Optional: Added opacity
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryGreen, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  yieldValue,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This is an AI-powered prediction based on historical data.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(BuildContext context) {
    final provider = Provider.of<YieldPredictionProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDropdownField(
                label: 'State',
                options: provider.states,
                selectedValue: _selectedState,
                onChanged: (newValue) {
                  setState(() {
                    _selectedState = newValue;
                    _selectedDistrict = null;
                    if (newValue != null) {
                      provider.fetchDistrictsByState(newValue);
                    }
                  });
                  _resetPrediction(provider);
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'District',
                options: provider.districts,
                selectedValue: _selectedDistrict,
                onChanged: (newValue) {
                  setState(() {
                    _selectedDistrict = newValue;
                  });
                  _resetPrediction(provider);
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Crop',
                options: provider.crops,
                selectedValue: _selectedCrop,
                onChanged: (newValue) {
                  setState(() {
                    _selectedCrop = newValue;
                  });
                  _resetPrediction(provider);
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Season',
                options: provider.seasons,
                selectedValue: _selectedSeason,
                onChanged: (newValue) {
                  setState(() {
                    _selectedSeason = newValue;
                  });
                  _resetPrediction(provider);
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _yearController,
                label: 'Year',
                hint: 'e.g., 2024',
                onFieldChanged: (_) => _resetPrediction(provider),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _areaController,
                label: 'Area (Hectares)',
                hint: 'e.g., 10',
                onFieldChanged: (_) => _resetPrediction(provider),
              ),
            ],
          );
        } else {
          int crossAxisCount = (constraints.maxWidth / 300).floor();
          if (crossAxisCount < 1) {
            crossAxisCount = 1;
          }
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3,
            children: [
              _buildDropdownField(
                label: 'State',
                options: provider.states,
                selectedValue: _selectedState,
                onChanged: (newValue) {
                  setState(() {
                    _selectedState = newValue;
                    _selectedDistrict = null;
                    if (newValue != null) {
                      provider.fetchDistrictsByState(newValue);
                    }
                  });
                  _resetPrediction(provider);
                },
              ),
              _buildDropdownField(
                label: 'District',
                options: provider.districts,
                selectedValue: _selectedDistrict,
                onChanged: (newValue) {
                  setState(() {
                    _selectedDistrict = newValue;
                  });
                  _resetPrediction(provider);
                },
              ),
              _buildDropdownField(
                label: 'Crop',
                options: provider.crops,
                selectedValue: _selectedCrop,
                onChanged: (newValue) {
                  setState(() {
                    _selectedCrop = newValue;
                  });
                  _resetPrediction(provider);
                },
              ),
              _buildDropdownField(
                label: 'Season',
                options: provider.seasons,
                selectedValue: _selectedSeason,
                onChanged: (newValue) {
                  setState(() {
                    _selectedSeason = newValue;
                  });
                  _resetPrediction(provider);
                },
              ),
              _buildTextField(
                controller: _yearController,
                label: 'Year',
                hint: 'e.g., 2024',
                onFieldChanged: (_) => _resetPrediction(provider),
              ),
              _buildTextField(
                controller: _areaController,
                label: 'Area (Hectares)',
                hint: 'e.g., 10',
                onFieldChanged: (_) => _resetPrediction(provider),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<Map<String, dynamic>> options,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedValue,
          onChanged: onChanged,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.lightCard.withOpacity(0.8), // ⬅️ Optional: Added opacity
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.textSecondary, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: options.map<DropdownMenuItem<String>>((Map<String, dynamic> item) {
            return DropdownMenuItem<String>(
              value: item['name'],
              child: Text(item['name'], style: const TextStyle(color: AppColors.textPrimary)),
            );
          }).toList(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ValueChanged<String?> onFieldChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: AppColors.textPrimary),
          onChanged: onFieldChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.lightCard.withOpacity(0.8), // ⬅️ Optional: Added opacity
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.textSecondary, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            if (double.tryParse(value) == null) {
              return 'Enter a valid number';
            }
            return null;
          },
        ),
      ],
    );
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<YieldPredictionProvider>(context, listen: false);

      final stateItem = provider.states.firstWhere((e) => e['name'] == _selectedState, orElse: () => {'id': null});
      final districtItem = provider.districts.firstWhere((e) => e['name'] == _selectedDistrict, orElse: () => {'id': null});
      final cropItem = provider.crops.firstWhere((e) => e['name'] == _selectedCrop, orElse: () => {'id': null});
      final seasonItem = provider.seasons.firstWhere((e) => e['name'] == _selectedSeason, orElse: () => {'id': null});
      
      final int? stateId = stateItem['id'];
      final int? districtId = districtItem['id'];
      final int? cropId = cropItem['id'];
      final int? seasonId = seasonItem['id'];

      if (stateId != null && districtId != null && cropId != null && seasonId != null) {
        provider.predictYield(
          stateId: stateId,
          districtId: districtId,
          cropId: cropId,
          seasonId: seasonId,
          year: int.parse(_yearController.text),
          area: double.parse(_areaController.text),
        );
      } else {
        provider.setErrorMessage('Please make sure all fields are selected correctly.');
      }
    }
  }
}