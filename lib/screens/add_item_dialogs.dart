import 'package:flutter/material.dart';

// ── Checklist item dialog ─────────────────────────────────────────────────────

// Returns the label string if confirmed, null if cancelled.
// Usage:
//   final label = await showAddChecklistItemDialog(context);
//   if (label != null) { /* add to list */ }
Future<String?> showAddChecklistItemDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (_) => const _AddChecklistItemDialog(),
  );
}

class _AddChecklistItemDialog extends StatefulWidget {
  const _AddChecklistItemDialog();

  @override
  State<_AddChecklistItemDialog> createState() =>
      _AddChecklistItemDialogState();
}

class _AddChecklistItemDialogState extends State<_AddChecklistItemDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, _controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Add Checklist Item',
        style: TextStyle(
          color: Colors.teal.shade700,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _confirm(),
          decoration: const InputDecoration(
            labelText: 'Item',
            prefixIcon: Icon(Icons.check_box_outline_blank),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Enter an item' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _confirm,
          child: const Text('Add'),
        ),
      ],
    );
  }
}

// ── Packing item dialog ───────────────────────────────────────────────────────

class PackingItemData {
  final String label;
  final String? assignedTo; // null = unassigned

  const PackingItemData({required this.label, this.assignedTo});
}

// Returns PackingItemData if confirmed, null if cancelled.
// Usage:
//   final item = await showAddPackingItemDialog(context, members: ['Alex','Maria']);
//   if (item != null) { /* add to list */ }
Future<PackingItemData?> showAddPackingItemDialog(
  BuildContext context, {
  List<String> members = const [],
}) {
  return showDialog<PackingItemData>(
    context: context,
    builder: (_) => _AddPackingItemDialog(members: members),
  );
}

class _AddPackingItemDialog extends StatefulWidget {
  const _AddPackingItemDialog({required this.members});
  final List<String> members;

  @override
  State<_AddPackingItemDialog> createState() => _AddPackingItemDialogState();
}

class _AddPackingItemDialogState extends State<_AddPackingItemDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _assignedTo; // null = unassigned

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(
        context,
        PackingItemData(
          label: _controller.text.trim(),
          assignedTo: _assignedTo,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build member options including "Unassigned"
    final options = ['Unassigned', ...widget.members];

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Add Packing Item',
        style: TextStyle(
          color: Colors.teal.shade700,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Item',
                prefixIcon: Icon(Icons.luggage_outlined),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter an item' : null,
            ),
            const SizedBox(height: 16),

            // Assign to member dropdown
            DropdownButtonFormField<String>(
              value: _assignedTo ?? 'Unassigned',
              decoration: const InputDecoration(
                labelText: 'Assign to',
                prefixIcon: Icon(Icons.person_outline),
              ),
              items: options
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (val) => setState(() {
                _assignedTo = val == 'Unassigned' ? null : val;
              }),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _confirm,
          child: const Text('Add'),
        ),
      ],
    );
  }
}