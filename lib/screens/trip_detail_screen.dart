import 'package:flutter/material.dart';

class TripDetailScreen extends StatefulWidget {
  const TripDetailScreen({super.key, required this.trip});

  final Map<String, String> trip;

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trip['name']!),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: navigate to trip settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Trip settings coming soon')),
              );
            },
          ),
        ],
        // Navigation bar
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
          _ItineraryTab(tripName: widget.trip['name']!),
          const _ChecklistTab(),
          const _PackingTab(),
        ],
      ),
    );
  }
}

// Itinerary tab 
class _ItineraryTab extends StatefulWidget {
  const _ItineraryTab({required this.tripName});
  final String tripName;

  @override
  State<_ItineraryTab> createState() => _ItineraryTabState();
}

class _ItineraryTabState extends State<_ItineraryTab> {
  int _selectedDay = 0;

  // SAMPLE DATA
  // TODO: replace with Firestore data
  final List<Map<String, String>> _dummyActivities = [
    {
      'time': '9:00 AM',
      'name': 'Tanah Lot Temple',
      'cost': '\$10',
      'duration': '2h',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Day selector
        SizedBox(
          height: 52,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: 5,
            itemBuilder: (context, index) {
              final isSelected = _selectedDay == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedDay = index),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.teal : Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Day ${index + 1}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.teal,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const Divider(height: 1),

        // Activity list
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ..._dummyActivities.map((a) => _ActivityTile(activity: a)),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Activity'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.teal,
                  side: const BorderSide(color: Colors.teal),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // TODO: open add activity sheet
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add activity coming soon')),
                  );
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.auto_fix_high),
                label: const Text('Run Optimizer'),
                onPressed: () {
                  // TODO: run optimizer_service and show results
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Optimizer coming soon')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
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
            // Time column
            SizedBox(
              width: 56,
              child: Text(
                activity['time']!,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            Container(width: 1, height: 40, color: Colors.teal.shade100),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity['name']!,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${activity['cost']}  ·  ${activity['duration']}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
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

// Checklist tab
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

  @override
  Widget build(BuildContext context) {
    final done = _items.where((i) => i['done'] == true).length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$done / ${_items.length} complete',
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
              Text('${(done / (_items.isEmpty ? 1 : _items.length) * 100).round()}%',
                  style: const TextStyle(
                      color: Colors.teal, fontWeight: FontWeight.bold)),
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

          // Items for checklist
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
                            color: e.value['done'] ? Colors.grey : Colors.black,
                          ),
                        ),
                        subtitle: e.value['done']
                            ? Text('by ${e.value['by']}',
                                style: const TextStyle(fontSize: 11))
                            : null,
                        onChanged: (val) {
                          // TODO: Firestore transaction update
                          setState(() => _items[e.key]['done'] = val);
                        },
                      ),
                    ),
                ListTile(
                  leading: const Icon(Icons.add, color: Colors.teal),
                  title: const Text('Add item',
                      style: TextStyle(color: Colors.teal)),
                  onTap: () {
                    // TODO: show add item dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add item coming soon')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Packing tab 
class _PackingTab extends StatefulWidget {
  const _PackingTab();

  @override
  State<_PackingTab> createState() => _PackingTabState();
}

class _PackingTabState extends State<_PackingTab> {
  // TODO: replace with Firestore stream + transactions
  final List<Map<String, dynamic>> _items = [
    {'label': 'Sunscreen SPF50', 'assignedTo': 'Alex', 'claimed': true},
    {'label': 'Snorkeling Gear', 'assignedTo': null, 'claimed': false},
  ];

  @override
  Widget build(BuildContext context) {
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
                                  : Colors.grey,
                            ),
                          ),
                          trailing: e.value['claimed']
                              ? const Icon(Icons.check_circle,
                                  color: Colors.teal)
                              : TextButton(
                                  onPressed: () {
                                    // TODO: Firestore transaction claim
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
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add item coming soon')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}