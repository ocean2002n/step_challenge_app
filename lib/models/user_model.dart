class User {
  final String id;
  final String name;
  final String email;
  final int dailyGoal;
  final DateTime createdDate;
  final DateTime lastSync;
  final String timezone;
  final String? nickname;
  final String? avatarPath;
  final String? gender;
  final double? height;
  final double? weight;
  final DateTime? birthDate;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.dailyGoal,
    required this.createdDate,
    required this.lastSync,
    required this.timezone,
    this.nickname,
    this.avatarPath,
    this.gender,
    this.height,
    this.weight,
    this.birthDate,
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
      'nickname': nickname,
      'avatar_path': avatarPath,
      'gender': gender,
      'height': height,
      'weight': weight,
      'birth_date': birthDate?.toIso8601String(),
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
      nickname: json['nickname'],
      avatarPath: json['avatar_path'],
      gender: json['gender'],
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      birthDate: json['birth_date'] != null ? DateTime.parse(json['birth_date']) : null,
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
    String? nickname,
    String? avatarPath,
    String? gender,
    double? height,
    double? weight,
    DateTime? birthDate,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      createdDate: createdDate ?? this.createdDate,
      lastSync: lastSync ?? this.lastSync,
      timezone: timezone ?? this.timezone,
      nickname: nickname ?? this.nickname,
      avatarPath: avatarPath ?? this.avatarPath,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      birthDate: birthDate ?? this.birthDate,
    );
  }
}