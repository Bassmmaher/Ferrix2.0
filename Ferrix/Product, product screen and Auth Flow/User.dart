class User {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  bool isVerified;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    this.isVerified = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'isVerified': isVerified,
        'createdAt': createdAt.toIso8601String(),
      };

  // Never expose passwordHash when sending to client
  Map<String, dynamic> toSafeJson() => {
        'id': id,
        'name': name,
        'email': email,
        'isVerified': isVerified,
      };
}
