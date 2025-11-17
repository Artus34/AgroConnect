import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data'; 
import '../../../core/services/image_service.dart';
import '../controllers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  final ImageService _imageService = ImageService(); 
  
  
  Uint8List? _newImageBytes;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).userModel;
    _nameController = TextEditingController(text: user?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  
  Future<void> _pickImage() async {
    final bytes = await _imageService.pickImage();
    if (bytes != null) {
      setState(() {
        _newImageBytes = bytes;
      });
    }
  }

  
  Future<void> _saveProfile() async {
    
    if (!_formKey.currentState!.validate()) return;
    
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentName = authProvider.userModel?.name ?? '';
    final newName = _nameController.text.trim();
    
    final bool nameChanged = newName != currentName;
    final bool imageChanged = _newImageBytes != null;
    
    if (!nameChanged && !imageChanged) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No changes to save.')),
      );
      return;
    }

    setState(() { _isSaving = true; });

    bool success = true;

    
    if (imageChanged) {
      final imageSuccess = await authProvider.updateProfileImage(_newImageBytes!);
      if (!imageSuccess) success = false;
    }
    
    
    if (nameChanged) {
      final nameSuccess = await authProvider.updateUserName(newName);
      if (!nameSuccess) success = false;
    }

    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Failed to update profile.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() { _isSaving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).userModel;
    final String? currentImageUrl = user?.profileImageUrl;
    
    
    Widget profileImage;
    if (_newImageBytes != null) {
      profileImage = Image.memory(_newImageBytes!, fit: BoxFit.cover);
    } else if (currentImageUrl != null && currentImageUrl.isNotEmpty) {
      profileImage = Image.network(currentImageUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.person, size: 50, color: Colors.white);
      });
    } else {
      profileImage = const Icon(Icons.person, size: 50, color: Colors.white);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.green,
                      child: ClipOval(
                        child: SizedBox(
                          width: 120,
                          height: 120,
                          child: profileImage,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        onPressed: _pickImage,
                        tooltip: 'Change profile picture',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Save Changes', style: TextStyle(fontSize: 16)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}