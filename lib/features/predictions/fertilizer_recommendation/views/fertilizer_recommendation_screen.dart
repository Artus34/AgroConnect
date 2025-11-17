import 'package:agrolink/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/fertilizer_recommendation_provider.dart';

class FertilizerRecommendationScreen extends StatefulWidget {
  const FertilizerRecommendationScreen({super.key});

  @override
  State<FertilizerRecommendationScreen> createState() =>
      _FertilizerRecommendationScreenState();
}

class _FertilizerRecommendationScreenState
    extends State<FertilizerRecommendationScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _inputControllers = {
    'temperature': TextEditingController(),
    'humidity': TextEditingController(),
    'moisture': TextEditingController(),
    'nitrogen': TextEditingController(),
    'potassium': TextEditingController(),
    'phosphorous': TextEditingController(),
  };

  int? _selectedSoilTypeId;
  int? _selectedCropTypeId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FertilizerRecommendationProvider>(context, listen: false)
          .fetchCategories();
    });
  }

  @override
  void dispose() {
    _inputControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final provider =
          Provider.of<FertilizerRecommendationProvider>(context, listen: false);

      final Map<String, dynamic> fertilizerData = {
        'Temparature': int.parse(_inputControllers['temperature']!.text),
        'Humidity': int.parse(_inputControllers['humidity']!.text),
        'Moisture': int.parse(_inputControllers['moisture']!.text),
        'Nitrogen': int.parse(_inputControllers['nitrogen']!.text),
        'Potassium': int.parse(_inputControllers['potassium']!.text),
        'Phosphorous': int.parse(_inputControllers['phosphorous']!.text),
        'Soil_Type_ID': _selectedSoilTypeId,
        'Crop_Type_ID': _selectedCropTypeId,
      };

      if (_selectedSoilTypeId != null && _selectedCropTypeId != null) {
        provider.getFertilizerRecommendation(fertilizerData);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select both soil and crop types.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FertilizerRecommendationProvider>(context);

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
            'Fertilizer Recommendation',
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
                            'Fertilizer Suggestion',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Fill in the details to get AI-powered fertilizer recommendations.',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildFormFields(context),
                          const SizedBox(height: 32),
                          Consumer<FertilizerRecommendationProvider>(
                            builder: (context, provider, child) {
                              if (provider.isRecommendationLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                      color: AppColors.primaryGreen),
                                );
                              }

                              if (provider.errorMessage != null) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Text(
                                    provider.errorMessage!,
                                    style:
                                        const TextStyle(color: Colors.redAccent),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }
                              if (provider.recommendation != null) {
                                return _buildRecommendationResultCard(
                                    provider.recommendation!);
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          Center(
                            child: ElevatedButton(
                              onPressed: () => _submitForm(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Get Suggestions',
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

  Widget _buildFormFields(BuildContext context) {
    final numericFields = _inputControllers.keys.toList();
    final provider =
        Provider.of<FertilizerRecommendationProvider>(context, listen: false);

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        if (constraints.maxWidth < 600) {
          crossAxisCount = 2;
        } else if (constraints.maxWidth < 900) {
          crossAxisCount = 3;
        } else {
          crossAxisCount = 4;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.0,
              ),
              itemCount: numericFields.length,
              itemBuilder: (context, index) {
                final fieldName = numericFields[index];
                final label = fieldName
                    .split('_')
                    .map((word) => word[0].toUpperCase() + word.substring(1))
                    .join(' ');
                final hint = fieldName == 'temperature' ? '°C' : '%';
                return _buildTextField(
                  controller: _inputControllers[fieldName]!,
                  label: label,
                  hint: hint,
                );
              },
            ),
            const SizedBox(height: 16),
            _buildDropdownFields(context, provider),
          ],
        );
      },
    );
  }

  Widget _buildDropdownFields(
      BuildContext context, FertilizerRecommendationProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            children: [
              _buildDropdownField(
                label: 'Soil Type',
                options: provider.soilTypes,
                selectedValue: _selectedSoilTypeId,
                onChanged: (newValue) {
                  setState(() {
                    _selectedSoilTypeId = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Crop Type',
                options: provider.cropTypes,
                selectedValue: _selectedCropTypeId,
                onChanged: (newValue) {
                  setState(() {
                    _selectedCropTypeId = newValue;
                  });
                },
              ),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Soil Type',
                  options: provider.soilTypes,
                  selectedValue: _selectedSoilTypeId,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedSoilTypeId = newValue;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  label: 'Crop Type',
                  options: provider.cropTypes,
                  selectedValue: _selectedCropTypeId,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCropTypeId = newValue;
                    });
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildRecommendationResultCard(String recommendation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommendation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
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
                const Text(
                  'Based on your soil and crop data, we recommend:',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  recommendation,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Expanded( 
                child: TextFormField(
                  controller: controller,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.lightCard.withOpacity(0.8), // ⬅️ Optional: Added opacity
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: AppColors.textSecondary, width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: AppColors.primaryGreen, width: 2.0),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: false),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildDropdownField({
    required String label,
    required List<Map<String, dynamic>> options, 
    required int? selectedValue, 
    required ValueChanged<int?> onChanged, 
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: selectedValue,
          onChanged: onChanged,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.lightCard.withOpacity(0.8), // ⬅️ Optional: Added opacity
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.textSecondary, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.primaryGreen, width: 2.0),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items:
              options.map<DropdownMenuItem<int>>((Map<String, dynamic> item) {
            return DropdownMenuItem<int>(
              value: item['id'],
              child: Text(item['name'],
                  style: const TextStyle(color: AppColors.textPrimary)),
            );
          }).toList(),
          validator: (value) {
            if (value == null) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }
}