class UserModel {
  final String id;
  final String name;
  final String email;
  final List<String> tripIds;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.tripIds = const [],
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> map) => UserModel(
        id: id,
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        tripIds: List<String>.from(map['tripIds'] ?? []),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'tripIds': tripIds,
      };
}