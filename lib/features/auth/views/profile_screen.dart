import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_provider.dart';
import 'edit_profile_screen.dart'; 


import '../../crop_sales/views/my_listings_screen.dart'; 
import '../../crop_sales/views/transaction_history_screen.dart'; 


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  
  Widget _buildProfileOption(BuildContext context, {required String title, required IconData icon, required Widget destination}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Theme.of(context).primaryColor),
          title: Text(title, style: const TextStyle(fontSize: 16)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destination),
            );
          },
        ),
        const Divider(height: 1),
      ],
    );
  }

  
 Widget _buildProfileHeader(String name, String email, String role, String? imageUrl) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.green,
          
          backgroundImage: imageUrl != null && imageUrl.isNotEmpty
              ? NetworkImage(imageUrl)
              : null,
          child: imageUrl == null || imageUrl.isEmpty
              ? const Icon(Icons.person, size: 50, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 16),
        
        Text(
          name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Chip(
          label: Text(
            role.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          backgroundColor: role == 'farmer' ? Colors.green.shade100 : Colors.blue.shade100,
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ],
    );
  }

  

  @override
  Widget build(BuildContext context) {
    
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.userModel;

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Profile'),
            actions: [
              
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  
                  if (user != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  }
                },
                tooltip: 'Edit Profile',
              ),
            ],
          ),
          body: authProvider.isLoading && user == null
              ? const Center(child: CircularProgressIndicator())
              : user == null
                  ? const Center(child: Text('Please log in to view your profile.'))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildProfileHeader(user.name, user.email, user.role, user.profileImageUrl),
                          const SizedBox(height: 32),
                          
                          
                          
                          
                          if (user.role == 'farmer')
                            _buildProfileOption(
                              context,
                              title: 'Manage Products',
                              icon: Icons.inventory_2_outlined,
                              destination: const MyListingsScreen(),
                            ),
                          
                          
                          _buildProfileOption(
                              context,
                              title: 'Transaction History',
                              icon: Icons.receipt_long,
                              destination: const TransactionHistoryScreen(),
                            ),
                          
                          const Divider(),
                          
                          const Spacer(), 
                          
                          
                          ListTile(
                            leading: const Icon(Icons.logout, color: Colors.red),
                            title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            onTap: () {
                              
                              authProvider.signOut(); 
                            },
                          ),
                          
                          
                        ],
                      ),
                    ),
        );
      },
    );
  }
}