import 'package:flutter/material.dart';
import '../services/trip_service.dart';

class TripSettingsScreen extends StatefulWidget {
  const TripSettingsScreen({super.key, required this.trip, required this.tripID});

  final Map<String, dynamic> trip;
  final String tripID;

  @override
  State<TripSettingsScreen> createState() => _TripSettingsScreenState();
}

class _TripSettingsScreenState extends State<TripSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _destinationController;
  late final TextEditingController _budgetController;
  final TextEditingController _inviteController = TextEditingController();

  // TODO: replace with real member list from Firestore
  final _tripService = TripService();
  late List<String> _members;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.trip['name'] ?? '');
    _destinationController =
        TextEditingController(text: widget.trip['destination'] ?? '');
    _budgetController =
        TextEditingController(text: widget.trip['budget']?.toString() ?? '');
    _members = List<String>.from(widget.trip['memberIds'] ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _destinationController.dispose();
    _budgetController.dispose();
    _inviteController.dispose();
    super.dispose();
  }

  void _save() async{
    if (!_formKey.currentState!.validate()) return;
    // TODO: update Firestore trip document
    try {
      await _tripService.updateTrip(
        tripID: widget.tripID,
        name: _nameController.text.trim(),
        destination: _destinationController.text.trim(),
        budgetLimit: double.parse(_budgetController.text.trim()),
        memberIds: _members
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip updated')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("There's an error updating the trip")),
      );
    } }

  void _addMember() {
    final email = _inviteController.text.trim();
    if (email.isEmpty || !email.contains('@')) return;
    setState(() {
      _members.add(email);
      _inviteController.clear();
    });
    // TODO: look up user by email in Firestore and add to trip memberIds
    
  }

  void _removeMember(String member) {
    setState(() => _members.remove(member));
    // TODO: remove userId from Firestore trip memberIds
  }

  void _deleteTrip() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Trip?'),
        content: Text(
          'This will permanently delete "${_nameController.text}". This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400),
            onPressed: () async{
              // TODO: delete Firestore trip document
              try {
                await _tripService.deleteTrip(widget.tripID);
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // close settings
                Navigator.pop(context);
              } catch (e)  {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("There's an error when deleting the trip"))
                );
              }// close trip detail
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Settings'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Trip details section ────────────────────────────────────────
            _SectionHeader('Trip Details'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Trip Name',
                prefixIcon: Icon(Icons.edit_outlined),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _destinationController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Destination',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Enter a destination'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Budget Limit (USD)',
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter a budget';
                if (double.tryParse(v) == null) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 28),

            // ── Members section ─────────────────────────────────────────────
            _SectionHeader('Members'),
            const SizedBox(height: 12),
            ..._members.map(
              (m) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Colors.teal.shade100,
                  child: Text(
                    m[0].toUpperCase(),
                    style: const TextStyle(
                        color: Colors.teal, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(m),
                trailing: m.contains('(you)')
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            color: Colors.red),
                        onPressed: () => _removeMember(m),
                      ),
              ),
            ),
            const SizedBox(height: 8),

            // Invite field
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _inviteController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Invite by email',
                      prefixIcon: Icon(Icons.person_add_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addMember,
                  icon: const Icon(Icons.add_circle,
                      color: Colors.teal, size: 32),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Save button ─────────────────────────────────────────────────
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save Changes'),
            ),
            const SizedBox(height: 16),

            // ── Danger zone ─────────────────────────────────────────────────
            _SectionHeader('Danger Zone'),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
              label: Text(
                'Delete Trip',
                style: TextStyle(color: Colors.red.shade400),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red.shade300),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _deleteTrip,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.teal.shade700,
      ),
    );
  }
}