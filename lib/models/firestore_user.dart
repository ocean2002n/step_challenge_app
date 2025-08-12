import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore 用戶資料模型
/// 用於 Firebase 資料庫存儲和同步
class FirestoreUser {
  final String uid;
  final String? email;
  final String? nickname;
  final String? gender;
  final DateTime? birthDate;
  final double? height;
  final double? weight;
  final String? profilePhotoUrl;
  final DateTime registrationDate;
  final DateTime lastUpdated;
  final Map<String, dynamic>? preferences;
  final Map<String, dynamic>? socialAccounts;
  
  const FirestoreUser({
    required this.uid,
    this.email,
    this.nickname,
    this.gender,
    this.birthDate,
    this.height,
    this.weight,
    this.profilePhotoUrl,
    required this.registrationDate,
    required this.lastUpdated,
    this.preferences,
    this.socialAccounts,
  });

  /// 從 Firestore 文檔創建用戶對象
  factory FirestoreUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Document data is null');
    }

    return FirestoreUser(
      uid: doc.id,
      email: data['email'] as String?,
      nickname: data['nickname'] as String?,
      gender: data['gender'] as String?,
      birthDate: data['birthDate'] != null 
          ? (data['birthDate'] as Timestamp).toDate()
          : null,
      height: (data['height'] as num?)?.toDouble(),
      weight: (data['weight'] as num?)?.toDouble(),
      profilePhotoUrl: data['profilePhotoUrl'] as String?,
      registrationDate: (data['registrationDate'] as Timestamp).toDate(),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      preferences: data['preferences'] as Map<String, dynamic>?,
      socialAccounts: data['socialAccounts'] as Map<String, dynamic>?,
    );
  }

  /// 轉換為 Firestore 文檔格式
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'nickname': nickname,
      'gender': gender,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'height': height,
      'weight': weight,
      'profilePhotoUrl': profilePhotoUrl,
      'registrationDate': Timestamp.fromDate(registrationDate),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'preferences': preferences ?? {},
      'socialAccounts': socialAccounts ?? {},
    };
  }

  /// 創建副本並更新指定字段
  FirestoreUser copyWith({
    String? uid,
    String? email,
    String? nickname,
    String? gender,
    DateTime? birthDate,
    double? height,
    double? weight,
    String? profilePhotoUrl,
    DateTime? registrationDate,
    DateTime? lastUpdated,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? socialAccounts,
  }) {
    return FirestoreUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      registrationDate: registrationDate ?? this.registrationDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      preferences: preferences ?? this.preferences,
      socialAccounts: socialAccounts ?? this.socialAccounts,
    );
  }

  /// 獲取用戶年齡
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month || 
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  /// 計算 BMI
  double? get bmi {
    if (height == null || weight == null || height! <= 0) return null;
    final heightInMeters = height! / 100;
    return weight! / (heightInMeters * heightInMeters);
  }

  /// 獲取 BMI 分類
  String get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) return '未知';
    
    if (bmiValue < 18.5) return '體重過輕';
    if (bmiValue < 24) return '正常體重';
    if (bmiValue < 27) return '體重過重';
    if (bmiValue < 30) return '輕度肥胖';
    if (bmiValue < 35) return '中度肥胖';
    return '重度肥胖';
  }

  @override
  String toString() {
    return 'FirestoreUser(uid: $uid, email: $email, nickname: $nickname)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FirestoreUser && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}

/// 用戶偏好設定模型
class UserPreferences {
  final String language;
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final String stepGoal;
  final Map<String, bool> notificationTypes;
  
  const UserPreferences({
    this.language = 'zh',
    this.notificationsEnabled = true,
    this.darkModeEnabled = false,
    this.stepGoal = '10000',
    this.notificationTypes = const {
      'daily_reminder': true,
      'goal_achieved': true,
      'friend_challenge': true,
      'weekly_summary': true,
    },
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      language: map['language'] as String? ?? 'zh',
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      darkModeEnabled: map['darkModeEnabled'] as bool? ?? false,
      stepGoal: map['stepGoal'] as String? ?? '10000',
      notificationTypes: Map<String, bool>.from(
        map['notificationTypes'] as Map<String, dynamic>? ?? {
          'daily_reminder': true,
          'goal_achieved': true,
          'friend_challenge': true,
          'weekly_summary': true,
        }
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'language': language,
      'notificationsEnabled': notificationsEnabled,
      'darkModeEnabled': darkModeEnabled,
      'stepGoal': stepGoal,
      'notificationTypes': notificationTypes,
    };
  }

  UserPreferences copyWith({
    String? language,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    String? stepGoal,
    Map<String, bool>? notificationTypes,
  }) {
    return UserPreferences(
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      stepGoal: stepGoal ?? this.stepGoal,
      notificationTypes: notificationTypes ?? this.notificationTypes,
    );
  }
}

/// 社交帳戶資訊模型
class SocialAccountInfo {
  final String provider; // 'google', 'apple'
  final String providerId;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final DateTime linkedAt;
  
  const SocialAccountInfo({
    required this.provider,
    required this.providerId,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.linkedAt,
  });

  factory SocialAccountInfo.fromMap(Map<String, dynamic> map) {
    return SocialAccountInfo(
      provider: map['provider'] as String,
      providerId: map['providerId'] as String,
      email: map['email'] as String?,
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      linkedAt: (map['linkedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'provider': provider,
      'providerId': providerId,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'linkedAt': Timestamp.fromDate(linkedAt),
    };
  }
}