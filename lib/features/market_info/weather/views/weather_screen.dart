import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // ⬅️ IMPORTED for ImageFilter

import '../../../../app/theme/app_colors.dart';
import '../controllers/weather_provider.dart';
import '../services/weather_service.dart'; // Contains WeatherData, Location, Current, ForecastDay

// Convert to StatefulWidget to manage TextEditingController
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Optionally pre-fill the text field with the currently selected location
    // Do this after the first frame to ensure provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
            final currentLocation = context.read<WeatherProvider>().selectedLocation;
            _locationController.text = currentLocation;
        }
    });
  }


  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  // Function to handle manual location update
  void _updateManualLocation() {
    final newLocation = _locationController.text.trim();
    if (newLocation.isNotEmpty) {
      context.read<WeatherProvider>().updateLocation(newLocation);
      FocusScope.of(context).unfocus(); // Dismiss keyboard
    } else {
        // Show error if input is empty
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a city name.'),
            backgroundColor: AppColors.errorRed,
          ),
        );
    }
  }


  @override
  Widget build(BuildContext context) {
    // Use watch to get the latest provider state and rebuild on changes
    final provider = context.watch<WeatherProvider>();
    final weatherData = provider.weatherData; // Can be null

    // Update text controller if provider's location changes externally (e.g., initial load)
    // Avoid doing this constantly, maybe only if it differs significantly
      if (_locationController.text != provider.selectedLocation && provider.selectedLocation.isNotEmpty) {
        // Using WidgetsBinding avoids setting state during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
           if (mounted) {
              _locationController.text = provider.selectedLocation;
              // Move cursor to end
              _locationController.selection = TextSelection.fromPosition(TextPosition(offset: _locationController.text.length));
           }
        });
      }


    return Scaffold(
      backgroundColor: Colors.transparent, // ⬅️ CHANGED: Set Scaffold background transparent
      appBar: AppBar(
        title: Column( // Display current location in AppBar title area
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Weather Details', style: TextStyle(color: AppColors.textPrimary, fontSize: 18)),
              // Show the location name from the provider
              if (provider.selectedLocation.isNotEmpty)
                Text(
                  'For: ${provider.selectedLocation}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              // Show loading indicator in AppBar subtitle if loading
              if (provider.isLoading && provider.selectedLocation.isEmpty)
                  const Text(
                    'Loading location...',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  )
            ],
        ),
        // NOTE: Keeping the original lightCard color for AppBar as per original code, 
        // but it will cover the background image/blur underneath it.
        backgroundColor: AppColors.lightCard, 
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
          // Removed the my_location button as we are manual only now
      ),
      body: Stack( // ⬅️ ADDED: Stack for layering background and content
        children: [
          // 1. Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/doodles3.png', // ⬅️ Your background image
              fit: BoxFit.cover,
              repeat: ImageRepeat.repeat,
            ),
          ),
          // 2. Blur Filter
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0), // ⬅️ Applied blur
              child: Container(
                // Optional: Add a subtle overlay color to make text readable over the blur
                color: Colors.white.withOpacity(0.5), 
              ),
            ),
          ),
          
          // 3. Foreground Content (Original Column)
          Column( // Use Column to add search bar above the list
            children: [
              // --- Location Search Bar ---
              Padding(
                // NOTE: The background of this Padding/Row is not explicitly set to transparent, 
                // so the elements (TextField, IconButton) may sit on the default transparent canvas, 
                // which reveals the blurred image.
                padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 8.0), // Adjusted padding
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          hintText: 'Enter City Name',
                          labelText: 'Location', // Added label
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.textFieldBorder),
                          ),
                            focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                          ),
                          isDense: true, // Makes the field shorter
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), // Adjusted padding
                            // Clear button inside the text field
                            suffixIcon: _locationController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 20, color: AppColors.textSecondary),
                                onPressed: () {
                                    _locationController.clear();
                                    // Optionally clear weather data or show prompt?
                                },
                              )
                            : null, // Only show clear button if text exists
                        ),
                        onSubmitted: (_) => _updateManualLocation(), // Allow search on keyboard submit
                          textInputAction: TextInputAction.search,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Search Button
                    IconButton(
                      icon: const Icon(Icons.search, color: AppColors.primaryGreen),
                      iconSize: 28,
                        tooltip: 'Search Location',
                      // Disable button while loading to prevent multiple requests
                      onPressed: provider.isLoading ? null : _updateManualLocation,
                      style: IconButton.styleFrom( // Makes the button slightly larger
                        padding: const EdgeInsets.all(12),
                        backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
              // --- END Location Search Bar ---

              // --- Weather Content Area ---
              Expanded( // Make the content area scrollable and take remaining space
                child: _buildWeatherContent(provider, weatherData),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper widget to build the main content area (loading, error, data)
  Widget _buildWeatherContent(WeatherProvider provider, WeatherData? weatherData) {
      // Show loading indicator covering the content area while fetching
      if (provider.isLoading) {
        return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
      }

      // Show error message if fetch failed
      if (provider.errorMessage != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column( // Added Column for icon + text
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.errorRed, size: 40),
                  const SizedBox(height: 10),
                  Text(
                    'Error: ${provider.errorMessage}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                    const SizedBox(height: 10),
                    Text(
                    'Please check the location name and your internet connection.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ]
            )
          ),
        );
      }

      // Show prompt if no location entered/loaded yet
      if (weatherData == null) {
        return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                  'Please enter a location above to get the weather forecast.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
            ));
      }

      // If we have data, show the weather details
      return RefreshIndicator(
        // Refresh uses the currently selected location from the provider
        onRefresh: () => provider.fetchWeatherForecast(
            locationQuery: provider.selectedLocation,
            force: true),
        color: AppColors.primaryGreen,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(), // Ensure scroll for refresh
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0), // Adjust padding
          children: [
            _CurrentWeatherHeader(current: weatherData.current, location: weatherData.location),
            const SizedBox(height: 24),
            _WeatherDetailsGrid(current: weatherData.current),
            const SizedBox(height: 24),
            _ForecastSection(forecastDays: weatherData.forecastDays),
          ],
        ),
      );
  }

} // End of _WeatherScreenState


