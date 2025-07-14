enum ChallengeGoalType { daily, total, duration }
enum ChallengeStatus { active, completed, cancelled }

class Challenge {
  final String id;
  final String title;
  final String description;
  final String creatorId;
  final DateTime startDate;
  final DateTime endDate;
  final ChallengeGoalType goalType;
  final int goalValue;
  final ChallengeStatus status;
  final DateTime createdDate;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.creatorId,
    required this.startDate,
    required this.endDate,
    required this.goalType,
    required this.goalValue,
    required this.status,
    required this.createdDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'challenge_id': id,
      'title': title,
      'description': description,
      'creator_id': creatorId,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'goal_type': goalType.name,
      'goal_value': goalValue,
      'status': status.name,
      'created_date': createdDate.toIso8601String(),
    };
  }

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['challenge_id'],
      title: json['title'],
      description: json['description'],
      creatorId: json['creator_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      goalType: ChallengeGoalType.values.firstWhere(
        (e) => e.name == json['goal_type'],
      ),
      goalValue: json['goal_value'],
      status: ChallengeStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      createdDate: DateTime.parse(json['created_date']),
    );
  }

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    String? creatorId,
    DateTime? startDate,
    DateTime? endDate,
    ChallengeGoalType? goalType,
    int? goalValue,
    ChallengeStatus? status,
    DateTime? createdDate,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      goalType: goalType ?? this.goalType,
      goalValue: goalValue ?? this.goalValue,
      status: status ?? this.status,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}

class ChallengeParticipant {
  final String challengeId;
  final String userId;
  final DateTime joinedDate;
  final int currentProgress;
  final bool isCompleted;
  final DateTime? completionDate;

  ChallengeParticipant({
    required this.challengeId,
    required this.userId,
    required this.joinedDate,
    required this.currentProgress,
    required this.isCompleted,
    this.completionDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'challenge_id': challengeId,
      'user_id': userId,
      'joined_date': joinedDate.toIso8601String().split('T')[0],
      'current_progress': currentProgress,
      'is_completed': isCompleted,
      'completion_date': completionDate?.toIso8601String().split('T')[0] ?? '',
    };
  }

  factory ChallengeParticipant.fromJson(Map<String, dynamic> json) {
    return ChallengeParticipant(
      challengeId: json['challenge_id'],
      userId: json['user_id'],
      joinedDate: DateTime.parse(json['joined_date']),
      currentProgress: json['current_progress'],
      isCompleted: json['is_completed'],
      completionDate: json['completion_date'].isNotEmpty 
          ? DateTime.parse(json['completion_date']) 
          : null,
    );
  }
}