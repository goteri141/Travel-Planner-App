import 'package:flutter/material.dart';

// Data class representing an activity — replace with model later
// TODO: swap this out for ActivityModel from models/ folder
class ActivityFormData {
  final String name;
  final String time;
  final String duration;
  final double cost;

  const ActivityFormData({
    required this.name,
    required this.time,
    required this.duration,
    required this.cost,
  });
}

// Call this from anywhere to open the sheet:
//   final result = await showAddActivitySheet(context);
//   if (result != null) { /* use result */ }
Future<ActivityFormData?> showAddActivitySheet(BuildContext context) {
  return showModalBottomSheet<ActivityFormData>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AddActivitySheet(),
  );
}

class _AddActivitySheet extends StatefulWidget {
  const _AddActivitySheet();

  @override
  State<_AddActivitySheet> createState() => _AddActivitySheetState();
}

class _AddActivitySheetState extends State<_AddActivitySheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _costController = TextEditingController();

  // Time picker state
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 11, minute: 0);

  // Category selection
  final List<String> _categories = [
    'Culture', 'Beach', 'Food', 'Adventure', 'Relaxation', 'Transport',
  ];
  String _selectedCategory = 'Culture';

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    super.dispose();
  }

  String _fmtTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  // Compute duration string from start/end
  String get _durationLabel {
    final startMins = _startTime.hour * 60 + _startTime.minute;
    final endMins = _endTime.hour * 60 + _endTime.minute;
    final diff = endMins - startMins;
    if (diff <= 0) return '—';
    final h = diff ~/ 60;
    final m = diff % 60;
    if (h == 0) return '${m}min';
    if (m == 0) return '${h}h';
    return '${h}h ${m}min';
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) => Theme(
        data: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final startMins = _startTime.hour * 60 + _startTime.minute;
    final endMins = _endTime.hour * 60 + _endTime.minute;
    if (endMins <= startMins) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    final data = ActivityFormData(
      name: _nameController.text.trim(),
      time: _fmtTime(_startTime),
      duration: _durationLabel,
      cost: double.parse(_costController.text.trim()),
    );

    Navigator.pop(context, data);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Text(
                'Add Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade700,
                ),
              ),
              const SizedBox(height: 20),

              // Activity name
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Activity Name',
                  prefixIcon: Icon(Icons.local_activity_outlined),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter an activity name' : null,
              ),
              const SizedBox(height: 16),

              // Category chips
              const Text('Category', style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _categories.map((cat) {
                  final selected = cat == _selectedCategory;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: selected,
                    selectedColor: Colors.teal,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black,
                      fontSize: 13,
                    ),
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Time row
              const Text('Time Window', style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _TimeTile(
                      label: 'Start',
                      time: _fmtTime(_startTime),
                      onTap: () => _pickTime(isStart: true),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.arrow_forward, color: Colors.grey, size: 18),
                  ),
                  Expanded(
                    child: _TimeTile(
                      label: 'End',
                      time: _fmtTime(_endTime),
                      onTap: () => _pickTime(isStart: false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Duration badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _durationLabel,
                      style: const TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Cost
              TextFormField(
                controller: _costController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Cost per person (USD)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter a cost (0 if free)';
                  if (double.tryParse(v.trim()) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _submit,
                child: const Text('Add to Itinerary'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Tappable time display tile
class _TimeTile extends StatelessWidget {
  const _TimeTile({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 2),
            Text(time,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}