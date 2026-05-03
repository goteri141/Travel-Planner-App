import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // TODO: replace with FCM / Firestore notification stream
  final List<_Notif> _notifs = [
    _Notif(
      icon: Icons.auto_fix_high,
      title: 'Optimizer reordered Day 2',
      body: 'Tanah Lot Temple was moved to 8:00 AM.',
      time: '2 min ago',
      isUnread: true,
      color: Colors.teal,
    ),
    _Notif(
      icon: Icons.edit,
      title: 'Maria edited the packing list',
      body: 'Added: Sunscreen SPF50',
      time: '5 min ago',
      isUnread: true,
      color: Colors.orange,
    ),
    _Notif(
      icon: Icons.check_circle_outline,
      title: 'Kai checked off: Flight booking',
      body: 'Pre-trip checklist · Bali 2026',
      time: '1 hr ago',
      isUnread: false,
      color: Colors.green,
    ),
    _Notif(
      icon: Icons.luggage,
      title: 'Your Bali trip starts in 3 days!',
      body: 'Jun 12 – Jun 20 · 3 members',
      time: '2 hrs ago',
      isUnread: false,
      color: Colors.teal,
    ),
  ];

  void _markAllRead() {
    setState(() {
      for (final n in _notifs) {
        n.isUnread = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifs.where((n) => n.isUnread).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(color: Colors.teal),
              ),
            ),
        ],
      ),
      body: _notifs.isEmpty
          ? const Center(
              child: Text(
                'No notifications yet',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _notifs.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 72),
              itemBuilder: (context, i) => _NotifTile(
                notif: _notifs[i],
                onTap: () {
                  setState(() => _notifs[i].isUnread = false);
                  // TODO: deep-link to relevant screen based on notif type
                },
              ),
            ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────

class _Notif {
  final IconData icon;
  final String title;
  final String body;
  final String time;
  final Color color;
  bool isUnread;

  _Notif({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    required this.color,
    required this.isUnread,
  });
}

// ── Tile ──────────────────────────────────────────────────────────────────────

class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.notif, required this.onTap});

  final _Notif notif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: notif.isUnread ? Colors.teal.shade50 : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon circle
            CircleAvatar(
              radius: 22,
              backgroundColor: notif.color.withOpacity(0.12),
              child: Icon(notif.icon, color: notif.color, size: 20),
            ),
            const SizedBox(width: 14),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.title,
                    style: TextStyle(
                      fontWeight: notif.isUnread
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notif.body,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.time,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Unread dot
            if (notif.isUnread)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}