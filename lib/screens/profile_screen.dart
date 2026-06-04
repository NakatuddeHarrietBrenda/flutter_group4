import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161616),
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFFF5F5F0),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Playfair Display',
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFD4AF37).withOpacity(0.2),
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1E1E1E),
                  border: Border.all(
                    color: const Color(0xFFD4AF37),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Color(0xFFD4AF37),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Harriet',
                style: TextStyle(
                  color: Color(0xFFF5F5F0),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Playfair Display',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'harriet@gmail.com',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '+256756890122',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),
              _buildProfileOption(Icons.settings_outlined, 'Settings'),
              _buildProfileOption(Icons.history_outlined, 'Order History'),
              _buildProfileOption(Icons.help_outline, 'Help & Support'),
              _buildProfileOption(Icons.logout, 'Logout', isDestructive: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.1),
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.redAccent : const Color(0xFFD4AF37),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.redAccent : const Color(0xFFF5F5F0),
            fontSize: 16,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.white30,
        ),
        onTap: () {},
      ),
    );
  }
}
