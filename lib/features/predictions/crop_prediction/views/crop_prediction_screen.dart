import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../controllers/crop_prediction_provider.dart';

class CropPredictionScreen extends StatelessWidget {
  CropPredictionScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _nitrogenController = TextEditingController();
  final _phosphorusController = TextEditingController();
  final _potassiumController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _humidityController = TextEditingController();
  final _phController = TextEditingController();
  final _rainfallController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
            'Crop Prediction',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          backgroundColor: Colors.transparent, // ⬅️ CHANGED: Make AppBar transparent
          elevation: 0, // ⬅️ Optional: Remove app bar shadow if it doesn't match background
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
                            'Crop Prediction',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Fill in the details below to get AI-powered crop suggestions for your farm.',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildFormFields(context),
                          const SizedBox(height: 32),
                          Consumer<CropPredictionProvider>(
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
                              if (provider.predictedCrop != null) {
                                return _buildPredictionResultCard(provider.predictedCrop!);
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
                                'Predict Crop',
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

  Widget _buildPredictionResultCard(String cropName) {
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
            'Based on your input, here are the most suitable crops.',
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
                  cropName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Confidence Score: 95%',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                const LinearProgressIndicator(
                  value: 0.95,
                  backgroundColor: AppColors.textSecondary,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                  minHeight: 8,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Excellent conditions for this crop due to suitable environmental factors.',
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
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _nitrogenController,
                label: 'Nitrogen (mg/kg)',
                hint: 'e.g., 90',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phosphorusController,
                label: 'Phosphorus (mg/kg)',
                hint: 'e.g., 42',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _potassiumController,
                label: 'Potassium (mg/kg)',
                hint: 'e.g., 43',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _temperatureController,
                label: 'Temperature (°C)',
                hint: 'e.g., 21',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _humidityController,
                label: 'Humidity (%)',
                hint: 'e.g., 82',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phController,
                label: 'Soil pH (0-14)',
                hint: 'e.g., 6.5',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _rainfallController,
                label: 'Rainfall (mm)',
                hint: 'e.g., 203',
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
              _buildTextField(
                controller: _nitrogenController,
                label: 'Nitrogen (mg/kg)',
                hint: 'e.g., 90',
              ),
              _buildTextField(
                controller: _phosphorusController,
                label: 'Phosphorus (mg/kg)',
                hint: 'e.g., 42',
              ),
              _buildTextField(
                controller: _potassiumController,
                label: 'Potassium (mg/kg)',
                hint: 'e.g., 43',
              ),
              _buildTextField(
                controller: _temperatureController,
                label: 'Temperature (°C)',
                hint: 'e.g., 21',
              ),
              _buildTextField(
                controller: _humidityController,
                label: 'Humidity (%)',
                hint: 'e.g., 82',
              ),
              _buildTextField(
                controller: _phController,
                label: 'Soil pH (0-14)',
                hint: 'e.g., 6.5',
              ),
              _buildTextField(
                controller: _rainfallController,
                label: 'Rainfall (mm)',
                hint: 'e.g., 203',
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: AppColors.textPrimary), 
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
      final provider = Provider.of<CropPredictionProvider>(context, listen: false);

      provider.predictCrop(
        n: double.parse(_nitrogenController.text),
        p: double.parse(_phosphorusController.text),
        k: double.parse(_potassiumController.text),
        temperature: double.parse(_temperatureController.text),
        humidity: double.parse(_humidityController.text),
        ph: double.parse(_phController.text),
        rainfall: double.parse(_rainfallController.text),
      );
    }
  }
}