// --- Your existing helper widgets (_CurrentWeatherHeader, etc.) remain unchanged below ---

class _CurrentWeatherHeader extends StatelessWidget {
  final Current current;
  final Location location;

  const _CurrentWeatherHeader({required this.current, required this.location});

  @override
  Widget build(BuildContext context) {
    // Ensure icon URL starts with https:
    String iconUrl = current.iconUrl;
    if (!iconUrl.startsWith('https:') && iconUrl.startsWith('//')) {
      iconUrl = 'https:$iconUrl';
    } else if (!iconUrl.startsWith('http')) {
      // Handle cases where it might be completely missing the protocol
      iconUrl = ''; // Or provide a default icon path
    }


    return Card(
      color: AppColors.lightCard,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: LayoutBuilder(builder: (context, constraints) {
          final maxW = constraints.maxWidth;
          final imageSize = (maxW * 0.2).clamp(48.0, 90.0);
          final tempFontSize = (maxW * 0.12).clamp(28.0, 64.0);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Display the definitive location name from the API response
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  // Show Region/Country if available and different from Name
                  '${location.name}${location.region.isNotEmpty && location.region != location.name ? ', ${location.region}' : ''}${location.country.isNotEmpty && location.country != location.name ? ', ${location.country}' : ''}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: imageSize,
                    height: imageSize,
                    child: (iconUrl.isNotEmpty)
                        ? Image.network(
                            iconUrl,
                            fit: BoxFit.contain,
                            // Loading builder can be added
                            errorBuilder: (_, __, ___) => const Icon(Icons.cloud_off, size: 48, color: AppColors.textSecondary),
                          )
                        : const Icon(Icons.cloud_off, size: 48, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 16),

                  Flexible(
                    child: FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${current.tempC.round()}°C',
                        style: TextStyle(fontSize: tempFontSize, fontWeight: FontWeight.w300, color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                current.conditionText,
                style: const TextStyle(fontSize: 20, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ],
          );
        }),
      ),
    );
  }
}



