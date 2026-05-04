import 'package:flutter/material.dart';

// Data class for a scored activity result
// TODO: swap for your ActivityModel + optimizer_service output
class ScoredActivity {
  final String name;
  final String time;
  final String duration;
  final double cost;
  final int score;         // 0–100
  final String reason;     // why it was placed here
  final int originalIndex; // where it was before

  const ScoredActivity({
    required this.name,
    required this.time,
    required this.duration,
    required this.cost,
    required this.score,
    required this.reason,
    required this.originalIndex,
  });
}

class OptimizerScreen extends StatefulWidget {
  const OptimizerScreen({
    super.key,
    required this.activities, // pass in from itinerary tab
  });

  final List<Map<String, String>> activities;

  @override
  State<OptimizerScreen> createState() => _OptimizerScreenState();
}

class _OptimizerScreenState extends State<OptimizerScreen> {
  bool _hasRun = false;
  bool _isRunning = false;
  double _budgetLimit = 80;

  late List<ScoredActivity> _optimized;
  late List<Map<String, String>> _before;

  @override
  void initState() {
    super.initState();
    _before = List.from(widget.activities);
    _optimized = [];  
  }

  List<ScoredActivity> _optimizeActivities(List<Map<String, String>> input) {
    final parsed = input.asMap().entries.map((entry) {
      final index = entry.key;
      final a = entry.value;

      final cost = double.tryParse(
            (a['cost'] ?? '0').replaceAll(r'$', '').trim(),
          ) ??
          0;

      final minutes = _parseTimeToMinutes(a['time'] ?? '');

      final durationHours = _parseDurationHours(a['duration'] ?? '');

      final budgetScore = cost <= _budgetLimit
          ? 35
          : (35 - ((cost - _budgetLimit) / 10)).clamp(0, 35).round();

      final timeScore = minutes == null
          ? 10
          : minutes < 720
              ? 25
              : minutes < 1020
                  ? 20
                  : 15;

      final durationScore = durationHours <= 2
          ? 20
          : durationHours <= 4
              ? 15
              : 8;

      final originalOrderScore = 20 - index;

      final totalScore =
          (budgetScore + timeScore + durationScore + originalOrderScore)
              .clamp(0, 100);

      return ScoredActivity(
        name: a['name'] ?? '',
        time: a['time'] ?? '',
        duration: a['duration'] ?? '',
        cost: cost,
        score: totalScore,
        reason: _buildReason(
          cost: cost,
          minutes: minutes,
          durationHours: durationHours,
        ),
        originalIndex: index,
      );
    }).toList();

    parsed.sort((a, b) => b.score.compareTo(a.score));
    return parsed;
  }

  int? _parseTimeToMinutes(String time) {
  final cleaned = time.trim().toUpperCase();

  final match = RegExp(r'^(\d{1,2}):?(\d{2})?\s*(AM|PM)?$')
      .firstMatch(cleaned);

  if (match == null) return null;

  var hour = int.tryParse(match.group(1) ?? '');
  final minute = int.tryParse(match.group(2) ?? '0') ?? 0;
  final period = match.group(3);

  if (hour == null) return null;

  if (period == 'PM' && hour != 12) hour += 12;
  if (period == 'AM' && hour == 12) hour = 0;

  return hour * 60 + minute;
}

double _parseDurationHours(String duration) {
  final cleaned = duration.toLowerCase().trim();

  final hourMatch = RegExp(r'(\d+(\.\d+)?)\s*h').firstMatch(cleaned);
  if (hourMatch != null) {
    return double.tryParse(hourMatch.group(1) ?? '') ?? 1;
  }

  final minuteMatch = RegExp(r'(\d+)\s*m').firstMatch(cleaned);
  if (minuteMatch != null) {
    final minutes = double.tryParse(minuteMatch.group(1) ?? '') ?? 60;
    return minutes / 60;
  }

  return 1;
}

String _buildReason({
  required double cost,
  required int? minutes,
  required double durationHours,
}) {
  final reasons = <String>[];

  if (cost <= _budgetLimit) {
    reasons.add('Fits within the selected budget');
  } else {
    reasons.add('Lower priority because it exceeds the budget');
  }

  if (minutes != null && minutes < 720) {
    reasons.add('scheduled earlier in the day');
  } else if (minutes != null && minutes >= 1020) {
    reasons.add('better suited for later in the day');
  }

  if (durationHours <= 2) {
    reasons.add('short enough to fit easily into the itinerary');
  } else {
    reasons.add('longer activity, so it needs more schedule space');
  }

  return reasons.join(', ');
}

