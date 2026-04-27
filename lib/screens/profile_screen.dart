import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // SAMPLE DATA
  // TODO: replace with Firestore user document
  static const _dummyUser = {
    'name': 'Alex Rivera',
    'email': 'alex@email.com',
    'xp': 1240,
    'xpMax': 2000,
    'trips': 5,
    'badges': 3,
  };

  @override
  Widget build(BuildContext context) {
    final xp = _dummyUser['xp'] as int;
    final xpMax = _dummyUser['xpMax'] as int;

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

          // XP bar (XP system could be scrapped, should be built out last)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('XP: $xp / $xpMax',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              Text('${(xp / xpMax * 100).round()}%',
                  style: const TextStyle(color: Colors.teal, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: xp / xpMax,
            color: Colors.teal,
            backgroundColor: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(4),
            minHeight: 8,
          ),
          const SizedBox(height: 20),

          // Stats row
          Row(
            children: [
              _StatChip(
                label: 'Trips',
                value: '${_dummyUser['trips']}',
                icon: Icons.luggage,
              ),
              const SizedBox(width: 12),
              _StatChip(
                label: 'Badges',
                value: '${_dummyUser['badges']}',
                icon: Icons.military_tech,
              ),
              const SizedBox(width: 12),
              _StatChip(
                label: 'XP',
                value: '$xp',
                icon: Icons.star,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Badges
          Text('Badges',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade700)),
          const SizedBox(height: 12),
          const _BadgeRow(),
          const SizedBox(height: 24),

          // Settings section
          Text('Account',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade700)),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.edit_outlined,
            label: 'Edit Profile',
            //# TODO: Add profile editing with Firestore user docs
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Edit profile coming soon')),
            ),
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            //# TODO: Add notifications with Firestore cloud messaging
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications coming soon')),
            ),
          ),
          _SettingsTile(
            icon: Icons.logout,
            label: 'Sign Out',
            color: Colors.red.shade400,
            onTap: () {
              // TODO: call auth_service.signOut()
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const SplashScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}


// Class for stats layout 
class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.teal.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.teal, size: 20),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _BadgeRow extends StatelessWidget {
  const _BadgeRow();

  // TODO: replace with Firestore user badges
  static const _badges = [
    {'icon': Icons.flight_takeoff, 'label': 'First Trip'},
    {'icon': Icons.group, 'label': 'Collaborator'},
    {'icon': Icons.auto_fix_high, 'label': 'Optimizer'},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _badges.map((b) {
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Column(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.teal.shade50,
                child: Icon(b['icon'] as IconData,
                    color: Colors.teal, size: 22),
              ),
              const SizedBox(height: 4),
              Text(b['label'] as String,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// Class for settings button layout
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