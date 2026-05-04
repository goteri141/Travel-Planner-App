import 'package:flutter/material.dart';
import 'add_activity_sheet.dart';
import 'add_item_dialogs.dart';
import 'optimizer_screen.dart';
import 'trip_settings_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TripDetailScreen extends StatefulWidget {
  const TripDetailScreen({super.key, required this.trip, required this.tripID});

  // Changed from Map<String, String> to Map<String, dynamic>
  // to match Firestore document data
  final Map<String, dynamic> trip;
  final String tripID;

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripName = widget.trip['name'] as String? ?? 'Trip';
    final members = List<String>.from(widget.trip['memberIds'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: Text(tripName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TripSettingsScreen(
                  trip: widget.trip,
                  tripID: widget.tripID,
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.teal,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.teal,
          tabs: const [
            Tab(text: 'Itinerary'),
            Tab(text: 'Checklist'),
            Tab(text: 'Packing'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ItineraryTab(tripID: widget.tripID),
          _ChecklistTab(tripID: widget.tripID),
          _PackingTab(tripID: widget.tripID, members: members),
        ],
      ),
    );
  }
}

// ── Itinerary tab ─────────────────────────────────────────────────────────────

class _ItineraryTab extends StatefulWidget {
  const _ItineraryTab({required this.tripID});
  final String tripID;

  @override
  State<_ItineraryTab> createState() => _ItineraryTabState();
}

class _ItineraryTabState extends State<_ItineraryTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<void> _openAddActivity() async {
    final result = await showAddActivitySheet(context);

    if (result != null) {
      await _firestore
          .collection('trips')
          .doc(widget.tripID)
          .collection('itinerary')
          .add({
        'name': result.name,
        'time': result.time,
        'cost': result.cost,
        'duration': result.duration,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  void _openOptimizer(List<Map<String, String>> activities) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OptimizerScreen(activities: activities),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('trips')
          .doc(widget.tripID)
          .collection('itinerary')
          .orderBy('createdAt')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ...docs.map((doc) {
                    final activity =
                        doc.data() as Map<String, dynamic>;

                    return _ActivityTile(
                      activity: {
                        'time': activity['time'] ?? '',
                        'name': activity['name'] ?? '',
                        'cost': '\$${activity['cost']}',
                        'duration': activity['duration'] ?? '',
                      },
                    );
                  }),

                  const SizedBox(height: 8),

                  OutlinedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Activity'),
                    onPressed: _openAddActivity,
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text('Run Optimizer'),
                    onPressed: docs.isEmpty
                        ? null
                        : () {
                            final activities = docs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;

                              return {
                                'time': data['time']?.toString() ?? '',
                                'name': data['name']?.toString() ?? '',
                                'cost': '\$${data['cost'] ?? 0}',
                                'duration': data['duration']?.toString() ?? '',
                              };
                            }).toList();

                            _openOptimizer(activities);
                          },
                  )
                ],
              ),
            )
          ],
        );
      },
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});
  final Map<String, String> activity;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              child: Text(activity['time']!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ),
            Container(width: 1, height: 40, color: Colors.teal.shade100),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(activity['name']!,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text('${activity['cost']}  ·  ${activity['duration']}',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.drag_handle, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// ── Checklist tab ─────────────────────────────────────────────────────────────

class _ChecklistTab extends StatefulWidget {
  const _ChecklistTab({required this.tripID});

  final String tripID;

  @override
  State<_ChecklistTab> createState() => _ChecklistTabState();
}

class _ChecklistTabState extends State<_ChecklistTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _checklistRef =>
      _firestore.collection('trips').doc(widget.tripID).collection('checklist');

  Future<void> _addItem() async {
    final label = await showAddChecklistItemDialog(context);

    if (label != null && label.trim().isNotEmpty) {
      await _checklistRef.add({
        'label': label.trim(),
        'done': false,
        'by': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _toggleItem(String itemId, bool done) async {
    await _checklistRef.doc(itemId).update({
      'done': done,
      'by': done ? 'You' : null,
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _checklistRef.orderBy('createdAt').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.teal),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        final done = docs.where((doc) => doc.data()['done'] == true).length;
        final percent = docs.isEmpty ? 0 : (done / docs.length * 100).round();

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$done / ${docs.length} complete',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  Text(
                    '$percent%',
                    style: const TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: docs.isEmpty ? 0 : done / docs.length,
                color: Colors.teal,
                backgroundColor: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    ...docs.map((doc) {
                      final item = doc.data();
                      final isDone = item['done'] == true;
                      final by = item['by'];

                      return CheckboxListTile(
                        value: isDone,
                        activeColor: Colors.teal,
                        title: Text(
                          item['label'] ?? '',
                          style: TextStyle(
                            decoration:
                                isDone ? TextDecoration.lineThrough : null,
                            color: isDone ? Colors.grey : Colors.black,
                          ),
                        ),
                        subtitle: isDone && by != null
                            ? Text(
                                'by $by',
                                style: const TextStyle(fontSize: 11),
                              )
                            : null,
                        onChanged: (val) {
                          _toggleItem(doc.id, val ?? false);
                        },
                      );
                    }),
                    ListTile(
                      leading: const Icon(Icons.add, color: Colors.teal),
                      title: const Text(
                        'Add item',
                        style: TextStyle(color: Colors.teal),
                      ),
                      onTap: _addItem,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Packing tab ───────────────────────────────────────────────────────────────

class _PackingTab extends StatefulWidget {
  const _PackingTab({
    required this.tripID,
    required this.members,
  });

  final String tripID;
  final List<String> members;

  @override
  State<_PackingTab> createState() => _PackingTabState();
}

class _PackingTabState extends State<_PackingTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _packingRef =>
      _firestore.collection('trips').doc(widget.tripID).collection('packing');

  Future<void> _addItem() async {
    final result = await showAddPackingItemDialog(
      context,
      members: widget.members,
    );

    if (result != null && result.label.trim().isNotEmpty) {
      await _packingRef.add({
        'label': result.label.trim(),
        'assignedTo': result.assignedTo,
        'claimed': result.assignedTo != null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _claimItem(String itemId) async {
    await _packingRef.doc(itemId).update({
      'claimed': true,
      'assignedTo': 'You',
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _packingRef.orderBy('createdAt').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.teal),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Group Packing List',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade700,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    ...docs.map((doc) {
                      final item = doc.data();
                      final claimed = item['claimed'] == true;
                      final assignedTo = item['assignedTo'];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(item['label'] ?? ''),
                          subtitle: Text(
                            claimed
                                ? 'Claimed by ${assignedTo ?? 'Unknown'}'
                                : 'Unassigned',
                            style: TextStyle(
                              fontSize: 12,
                              color: claimed ? Colors.teal : Colors.grey,
                            ),
                          ),
                          trailing: claimed
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.teal,
                                )
                              : TextButton(
                                  onPressed: () => _claimItem(doc.id),
                                  child: const Text('Claim'),
                                ),
                        ),
                      );
                    }),
                    ListTile(
                      leading: const Icon(Icons.add, color: Colors.teal),
                      title: const Text(
                        'Add item',
                        style: TextStyle(color: Colors.teal),
                      ),
                      onTap: _addItem,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}