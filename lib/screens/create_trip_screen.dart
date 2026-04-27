import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  int _step = 0;

  // Form values
  final _nameController = TextEditingController();
  final _destinationController = TextEditingController();
  final _budgetController = TextEditingController();
  final _inviteController = TextEditingController();
  DateTimeRange? _dateRange;

  @override
  void dispose() {
    _nameController.dispose();
    _destinationController.dispose();
    _budgetController.dispose();
    _inviteController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      if (_step < 2) {
        setState(() => _step++);
      } else {
        _submit();
      }
    }
  }

  void _submit() {
    // TODO: write to Firestore via firestore_service.dart
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trip created!')),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Trip'),
      ),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(
              children: List.generate(3, (i) {
                final isActive = i == _step;
                final isDone = i < _step;
                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: (isActive || isDone)
                                ? Colors.teal
                                : Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      if (i < 2) const SizedBox(width: 4),
                    ],
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ['Trip Details', 'Dates & Budget', 'Invite'][_step],
                  style: TextStyle(
                    color: Colors.teal.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Step ${_step + 1} of 3',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),

          // Step content
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: [
                  _StepDetails(
                    nameController: _nameController,
                    destinationController: _destinationController,
                  ),
                  _StepDates(
                    budgetController: _budgetController,
                    dateRange: _dateRange,
                    onDatePicked: (range) =>
                        setState(() => _dateRange = range),
                  ),
                  _StepInvite(inviteController: _inviteController),
                ][_step],
              ),
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _step--),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.teal,
                        side: const BorderSide(color: Colors.teal),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    child: Text(_step < 2 ? 'Next' : 'Create Trip'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Step 1: Trip name + destination fields
class _StepDetails extends StatelessWidget {
  const _StepDetails({
    required this.nameController,
    required this.destinationController,
  });

  final TextEditingController nameController;
  final TextEditingController destinationController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Give your trip a name',
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 12),
        TextFormField(
          controller: nameController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Trip Name',
            prefixIcon: Icon(Icons.edit_outlined),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Enter a trip name' : null,
        ),
        const SizedBox(height: 20),
        const Text('Where are you going?',
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 12),
        TextFormField(
          controller: destinationController,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Destination',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Enter a destination' : null,
        ),
      ],
    );
  }
}

// Step 2: Dates + budget fields and pickers

class _StepDates extends StatelessWidget {
  const _StepDates({
    required this.budgetController,
    required this.dateRange,
    required this.onDatePicked,
  });

  final TextEditingController budgetController;
  final DateTimeRange? dateRange;
  final ValueChanged<DateTimeRange> onDatePicked;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('When are you travelling?',
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              builder: (context, child) => Theme(
                data: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
                child: child!,
              ),
            );
            if (picked != null) onDatePicked(picked);
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Travel Dates',
              prefixIcon: Icon(Icons.calendar_today_outlined),
            ),
            child: Text(
              dateRange == null
                  ? 'Select dates'
                  : '${_fmt(dateRange!.start)}  →  ${_fmt(dateRange!.end)}',
              style: TextStyle(
                color: dateRange == null ? Colors.grey : Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text('What is your total budget?',
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 12),
        TextFormField(
          controller: budgetController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Budget (USD)',
            prefixIcon: Icon(Icons.attach_money),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Enter a budget';
            if (double.tryParse(v) == null) return 'Enter a valid number';
            return null;
          },
        ),
      ],
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

// Step 3: Optional invite members field

class _StepInvite extends StatefulWidget {
  const _StepInvite({required this.inviteController});
  final TextEditingController inviteController;

  @override
  State<_StepInvite> createState() => _StepInviteState();
}

class _StepInviteState extends State<_StepInvite> {
  final List<String> _invited = [];

  void _addInvite() {
    final email = widget.inviteController.text.trim();
    if (email.isNotEmpty && email.contains('@')) {
      setState(() {
        _invited.add(email);
        widget.inviteController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Invite your travel group (optional)',
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.inviteController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  prefixIcon: Icon(Icons.person_add_outlined),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _addInvite,
              icon: const Icon(Icons.add_circle, color: Colors.teal, size: 32),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._invited.map(
          (email) => ListTile(
            dense: true,
            leading: const CircleAvatar(
              backgroundColor: Colors.teal,
              radius: 14,
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
            title: Text(email, style: const TextStyle(fontSize: 14)),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.grey),
              onPressed: () => setState(() => _invited.remove(email)),
            ),
          ),
        ),
        if (_invited.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'You can also invite members after creating the trip.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
      ],
    );
  }
}