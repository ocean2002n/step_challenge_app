class User {
  final String id;
  final String name;
  final String email;
  final int dailyGoal;
  final DateTime createdDate;
  final DateTime lastSync;
  final String timezone;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.dailyGoal,
    required this.createdDate,
    required this.lastSync,
    required this.timezone,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'name': name,
      'email': email,
      'daily_goal': dailyGoal,
      'created_date': createdDate.toIso8601String(),
      'last_sync': lastSync.toIso8601String(),
      'timezone': timezone,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'],
      name: json['name'],
      email: json['email'],
      dailyGoal: json['daily_goal'],
      createdDate: DateTime.parse(json['created_date']),
      lastSync: DateTime.parse(json['last_sync']),
      timezone: json['timezone'],
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    int? dailyGoal,
    DateTime? createdDate,
    DateTime? lastSync,
    String? timezone,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      createdDate: createdDate ?? this.createdDate,
      lastSync: lastSync ?? this.lastSync,
      timezone: timezone ?? this.timezone,
    );
  }
}