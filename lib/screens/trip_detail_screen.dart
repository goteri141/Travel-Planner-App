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
          const _ChecklistTab(),
          _PackingTab(members: members),
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
  const _ChecklistTab();

  @override
  State<_ChecklistTab> createState() => _ChecklistTabState();
}

class _ChecklistTabState extends State<_ChecklistTab> {
  // TODO: replace with Firestore stream + transactions
  final List<Map<String, dynamic>> _items = [
    {'label': 'Book flights', 'done': true, 'by': 'Alex'},
  ];

  Future<void> _addItem() async {
    final label = await showAddChecklistItemDialog(context);
    if (label != null) {
      setState(() => _items.add({'label': label, 'done': false, 'by': null}));
      // TODO: write to Firestore
    }
  }

  @override
  Widget build(BuildContext context) {
    final done = _items.where((i) => i['done'] == true).length;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$done / ${_items.length} complete',
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
              Text(
                '${(done / (_items.isEmpty ? 1 : _items.length) * 100).round()}%',
                style: const TextStyle(
                    color: Colors.teal, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: _items.isEmpty ? 0 : done / _items.length,
            color: Colors.teal,
            backgroundColor: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                ..._items.asMap().entries.map(
                      (e) => CheckboxListTile(
                        value: e.value['done'],
                        activeColor: Colors.teal,
                        title: Text(
                          e.value['label'],
                          style: TextStyle(
                            decoration: e.value['done']
                                ? TextDecoration.lineThrough
                                : null,
                            color:
                                e.value['done'] ? Colors.grey : Colors.black,
                          ),
                        ),
                        subtitle:
                            e.value['done'] && e.value['by'] != null
                                ? Text('by ${e.value['by']}',
                                    style: const TextStyle(fontSize: 11))
                                : null,
                        onChanged: (val) {
                          // TODO: Firestore transaction
                          setState(() => _items[e.key]['done'] = val);
                        },
                      ),
                    ),
                ListTile(
                  leading: const Icon(Icons.add, color: Colors.teal),
                  title: const Text('Add item',
                      style: TextStyle(color: Colors.teal)),
                  onTap: _addItem,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Packing tab ───────────────────────────────────────────────────────────────

class _PackingTab extends StatefulWidget {
  const _PackingTab({required this.members});
  final List<String> members;

  @override
  State<_PackingTab> createState() => _PackingTabState();
}

class _PackingTabState extends State<_PackingTab> {
  // TODO: replace with Firestore stream + transactions
  final List<Map<String, dynamic>> _items = [
    {'label': 'Sunscreen SPF50', 'assignedTo': 'Alex', 'claimed': true},
    {'label': 'Snorkeling Gear', 'assignedTo': null, 'claimed': false},
  ];

  Future<void> _addItem() async {
    final result = await showAddPackingItemDialog(
      context,
      members: widget.members,
    );
    if (result != null) {
      setState(() => _items.add({
            'label': result.label,
            'assignedTo': result.assignedTo,
            'claimed': result.assignedTo != null,
          }));
      // TODO: write to Firestore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Group Packing List',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade700)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                ..._items.asMap().entries.map(
                      (e) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          title: Text(e.value['label']),
                          subtitle: Text(
                            e.value['claimed']
                                ? 'Claimed by ${e.value['assignedTo']}'
                                : 'Unassigned',
                            style: TextStyle(
                                fontSize: 12,
                                color: e.value['claimed']
                                    ? Colors.teal
                                    : Colors.grey),
                          ),
                          trailing: e.value['claimed']
                              ? const Icon(Icons.check_circle,
                                  color: Colors.teal)
                              : TextButton(
                                  onPressed: () {
                                    // TODO: Firestore transaction
                                    setState(() {
                                      _items[e.key]['claimed'] = true;
                                      _items[e.key]['assignedTo'] = 'You';
                                    });
                                  },
                                  child: const Text('Claim'),
                                ),
                        ),
                      ),
                    ),
                ListTile(
                  leading: const Icon(Icons.add, color: Colors.teal),
                  title: const Text('Add item',
                      style: TextStyle(color: Colors.teal)),
                  onTap: _addItem,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}