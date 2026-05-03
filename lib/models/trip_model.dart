class TripModel {
  final String id;
  final String name;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final double budgetLimit;
  final List<String> memberIds;

  const TripModel({
    required this.id,
    required this.name,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.budgetLimit,
    this.memberIds = const [],
  });

  // Formatted date range for display e.g. "Jun 12 – Jun 20"
  String get dateRangeLabel {
    String fmt(DateTime d) {
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[d.month]} ${d.day}';
    }
    return '${fmt(startDate)} – ${fmt(endDate)}';
  }

  int get durationDays => endDate.difference(startDate).inDays + 1;

  factory TripModel.fromMap(String id, Map<String, dynamic> map) => TripModel(
        id: id,
        name: map['name'] ?? '',
        destination: map['destination'] ?? '',
        startDate: DateTime.parse(map['startDate']),
        endDate: DateTime.parse(map['endDate']),
        budgetLimit: (map['budgetLimit'] as num).toDouble(),
        memberIds: List<String>.from(map['memberIds'] ?? []),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'destination': destination,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'budgetLimit': budgetLimit,
        'memberIds': memberIds,
      };
}