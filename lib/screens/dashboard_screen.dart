import 'package:flutter/material.dart';
import 'trip_detail_screen.dart';
import 'create_trip_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import '../services/trip_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final TripService _tripService = TripService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TropicaGuide'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _TripsTab(tripService: _tripService),
          const _ProfileTab(),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('New Trip'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreateTripScreen()),
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.luggage_outlined),
              activeIcon: Icon(Icons.luggage),
              label: 'Trips'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
    );
  }
}

class _TripsTab extends StatelessWidget {
  const _TripsTab({required this.tripService});
  final TripService tripService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: tripService.getTrips(),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.teal),
          );
        }

        // Error
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off, color: Colors.grey, size: 48),
                const SizedBox(height: 12),
                const Text('Could not load trips',
                    style: TextStyle(color: Colors.grey, fontSize: 15)),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {},
                  child: const Text('Retry',
                      style: TextStyle(color: Colors.teal)),
                ),
              ],
            ),
          );
        }

        final trips = snapshot.data ?? [];

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Trips',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700)),
              const SizedBox(height: 16),
              if (trips.isEmpty)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.luggage_outlined,
                            color: Colors.grey, size: 48),
                        SizedBox(height: 12),
                        Text('No trips yet — tap + to create one',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: trips.length,
                    itemBuilder: (context, i) =>
                        _TripCard(trip: trips[i]),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip});
  final Map<String, dynamic> trip;

  @override
  Widget build(BuildContext context) {
    final name = trip['name'] as String? ?? 'Unnamed Trip';
    final destination = trip['destination'] as String? ?? '';
    final id = trip['id'] as String? ?? '';
    final memberCount = (trip['memberIds'] as List?)?.length ?? 0;

    // Firestore stores dates as Timestamps — convert to display string
    final startTs = trip['startDate'];
    final endTs = trip['endDate'];
    final dates = (startTs != null && endTs != null)
        ? '${_fmtTimestamp(startTs)} – ${_fmtTimestamp(endTs)}'
        : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TripDetailScreen(trip: trip, tripID: id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.travel_explore, color: Colors.teal),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(destination,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 4),
                    Row(children: [
                      if (dates.isNotEmpty) ...[
                        const Icon(Icons.calendar_today_outlined,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(dates,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                        const SizedBox(width: 12),
                      ],
                      const Icon(Icons.group_outlined,
                          size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('$memberCount members',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ]),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtTimestamp(dynamic ts) {
    try {
      final date = (ts as dynamic).toDate() as DateTime;
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month]} ${date.day}';
    } catch (_) {
      return '';
    }
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();
  @override
  Widget build(BuildContext context) => const ProfileScreen();
}