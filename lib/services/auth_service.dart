import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'social_auth_service.dart';
import 'crashlytics_service.dart';

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
  String? _nickname;
  String? _email;
  String? _gender;
  DateTime? _birthDate;
  double? _height;
  double? _weight;
  String? _profilePhotoUrl;
  
  bool get isFirstLaunch => _isFirstLaunch;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isUserRegistered => _isUserRegistered;
  String? get userId => _userId;
  DateTime? get registrationDate => _registrationDate;
  String? get nickname => _nickname;
  String? get email => _email;
  String? get gender => _gender;
  DateTime? get birthDate => _birthDate;
  double? get height => _height;
  double? get weight => _weight;
  String? get profilePhotoUrl => _profilePhotoUrl;
  
  /// 初始化認證服務
  Future<void> initialize() async {
    await _loadAuthState();
  }
  
  /// 載入認證狀態
  Future<void> _loadAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _isFirstLaunch = prefs.getBool(_isFirstLaunchKey) ?? true;
      _hasCompletedOnboarding = prefs.getBool(_hasCompletedOnboardingKey) ?? false;
      _isUserRegistered = prefs.getBool(_userRegisteredKey) ?? false;
      _userId = prefs.getString(_userIdKey);
      
      _nickname = prefs.getString('nickname');
      _email = prefs.getString('email');
      _gender = prefs.getString('gender');
      final birthDateString = prefs.getString('birthDate');
      if (birthDateString != null) {
        _birthDate = DateTime.parse(birthDateString);
      }
      _height = prefs.getDouble('height');
      _weight = prefs.getDouble('weight');
      _profilePhotoUrl = prefs.getString('profilePhotoUrl');
      
      final regDateString = prefs.getString(_registrationDateKey);
      if (regDateString != null) {
        _registrationDate = DateTime.parse(regDateString);
      }
      
      debugPrint('🔐 Auth state loaded: firstLaunch=$_isFirstLaunch, onboarded=$_hasCompletedOnboarding, registered=$_isUserRegistered');
      
      // Set user identifier for Crashlytics if user is registered
      if (_isUserRegistered && _userId != null) {
        await CrashlyticsService.setUserIdentifier(_userId!);
      }
      
      notifyListeners();
    } catch (e, stack) {
      await CrashlyticsService.recordError(e, stack, reason: 'Loading auth state failed');
      debugPrint('Error loading auth state: $e');
      // Set default values on error
      _isFirstLaunch = true;
      _hasCompletedOnboarding = false;
      _isUserRegistered = false;
      notifyListeners();
    }
  }
  
  /// 標記首次啟動完成
  Future<void> markFirstLaunchCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isFirstLaunchKey, false);
      
      _isFirstLaunch = false;
      debugPrint('✅ First launch marked as completed');
      notifyListeners();
    } catch (e, stack) {
      await CrashlyticsService.recordError(e, stack, reason: 'Marking first launch completed failed');
      debugPrint('Error marking first launch completed: $e');
    }
  }
  
  /// 完成引導流程
  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasCompletedOnboardingKey, true);
      
      _hasCompletedOnboarding = true;
      debugPrint('✅ Onboarding completed');
      notifyListeners();
    } catch (e, stack) {
      await CrashlyticsService.recordError(e, stack, reason: 'Completing onboarding failed');
      debugPrint('Error completing onboarding: $e');
    }
  }
  
  /// 用戶註冊
  Future<void> registerUser({
    required String nickname,
    required String email,
    required String gender,
    required DateTime birthDate,
    required double height,
    required double weight,
    String? profilePhotoUrl,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = _generateUserId();
      final now = DateTime.now();
      
      // 保存註冊狀態
      await prefs.setBool(_userRegisteredKey, true);
      await prefs.setString(_userIdKey, userId);
      await prefs.setString(_registrationDateKey, now.toIso8601String());
      
      // 保存用戶基本資料
      await prefs.setString('nickname', nickname);
      await prefs.setString('email', email);
      await prefs.setString('gender', gender);
      await prefs.setString('birthDate', birthDate.toIso8601String());
      await prefs.setDouble('height', height);
      await prefs.setDouble('weight', weight);
      if (profilePhotoUrl != null) {
        await prefs.setString('profilePhotoUrl', profilePhotoUrl);
      }
      
      _isUserRegistered = true;
      _userId = userId;
      _registrationDate = now;
      _nickname = nickname;
      _email = email;
      _gender = gender;
      _birthDate = birthDate;
      _height = height;
      _weight = weight;
      _profilePhotoUrl = profilePhotoUrl;
      
      // Set user identifier for Crashlytics
      await CrashlyticsService.setUserIdentifier(userId);
    
      debugPrint('✅ User registered successfully: $userId');
      notifyListeners();
    } catch (e, stack) {
      await CrashlyticsService.recordError(e, stack, reason: 'User registration failed');
      debugPrint('Error registering user: $e');
      rethrow;
    }
  }

  /// 使用社群登入註冊用戶
  Future<void> registerWithSocialLogin({
    required LinkedAccount socialAccount,
    String? gender,
    DateTime? birthDate,
    double? height,
    double? weight,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = _generateUserId();
      final now = DateTime.now();
      
      // 保存註冊狀態
      await prefs.setBool(_userRegisteredKey, true);
      await prefs.setString(_userIdKey, userId);
      await prefs.setString(_registrationDateKey, now.toIso8601String());
      
      // 保存社群登入資料
      final nickname = socialAccount.displayName ?? socialAccount.email?.split('@').first ?? 'User';
      final email = socialAccount.email ?? '';
      
      await prefs.setString('nickname', nickname);
      await prefs.setString('email', email);
      if (gender != null) await prefs.setString('gender', gender);
      if (birthDate != null) await prefs.setString('birthDate', birthDate.toIso8601String());
      if (height != null) await prefs.setDouble('height', height);
      if (weight != null) await prefs.setDouble('weight', weight);
      if (socialAccount.photoUrl != null) {
        await prefs.setString('profilePhotoUrl', socialAccount.photoUrl!);
      }
      
      _isUserRegistered = true;
      _userId = userId;
      _registrationDate = now;
      _nickname = nickname;
      _email = email;
      _gender = gender;
      _birthDate = birthDate;
      _height = height;
      _weight = weight;
      _profilePhotoUrl = socialAccount.photoUrl;
      
      // Set user identifier for Crashlytics
      await CrashlyticsService.setUserIdentifier(userId);
    
      debugPrint('✅ User registered with ${socialAccount.provider.name} login: $userId');
      notifyListeners();
    } catch (e, stack) {
      await CrashlyticsService.recordError(e, stack, reason: 'Social login registration failed');
      debugPrint('Error registering with social login: $e');
      rethrow;
    }
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
  
  /// 初步註冊社群登入用戶（不標記為完全註冊）
  Future<void> initSocialLoginUser({
    required LinkedAccount socialAccount,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = _generateUserId();
      final now = DateTime.now();
      
      // 保存基本註冊狀態（但不標記為完全註冊）
      await prefs.setString(_userIdKey, userId);
      await prefs.setString(_registrationDateKey, now.toIso8601String());
      
      // 保存社群登入資料
      final nickname = socialAccount.displayName ?? socialAccount.email?.split('@').first ?? 'User';
      final email = socialAccount.email ?? '';
      
      await prefs.setString('nickname', nickname);
      await prefs.setString('email', email);
      if (socialAccount.photoUrl != null) {
        await prefs.setString('profilePhotoUrl', socialAccount.photoUrl!);
      }
      
      // 更新內存狀態（但 _isUserRegistered 保持 false）
      _userId = userId;
      _registrationDate = now;
      _nickname = nickname;
      _email = email;
      _profilePhotoUrl = socialAccount.photoUrl;
      
      debugPrint('✅ Social login user initialized: $userId (incomplete registration)');
      notifyListeners();
    } catch (e, stack) {
      await CrashlyticsService.recordError(e, stack, reason: 'Social login user initialization failed');
      debugPrint('Error initializing social login user: $e');
      rethrow;
    }
  }

  /// 完成社群登入用戶註冊
  Future<void> completeSocialLoginRegistration({
    String? gender,
    DateTime? birthDate,
    double? height,
    double? weight,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 保存完整註冊狀態
      await prefs.setBool(_userRegisteredKey, true);
      
      if (gender != null) await prefs.setString('gender', gender);
      if (birthDate != null) await prefs.setString('birthDate', birthDate.toIso8601String());
      if (height != null) await prefs.setDouble('height', height);
      if (weight != null) await prefs.setDouble('weight', weight);
      
      // 更新內存狀態
      _isUserRegistered = true;
      _gender = gender;
      _birthDate = birthDate;
      _height = height;
      _weight = weight;
      
      debugPrint('✅ Social login user registration completed: $_userId');
      notifyListeners();
    } catch (e, stack) {
      await CrashlyticsService.recordError(e, stack, reason: 'Completing social login registration failed');
      debugPrint('Error completing social login registration: $e');
      rethrow;
    }
  }

  /// 更新用戶資料照片
  Future<void> updateProfilePhoto(String? photoUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (photoUrl != null && photoUrl.isNotEmpty) {
        await prefs.setString('profilePhotoUrl', photoUrl);
        _profilePhotoUrl = photoUrl;
      } else {
        await prefs.remove('profilePhotoUrl');
        _profilePhotoUrl = null;
      }
      
      debugPrint('✅ Profile photo updated: $photoUrl');
      notifyListeners();
    } catch (e, stack) {
      await CrashlyticsService.recordError(e, stack, reason: 'Updating profile photo failed');
      debugPrint('Error updating profile photo: $e');
    }
  }

  /// 登出用戶
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      _isFirstLaunch = true;
      _hasCompletedOnboarding = false;
      _isUserRegistered = false;
      _userId = null;
      _registrationDate = null;
      _nickname = null;
      _email = null;
      _gender = null;
      _birthDate = null;
      _height = null;
      _weight = null;
      _profilePhotoUrl = null;
      
      debugPrint('🔐 User logged out');
      notifyListeners();
    } catch (e, stack) {
      await CrashlyticsService.recordError(e, stack, reason: 'User logout failed');
      debugPrint('Error logging out user: $e');
    }
  }

  /// 重置用戶數據（僅用於測試）
  Future<void> resetUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      _isFirstLaunch = true;
      _hasCompletedOnboarding = false;
      _isUserRegistered = false;
      _userId = null;
      _registrationDate = null;
      _nickname = null;
      _email = null;
      _gender = null;
      _birthDate = null;
      _height = null;
      _weight = null;
      _profilePhotoUrl = null;
      
      debugPrint('🔄 User data reset');
      notifyListeners();
    } catch (e, stack) {
      await CrashlyticsService.recordError(e, stack, reason: 'Reset user data failed');
      debugPrint('Error resetting user data: $e');
    }
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