class _WeatherDetailsGrid extends StatelessWidget {
  final Current current;
  const _WeatherDetailsGrid({required this.current});

  List<Map<String, dynamic>> _getDetails(Current current) {
    return [
      {'icon': Icons.thermostat, 'label': 'Feels Like', 'value': '${current.feelslikeC.round()}°C'},
      {'icon': Icons.air, 'label': 'Wind', 'value': '${current.windKph.round()} kph'},
      {'icon': Icons.water_drop_outlined, 'label': 'Humidity', 'value': '${current.humidity}%'},
      {'icon': Icons.grain, 'label': 'Precipitation', 'value': '${current.precipMm} mm'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final details = _getDetails(current);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 12),

        LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth;
          int crossAxisCount = 2;
          // Responsive grid columns
          if (width >= 600) crossAxisCount = 4; // Wider screens get 4 columns
          else crossAxisCount = 2; // Default to 2

          const double desiredTileHeight = 78; // Target height for each card
          final tileWidth = (width - ((crossAxisCount - 1) * 12)) / crossAxisCount;
          // Ensure aspect ratio doesn't get too extreme
          final childAspectRatio = (tileWidth / desiredTileHeight).clamp(1.0, 1.8);

          return GridView.builder(
            itemCount: details.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: childAspectRatio,
            ),
            itemBuilder: (context, index) {
              final detail = details[index];
              return _DetailCard(
                icon: detail['icon'] as IconData,
                label: detail['label'] as String,
                value: detail['value'] as String,
              );
            },
          );
        }),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.lightCard,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row( // Keep as Row for icon and text side-by-side
            children: [
              Icon(icon, color: AppColors.primaryGreen, size: 28),
              const SizedBox(width: 12),
              Expanded( // Allow text column to take remaining space
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                      const SizedBox(height: 2), // Small gap
                    Text(
                      value,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
        ),
      ),
    );
  }
}



class _ForecastSection extends StatelessWidget {
  final List<ForecastDay> forecastDays;
  const _ForecastSection({required this.forecastDays});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('3-Day Forecast', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Card(
          color: AppColors.lightCard,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          // Use clipBehavior to ensure corners are clipped if needed
          clipBehavior: Clip.antiAlias,
          child: ListView.separated(
            itemCount: forecastDays.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero, // Remove padding for full width divider
            itemBuilder: (context, index) => _ForecastTile(day: forecastDays[index]),
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.lightGreenBackground), // Themed divider
          ),
        ),
      ],
    );
  }
}

class _ForecastTile extends StatelessWidget {
  final ForecastDay day;
  const _ForecastTile({required this.day});

  @override
  Widget build(BuildContext context) {
      // Ensure icon URL starts with https:
    String iconUrl = day.iconUrl;
    if (!iconUrl.startsWith('https:') && iconUrl.startsWith('//')) {
      iconUrl = 'https:$iconUrl';
    } else if (!iconUrl.startsWith('http')) {
      iconUrl = ''; // Provide a default or handle missing protocol
    }

    return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Add vertical padding
      leading: SizedBox(
        width: 40,
        height: 40,
        child: (iconUrl.isNotEmpty)
            ? Image.network(iconUrl, width: 40, height: 40, fit: BoxFit.contain,
                  // Loading builder can be added
                errorBuilder: (_, __, ___) => const Icon(Icons.cloud_off, color: AppColors.textSecondary))
            : const Icon(Icons.cloud_off, color: AppColors.textSecondary),
      ),
      title: Text(day.dayOfWeek, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      subtitle: Text(day.conditionText, style: const TextStyle(color: AppColors.textSecondary)),
      trailing: Text(
        '${day.maxTempC.round()}° / ${day.minTempC.round()}°',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      ),
    );
  }
}