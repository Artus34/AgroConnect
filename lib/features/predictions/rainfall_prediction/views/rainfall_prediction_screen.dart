import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../controllers/rainfall_prediction_provider.dart';

class RainfallPredictionScreen extends StatefulWidget {
  const RainfallPredictionScreen({super.key});

  @override
  State<RainfallPredictionScreen> createState() =>
      _RainfallPredictionScreenState();
}

class _RainfallPredictionScreenState extends State<RainfallPredictionScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedSubdivision;
  final Map<String, TextEditingController> _rainfallControllers = {
    'Jan': TextEditingController(),
    'Feb': TextEditingController(),
    'Mar': TextEditingController(),
    'Apr': TextEditingController(),
    'May': TextEditingController(),
    'Jun': TextEditingController(),
    'Jul': TextEditingController(),
    'Aug': TextEditingController(),
    'Sep': TextEditingController(),
    'Oct': TextEditingController(),
    'Nov': TextEditingController(),
    'Dec': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RainfallPredictionProvider>(context, listen: false)
          .fetchSubdivisions();
    });
  }

  @override
  void dispose() {
    _rainfallControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void _resetPrediction(RainfallPredictionProvider provider) {
    if (provider.predictedRainfall != null) {
      provider.resetPrediction();
    }
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final provider =
          Provider.of<RainfallPredictionProvider>(context, listen: false);

      final subdivisionItem = provider.subdivisions.firstWhere(
        (e) => e['name'] == _selectedSubdivision,
        orElse: () => {'id': null},
      );

      final int? subdivisionId = subdivisionItem['id'];
      if (subdivisionId != null) {
        final Map<String, double> rainfallData = {};
        _rainfallControllers.forEach((month, controller) {
          final String uppercaseMonth = month.toUpperCase();
          rainfallData[uppercaseMonth] = double.parse(controller.text);
        });

        provider.predictRainfall(
          subdivisionId: subdivisionId,
          rainfallData: rainfallData,
        );
      } else {
        provider.setErrorMessage(
            'Please make sure all fields are selected correctly.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RainfallPredictionProvider>(context);

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
            'Rainfall Prediction',
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
              // to the correct method for returning to the previous screen.
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
                  color: AppColors.lightCard.withOpacity(0.9), // ⬅️ Optional: Added opacity
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
                            'Rainfall Prediction',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Enter the subdivision and rainfall for each month in millimeters (mm) to predict the total annual rainfall.',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildFormFields(context),
                          const SizedBox(height: 32),
                          Consumer<RainfallPredictionProvider>(
                            builder: (context, provider, child) {
                              if (provider.isLoading) {
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
                              if (provider.predictedRainfall != null) {
                                return _buildPredictionResultCard(
                                    provider.predictedRainfall!);
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
                                'Predict Yearly Rainfall',
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

  Widget _buildPredictionResultCard(String rainfallValue) {
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
            'Based on your input, the estimated annual rainfall is:',
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
                  '$rainfallValue mm',
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
    final provider = Provider.of<RainfallPredictionProvider>(context);
    final months = _rainfallControllers.keys.toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double aspectRatio;

        if (constraints.maxWidth < 600) {
          crossAxisCount = 2;
          aspectRatio = 2.2;
        } else if (constraints.maxWidth < 900) {
          crossAxisCount = 3;
          aspectRatio = 2.5;
        } else {
          crossAxisCount = 4;
          aspectRatio = 3.0; 
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDropdownField(
              label: 'Subdivision',
              options: provider.subdivisions,
              selectedValue: _selectedSubdivision,
              onChanged: (newValue) {
                setState(() {
                  _selectedSubdivision = newValue;
                });
                _resetPrediction(provider);
              },
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: aspectRatio,
              ),
              itemCount: months.length,
              itemBuilder: (context, index) {
                final month = months[index];
                return _buildTextField(
                  controller: _rainfallControllers[month]!,
                  label: month,
                  hint: 'mm',
                  onFieldChanged: (_) => _resetPrediction(provider),
                );
              },
            ),
          ],
        );
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
        Text(label,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
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
          items: options
              .map<DropdownMenuItem<String>>((Map<String, dynamic> item) {
            return DropdownMenuItem<String>(
              value: item['name'],
              child: Text(item['name'],
                  style: const TextStyle(color: AppColors.textPrimary)),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  )),
              const SizedBox(height: 4),
              Expanded(
                child: TextFormField(
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
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
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
              ),
            ],
          ),
        );
      },
    );
  }
}