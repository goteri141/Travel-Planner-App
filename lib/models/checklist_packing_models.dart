// ── Checklist item ────────────────────────────────────────────────────────────

class ChecklistItemModel {
  final String id;
  final String label;
  final bool isDone;
  final String? completedBy; // userId of who checked it off, null if undone

  const ChecklistItemModel({
    required this.id,
    required this.label,
    this.isDone = false,
    this.completedBy,
  });

  factory ChecklistItemModel.fromMap(String id, Map<String, dynamic> map) =>
      ChecklistItemModel(
        id: id,
        label: map['label'] ?? '',
        isDone: map['isDone'] ?? false,
        completedBy: map['completedBy'],
      );

  Map<String, dynamic> toMap() => {
        'label': label,
        'isDone': isDone,
        'completedBy': completedBy,
      };
}

// ── Packing item ──────────────────────────────────────────────────────────────

class PackingItemModel {
  final String id;
  final String label;
  final String? assignedTo; // userId, null = unassigned
  final bool isClaimed;

  const PackingItemModel({
    required this.id,
    required this.label,
    this.assignedTo,
    this.isClaimed = false,
  });

  factory PackingItemModel.fromMap(String id, Map<String, dynamic> map) =>
      PackingItemModel(
        id: id,
        label: map['label'] ?? '',
        assignedTo: map['assignedTo'],
        isClaimed: map['isClaimed'] ?? false,
      );

  Map<String, dynamic> toMap() => {
        'label': label,
        'assignedTo': assignedTo,
        'isClaimed': isClaimed,
      };
}