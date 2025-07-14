class DailySteps {
  final String userId;
  final DateTime date;
  final int steps;
  final bool goalAchieved;
  final DateTime syncTime;
  final String deviceType;

  DailySteps({
    required this.userId,
    required this.date,
    required this.steps,
    required this.goalAchieved,
    required this.syncTime,
    required this.deviceType,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'steps': steps,
      'goal_achieved': goalAchieved,
      'sync_timestamp': syncTime.toIso8601String(),
      'device_type': deviceType,
    };
  }

  factory DailySteps.fromJson(Map<String, dynamic> json) {
    return DailySteps(
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      steps: json['steps'],
      goalAchieved: json['goal_achieved'],
      syncTime: DateTime.parse(json['sync_timestamp']),
      deviceType: json['device_type'],
    );
  }

  DailySteps copyWith({
    String? userId,
    DateTime? date,
    int? steps,
    bool? goalAchieved,
    DateTime? syncTime,
    String? deviceType,
  }) {
    return DailySteps(
      userId: userId ?? this.userId,
      date: date ?? this.date,
      steps: steps ?? this.steps,
      goalAchieved: goalAchieved ?? this.goalAchieved,
      syncTime: syncTime ?? this.syncTime,
      deviceType: deviceType ?? this.deviceType,
    );
  }
}