  Future<void> _runOptimizer() async {
    setState(() => _isRunning = true);

    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _optimized = _optimizeActivities(widget.activities);
      _isRunning = false;
      _hasRun = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Itinerary Optimizer'),
      ),
      body: Column(
        children: [
          // Controls panel
          Container(
            color: Colors.teal.shade50,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Constraints',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 12),

                // Budget slider
                Row(
                  children: [
                    const Icon(Icons.attach_money, size: 18, color: Colors.teal),
                    const SizedBox(width: 4),
                    Text(
                      'Budget limit: \$${_budgetLimit.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.teal,
                    thumbColor: Colors.teal,
                    inactiveTrackColor: Colors.teal.shade100,
                    overlayColor: Colors.teal.withOpacity(0.12),
                  ),
                  child: Slider(
                    value: _budgetLimit,
                    min: 0,
                    max: 300,
                    divisions: 30,
                    onChanged: (v) => setState(() {
                      _budgetLimit = v;
                      _hasRun = false; // prompt re-run when constraint changes
                    }),
                  ),
                ),

                const SizedBox(height: 4),

                // Run button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: _isRunning
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.auto_fix_high),
                    label: Text(_isRunning ? 'Optimizing…' : 'Run Optimizer'),
                    onPressed: _isRunning ? null : _runOptimizer,
                  ),
                ),

                if (!_hasRun && _optimized.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Adjust constraints above then tap Run Optimizer.',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),

          // Results area
          Expanded(
            child: _hasRun
                ? _ResultsView(before: _before, optimized: _optimized)
                : _EmptyState(hasActivities: widget.activities.isNotEmpty),
          ),
        ],
      ),
    );
  }
}

// ── Empty / pre-run state ─────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasActivities});
  final bool hasActivities;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.route, size: 64, color: Colors.teal.shade100),
            const SizedBox(height: 16),
            Text(
              hasActivities
                  ? 'Set your constraints and tap\nRun Optimizer to reorder your day.'
                  : 'Add activities to your itinerary first,\nthen run the optimizer.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Results: before/after + score cards ──────────────────────────────────────

class _ResultsView extends StatelessWidget {
  const _ResultsView({required this.before, required this.optimized});

  final List<Map<String, String>> before;
  final List<ScoredActivity> optimized;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Before / After header
        Row(
          children: [
            Expanded(
              child: Text(
                'Before',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward, color: Colors.teal, size: 20),
            Expanded(
              child: Text(
                'Optimized',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Side-by-side rows
        ...List.generate(optimized.length, (i) {
          final afterItem = optimized[i];
          final beforeItem = i < before.length ? before[i] : null;
          final moved = afterItem.originalIndex != i;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Before column
                Expanded(
                  child: _BeforeTile(
                    name: beforeItem?['name'] ?? '',
                    time: beforeItem?['time'] ?? '',
                    dimmed: moved,
                  ),
                ),
                const SizedBox(width: 8),
                // Move indicator
                Icon(
                  moved ? Icons.swap_vert : Icons.check,
                  color: moved ? Colors.orange : Colors.teal,
                  size: 18,
                ),
                const SizedBox(width: 8),
                // After column
                Expanded(
                  child: _AfterTile(activity: afterItem, moved: moved),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 20),
        Divider(color: Colors.teal.shade100),
        const SizedBox(height: 12),

        // Score explanation cards
        Text(
          'Why activities moved',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.teal.shade700,
          ),
        ),
        const SizedBox(height: 12),

        ...optimized.map((a) => _ScoreCard(activity: a)),
      ],
    );
  }
}

class _BeforeTile extends StatelessWidget {
  const _BeforeTile({
    required this.name,
    required this.time,
    required this.dimmed,
  });

  final String name;
  final String time;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: dimmed ? Colors.grey.shade100 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: dimmed ? Colors.grey : Colors.black,
              decoration: dimmed ? TextDecoration.lineThrough : null,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (time.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(time,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ],
      ),
    );
  }
}

class _AfterTile extends StatelessWidget {
  const _AfterTile({required this.activity, required this.moved});

  final ScoredActivity activity;
  final bool moved;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: moved ? Colors.teal.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: moved ? Colors.teal.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            activity.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: moved ? Colors.teal.shade800 : Colors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(activity.time,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const Spacer(),
              // Score badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${activity.score}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Score explanation card shown below the before/after comparison
class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.activity});

  final ScoredActivity activity;

  Color get _scoreColor {
    if (activity.score >= 85) return Colors.teal;
    if (activity.score >= 60) return Colors.orange;
    return Colors.red.shade400;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _scoreColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: _scoreColor, width: 2),
              ),
              child: Center(
                child: Text(
                  '${activity.score}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _scoreColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 12, color: Colors.grey),
                      const SizedBox(width: 3),
                      Text(
                        '${activity.time}  ·  ${activity.duration}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.attach_money, size: 12, color: Colors.grey),
                      Text(
                        '\$${activity.cost.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Explanation
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline,
                            size: 14, color: Colors.amber),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            activity.reason,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}