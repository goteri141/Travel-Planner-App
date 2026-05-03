import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../services/authentication_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthenticationService _authService = AuthenticationService();
  final userID = FirebaseAuth.instance.currentUser!.uid;

  String userName = '';
  String email = '';

  // Getting User Info 
  Future<void> loadProfile() async {
  final user = await FirebaseFirestore.instance
    .collection('users')
    .doc(userID)
    .get();
  
  final data = user.data();

  if (data != null) {
    setState(() {
      userName = data['name'];
      email = data['email'];
    });
  }
  }
  
  @override
  void initState() {
    super.initState();
    loadProfile();
  }

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
                    userName,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
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
              await _authService.signOut();
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