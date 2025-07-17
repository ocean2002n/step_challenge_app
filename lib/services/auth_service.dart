import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  static const String _isFirstLaunchKey = 'is_first_launch';
  static const String _hasCompletedOnboardingKey = 'has_completed_onboarding';
  static const String _userRegisteredKey = 'user_registered';
  static const String _userIdKey = 'user_id';
  static const String _registrationDateKey = 'registration_date';
  
  bool _isFirstLaunch = true;
  bool _hasCompletedOnboarding = false;
  bool _isUserRegistered = false;
  String? _userId;
  DateTime? _registrationDate;
  
  bool get isFirstLaunch => _isFirstLaunch;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isUserRegistered => _isUserRegistered;
  String? get userId => _userId;
  DateTime? get registrationDate => _registrationDate;
  
  /// 初始化認證服務
  Future<void> initialize() async {
    await _loadAuthState();
  }
  
  /// 載入認證狀態
  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    
    _isFirstLaunch = prefs.getBool(_isFirstLaunchKey) ?? true;
    _hasCompletedOnboarding = prefs.getBool(_hasCompletedOnboardingKey) ?? false;
    _isUserRegistered = prefs.getBool(_userRegisteredKey) ?? false;
    _userId = prefs.getString(_userIdKey);
    
    final regDateString = prefs.getString(_registrationDateKey);
    if (regDateString != null) {
      _registrationDate = DateTime.parse(regDateString);
    }
    
    debugPrint('🔐 Auth state loaded: firstLaunch=$_isFirstLaunch, onboarded=$_hasCompletedOnboarding, registered=$_isUserRegistered');
    notifyListeners();
  }
  
  /// 標記首次啟動完成
  Future<void> markFirstLaunchCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstLaunchKey, false);
    
    _isFirstLaunch = false;
    debugPrint('✅ First launch marked as completed');
    notifyListeners();
  }
  
  /// 完成引導流程
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasCompletedOnboardingKey, true);
    
    _hasCompletedOnboarding = true;
    debugPrint('✅ Onboarding completed');
    notifyListeners();
  }
  
  /// 用戶註冊
  Future<void> registerUser({
    required String nickname,
    required String gender,
    required DateTime birthDate,
    required double height,
    required double weight,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = _generateUserId();
    final now = DateTime.now();
    
    // 保存註冊狀態
    await prefs.setBool(_userRegisteredKey, true);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_registrationDateKey, now.toIso8601String());
    
    // 保存用戶基本資料
    await prefs.setString('nickname', nickname);
    await prefs.setString('gender', gender);
    await prefs.setString('birthDate', birthDate.toIso8601String());
    await prefs.setDouble('height', height);
    await prefs.setDouble('weight', weight);
    
    _isUserRegistered = true;
    _userId = userId;
    _registrationDate = now;
    
    debugPrint('✅ User registered successfully: $userId');
    notifyListeners();
  }
  
  /// 檢查用戶是否需要完成設定
  bool needsSetup() {
    return _isFirstLaunch || !_hasCompletedOnboarding || !_isUserRegistered;
  }
  
  /// 獲取設定進度
  double getSetupProgress() {
    int completed = 0;
    int total = 3;
    
    if (!_isFirstLaunch) completed++;
    if (_hasCompletedOnboarding) completed++;
    if (_isUserRegistered) completed++;
    
    return completed / total;
  }
  
  /// 登出用戶
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    _isFirstLaunch = true;
    _hasCompletedOnboarding = false;
    _isUserRegistered = false;
    _userId = null;
    _registrationDate = null;
    
    debugPrint('🔐 User logged out');
    notifyListeners();
  }

  /// 重置用戶數據（僅用於測試）
  Future<void> resetUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    _isFirstLaunch = true;
    _hasCompletedOnboarding = false;
    _isUserRegistered = false;
    _userId = null;
    _registrationDate = null;
    
    debugPrint('🔄 User data reset');
    notifyListeners();
  }
  
  /// 生成用戶ID
  String _generateUserId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'user_$timestamp$random';
  }
  
  /// 獲取用戶年齡
  int? getUserAge() {
    if (_registrationDate == null) return null;
    
    final now = DateTime.now();
    return now.year - _registrationDate!.year;
  }
  
  /// 檢查是否為新用戶（註冊不到7天）
  bool isNewUser() {
    if (_registrationDate == null) return false;
    
    final daysSinceRegistration = DateTime.now().difference(_registrationDate!).inDays;
    return daysSinceRegistration <= 7;
  }
}