class ActivityModel {
  final String id;
  final String name;
  final String category;
  final int startMinutes;  // minutes from midnight e.g. 9:00 AM = 540
  final int endMinutes;    // used by optimizer for time-window scoring
  final double cost;
  final int orderIndex;    // position within the trip activity list

  const ActivityModel({
    required this.id,
    required this.name,
    required this.category,
    required this.startMinutes,
    required this.endMinutes,
    required this.cost,
    required this.orderIndex,
  });

  // Display helpers
  String get startTimeLabel => _fmtMinutes(startMinutes);
  String get endTimeLabel => _fmtMinutes(endMinutes);
  String get durationLabel {
    final diff = endMinutes - startMinutes;
    if (diff <= 0) return '—';
    final h = diff ~/ 60;
    final m = diff % 60;
    if (h == 0) return '${m}min';
    if (m == 0) return '${h}h';
    return '${h}h ${m}min';
  }

  static String _fmtMinutes(int mins) {
    final h = mins ~/ 60;
    final m = mins % 60;
    final period = h < 12 ? 'AM' : 'PM';
    final displayH = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$displayH:${m.toString().padLeft(2, '0')} $period';
  }

  factory ActivityModel.fromMap(String id, Map<String, dynamic> map) =>
      ActivityModel(
        id: id,
        name: map['name'] ?? '',
        category: map['category'] ?? '',
        startMinutes: map['startMinutes'] ?? 0,
        endMinutes: map['endMinutes'] ?? 0,
        cost: (map['cost'] as num).toDouble(),
        orderIndex: map['orderIndex'] ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'category': category,
        'startMinutes': startMinutes,
        'endMinutes': endMinutes,
        'cost': cost,
        'orderIndex': orderIndex,
      };

  ActivityModel withOrder(int newOrder) => ActivityModel(
        id: id,
        name: name,
        category: category,
        startMinutes: startMinutes,
        endMinutes: endMinutes,
        cost: cost,
        orderIndex: newOrder,
      );
}