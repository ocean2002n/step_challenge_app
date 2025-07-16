class Friend {
  final String id;
  final String nickname;
  final String? avatarPath;
  final DateTime addedDate;
  final Map<String, int> monthlySteps; // Format: 'YYYY-MM' -> steps
  
  Friend({
    required this.id,
    required this.nickname,
    this.avatarPath,
    required this.addedDate,
    this.monthlySteps = const {},
  });

  // Create friend from JSON
  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      avatarPath: json['avatarPath'] as String?,
      addedDate: DateTime.parse(json['addedDate'] as String),
      monthlySteps: Map<String, int>.from(json['monthlySteps'] ?? {}),
    );
  }

  // Convert friend to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'avatarPath': avatarPath,
      'addedDate': addedDate.toIso8601String(),
      'monthlySteps': monthlySteps,
    };
  }

  // Create a copy with updated values
  Friend copyWith({
    String? id,
    String? nickname,
    String? avatarPath,
    DateTime? addedDate,
    Map<String, int>? monthlySteps,
  }) {
    return Friend(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatarPath: avatarPath ?? this.avatarPath,
      addedDate: addedDate ?? this.addedDate,
      monthlySteps: monthlySteps ?? this.monthlySteps,
    );
  }

  // Get steps for current month
  int get currentMonthSteps {
    final currentMonth = DateTime.now();
    final monthKey = '${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}';
    return monthlySteps[monthKey] ?? 0;
  }

  // Get steps for specific month
  int getStepsForMonth(DateTime month) {
    final monthKey = '${month.year}-${month.month.toString().padLeft(2, '0')}';
    return monthlySteps[monthKey] ?? 0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Friend && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Friend(id: $id, nickname: $nickname, currentMonthSteps: $currentMonthSteps)';
  }
}

class FriendInvite {
  final String inviterId;
  final String inviterNickname;
  final String? inviterAvatarPath;
  final DateTime createdDate;
  final String inviteCode;
  
  FriendInvite({
    required this.inviterId,
    required this.inviterNickname,
    this.inviterAvatarPath,
    required this.createdDate,
    required this.inviteCode,
  });

  factory FriendInvite.fromJson(Map<String, dynamic> json) {
    return FriendInvite(
      inviterId: json['inviterId'] as String,
      inviterNickname: json['inviterNickname'] as String,
      inviterAvatarPath: json['inviterAvatarPath'] as String?,
      createdDate: DateTime.parse(json['createdDate'] as String),
      inviteCode: json['inviteCode'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inviterId': inviterId,
      'inviterNickname': inviterNickname,
      'inviterAvatarPath': inviterAvatarPath,
      'createdDate': createdDate.toIso8601String(),
      'inviteCode': inviteCode,
    };
  }
}