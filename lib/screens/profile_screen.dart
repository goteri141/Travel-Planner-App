import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../services/authentication_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // TODO: replace with Firestore user document
  static const _dummyUser = {
    'name': 'Alex Rivera',
    'email': 'alex@email.com',
    'trips': 5,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + name & email
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: Colors.teal.shade100,
                child: const Icon(Icons.person, size: 40, color: Colors.teal),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _dummyUser['name'] as String,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _dummyUser['email'] as String,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Trips stat chip
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              children: [
                Icon(Icons.luggage, color: Colors.teal, size: 22),
                SizedBox(height: 4),
                Text(
                  '5', // TODO: replace with real trip count
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Text('Trips',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Account section
          Text(
            'Account',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700),
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.edit_outlined,
            label: 'Edit Profile',
            // TODO: navigate to edit profile screen
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Edit profile coming soon')),
            ),
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            // TODO: navigate to notifications screen
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications coming soon')),
            ),
          ),
          _SettingsTile(
            icon: Icons.logout,
            label: 'Sign Out',
            color: Colors.red.shade400,
            onTap: () async {
              await AuthenticationService().signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SplashScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color ?? Colors.teal.shade700),
      title: Text(label,
          style: TextStyle(color: color ?? Colors.black, fontSize: 15)),
      trailing: color == null
          ? const Icon(Icons.chevron_right, color: Colors.grey)
          : null,
      onTap: onTap,
    );
  }
}