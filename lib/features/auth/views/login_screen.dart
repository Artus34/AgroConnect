import 'dart:ui'; // Needed for BackdropFilter for the glass effect

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart'; 
import '../../../app/theme/app_colors.dart'; // Assuming AppColors is available
import '../controllers/auth_provider.dart'; // Assuming AuthProvider is available


class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        
        return Scaffold(
          // Using Stack for the background, glow circles, and then the card
          body: Stack(
            children: [
              // 1. Deep Neon Grey Background with Subtle Green/Blue Gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E272E), Color(0xFF131A21)], // Dark, subtle colors
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // 2. Glow Circles (Visual interest for blur layer)
              _buildGlowCircle(Alignment.topLeft, AppColors.primaryGreen, 200),
              _buildGlowCircle(Alignment.bottomRight, AppColors.primaryGreen.withOpacity(0.5), 150),
              
              // 3. Login Form (Conditional on Loading State)
              auth.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryGreen),
                  )
                : Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        
                        // Custom Glass Card (uses BackdropFilter)
                        child: _GlassCard(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                
                                // Shimmer Effect on Title
                                Shimmer.fromColors(
                                  baseColor: AppColors.primaryGreen,
                                  highlightColor: Colors.lightGreenAccent,
                                  child: const Text(
                                    'AgroConnect',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white, 
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Welcome! Please login or create an account.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white70, 
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                
                                _buildTabSelector(context),
                                const SizedBox(height: 24),

                                
                                const Text('Email',
                                      style: TextStyle(color: Colors.white70)),
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                    controller: _emailController,
                                    hintText: 'name@example.com',
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) =>
                                        (value == null || !value.contains('@'))
                                            ? 'Enter a valid email'
                                            : null,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text('Password',
                                      style: TextStyle(color: Colors.white70)),
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                    controller: _passwordController,
                                    hintText: '••••••••',
                                    obscureText: true,
                                    validator: (value) =>
                                        (value == null || value.isEmpty)
                                            ? 'Enter your password'
                                            : null,
                                  ),
                                  const SizedBox(height: 24),

                                  
                                  if (auth.errorMessage != null)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        auth.errorMessage!,
                                        style: const TextStyle(color: Colors.redAccent),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),

                                  
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryGreen,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: auth.isLoading ? null : () => _loginUser(context),
                                    child: const Text('Login'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
  
  // Helper for creating the glowing circles (used for the blur effect)
  Widget _buildGlowCircle(Alignment alignment, Color color, double radius) {
    return Align(
      alignment: alignment,
      child: Container(
        height: radius * 2,
        width: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 150, 
              spreadRadius: 50,
            ),
          ],
        ),
      ),
    );
  }

  // Helper for consistent glass-themed text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white), 
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1), 
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
    );
  }

  Widget _buildTabSelector(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2), 
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryGreen, 
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/signup'),
              child: Container(
                color: Colors.transparent,
                child: const Center(
                  child: Text(
                    'Sign Up',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loginUser(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      
      final auth = context.read<AuthProvider>(); 
      
      final bool success = await auth.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (success && context.mounted) {
        
        Navigator.pushReplacementNamed(context, '/home'); 
      }
    }
  }
}


// ⭐️ Custom _GlassCard Implementation using BackdropFilter
// This widget provides the glassmorphism effect without external dependencies.
class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          decoration: BoxDecoration(
            // Frosted Glass effect: semi-transparent white/light green
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.15),
                AppColors.primaryGreen.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            // Subtle border
            border: Border.all(
              color: Colors.white.withOpacity(0.2), 
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(24.0),
          child: child,
        ),
      ),
    );
  }
}
