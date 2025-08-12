import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import 'crashlytics_service.dart';

/// Firebase Authentication 服務
/// 提供完整的認證功能，包括 Google 和 Apple 登入
class FirebaseAuthService extends ChangeNotifier {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  User? _currentUser;
  StreamSubscription<User?>? _authStateSubscription;

  /// 當前 Firebase 用戶
  User? get currentUser => _currentUser;

  /// 檢查是否已認證
  bool get isAuthenticated => _currentUser != null;

  /// 用戶唯一 ID
  String? get uid => _currentUser?.uid;

  /// 用戶電子郵件
  String? get email => _currentUser?.email;

  /// 用戶顯示名稱
  String? get displayName => _currentUser?.displayName;

  /// 用戶頭像 URL
  String? get photoURL => _currentUser?.photoURL;

  /// 初始化服務並開始監聽認證狀態變化
  Future<void> initialize() async {
    try {
      debugPrint('🔥 Initializing Firebase Auth Service...');
      
      // 獲取當前用戶狀態
      _currentUser = _firebaseAuth.currentUser;
      
      // 開始監聽認證狀態變化
      _authStateSubscription = _firebaseAuth.authStateChanges().listen(
        _onAuthStateChanged,
        onError: (error) async {
          debugPrint('❌ Auth state change error: $error');
          await CrashlyticsService.recordError(error, StackTrace.current, reason: 'Auth state change error');
        },
      );
      
      debugPrint('✅ Firebase Auth Service initialized. Current user: ${_currentUser?.uid ?? 'None'}');
    } catch (error) {
      debugPrint('❌ Firebase Auth Service initialization failed: $error');
      await CrashlyticsService.recordError(error, StackTrace.current, reason: 'Firebase Auth Service init failed');
    }
  }

  /// 處理認證狀態變化
  void _onAuthStateChanged(User? user) {
    try {
      _currentUser = user;
      
      if (user != null) {
        debugPrint('🔥 Auth state changed: User signed in (${user.uid})');
        CrashlyticsService.setUserIdentifier(user.uid);
      } else {
        debugPrint('🔥 Auth state changed: User signed out');
        CrashlyticsService.setUserIdentifier('');
      }
      
      notifyListeners();
    } catch (error) {
      debugPrint('❌ Error handling auth state change: $error');
      CrashlyticsService.recordError(error, StackTrace.current, reason: 'Auth state change handling failed');
    }
  }

  /// 釋放資源
  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  /// 使用 Google 登入
  Future<UserCredential?> signInWithGoogle() async {
    try {
      debugPrint('🔍 Starting Google Sign-In...');

      // 觸發認證流程
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        debugPrint('❌ Google sign in cancelled by user');
        return null;
      }

      // 獲取認證詳細資訊
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 創建新的認證憑證
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 使用憑證登入 Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      debugPrint('✅ Google sign in successful: ${userCredential.user?.email}');
      debugPrint('   UID: ${userCredential.user?.uid}');
      debugPrint('   Display Name: ${userCredential.user?.displayName}');
      debugPrint('   Photo URL: ${userCredential.user?.photoURL}');
      
      await CrashlyticsService.recordUserAction('google_sign_in_success');
      await CrashlyticsService.setUserIdentifier(userCredential.user?.uid ?? '');
      
      return userCredential;

    } catch (error) {
      debugPrint('❌ Google sign in error: $error');
      await CrashlyticsService.recordError(error, StackTrace.current, reason: 'Google sign in failed');
      rethrow;
    }
  }

  /// 使用 Apple 登入
  Future<UserCredential?> signInWithApple() async {
    try {
      debugPrint('🍎 Starting Apple Sign-In...');

      // 檢查 Apple Sign In 是否可用
      if (!await SignInWithApple.isAvailable()) {
        debugPrint('❌ Apple Sign In not available on this device');
        throw Exception('Apple Sign In 在此裝置上不支援');
      }

      // 生成隨機數用於安全驗證
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // 請求 Apple ID 認證
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // 創建 OAuth 認證憑證
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // 使用憑證登入 Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(oauthCredential);
      
      debugPrint('✅ Apple sign in successful: ${userCredential.user?.email}');
      debugPrint('   UID: ${userCredential.user?.uid}');
      debugPrint('   Display Name: ${userCredential.user?.displayName}');
      
      await CrashlyticsService.recordUserAction('apple_sign_in_success');
      await CrashlyticsService.setUserIdentifier(userCredential.user?.uid ?? '');
      
      return userCredential;

    } catch (error) {
      debugPrint('❌ Apple sign in error: $error');
      await CrashlyticsService.recordError(error, StackTrace.current, reason: 'Apple sign in failed');
      rethrow;
    }
  }

  /// 使用電子郵件和密碼登入
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      debugPrint('📧 Starting email/password sign in...');
      
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      debugPrint('✅ Email sign in successful: ${userCredential.user?.email}');
      
      await CrashlyticsService.recordUserAction('email_sign_in_success');
      await CrashlyticsService.setUserIdentifier(userCredential.user?.uid ?? '');
      
      return userCredential;
      
    } catch (error) {
      debugPrint('❌ Email sign in error: $error');
      await CrashlyticsService.recordError(error, StackTrace.current, reason: 'Email sign in failed');
      rethrow;
    }
  }

  /// 使用電子郵件和密碼創建用戶
  Future<UserCredential?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      debugPrint('📧 Creating user with email/password...');
      
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      debugPrint('✅ User created successfully: ${userCredential.user?.email}');
      
      await CrashlyticsService.recordUserAction('email_registration_success');
      await CrashlyticsService.setUserIdentifier(userCredential.user?.uid ?? '');
      
      return userCredential;
      
    } catch (error) {
      debugPrint('❌ User creation error: $error');
      await CrashlyticsService.recordError(error, StackTrace.current, reason: 'User creation failed');
      rethrow;
    }
  }

  /// 發送電子郵件驗證
  Future<void> sendEmailVerification() async {
    try {
      if (_currentUser != null && !_currentUser!.emailVerified) {
        await _currentUser!.sendEmailVerification();
        debugPrint('✅ Email verification sent');
        await CrashlyticsService.recordUserAction('email_verification_sent');
      }
    } catch (error) {
      debugPrint('❌ Email verification error: $error');
      await CrashlyticsService.recordError(error, StackTrace.current, reason: 'Email verification failed');
      rethrow;
    }
  }

  /// 發送密碼重設電子郵件
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      debugPrint('✅ Password reset email sent to $email');
      await CrashlyticsService.recordUserAction('password_reset_sent');
    } catch (error) {
      debugPrint('❌ Password reset error: $error');
      await CrashlyticsService.recordError(error, StackTrace.current, reason: 'Password reset failed');
      rethrow;
    }
  }

  /// 更新用戶資料
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      if (_currentUser != null) {
        await _currentUser!.updateDisplayName(displayName);
        await _currentUser!.updatePhotoURL(photoURL);
        await _currentUser!.reload();
        _currentUser = _firebaseAuth.currentUser;
        notifyListeners();
        
        debugPrint('✅ User profile updated');
        await CrashlyticsService.recordUserAction('profile_updated');
      }
    } catch (error) {
      debugPrint('❌ Profile update error: $error');
      await CrashlyticsService.recordError(error, StackTrace.current, reason: 'Profile update failed');
      rethrow;
    }
  }

  /// 獲取 ID Token 用於 API 認證
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      if (_currentUser != null) {
        return await _currentUser!.getIdToken(forceRefresh);
      }
      return null;
    } catch (error) {
      debugPrint('❌ Get ID token error: $error');
      await CrashlyticsService.recordError(error, StackTrace.current, reason: 'Get ID token failed');
      return null;
    }
  }

  /// 從所有提供商登出
  Future<void> signOut() async {
    try {
      debugPrint('🔓 Signing out...');
      
      // 從 Google 登出（如果已連接）
      try {
        await _googleSignIn.signOut();
        debugPrint('🔓 Google Sign-In signed out');
      } catch (e) {
        debugPrint('⚠️ Google sign out error (non-critical): $e');
      }
      
      // 從 Firebase 登出
      await _firebaseAuth.signOut();
      
      debugPrint('✅ Sign out successful');
      await CrashlyticsService.recordUserAction('sign_out');
      await CrashlyticsService.setUserIdentifier('');
      
    } catch (error) {
      debugPrint('❌ Sign out error: $error');
      await CrashlyticsService.recordError(error, StackTrace.current, reason: 'Sign out failed');
      rethrow;
    }
  }

  /// 刪除用戶帳戶
  Future<void> deleteAccount() async {
    try {
      if (_currentUser != null) {
        await _currentUser!.delete();
        debugPrint('✅ User account deleted');
        await CrashlyticsService.recordUserAction('account_deleted');
      }
    } catch (error) {
      debugPrint('❌ Account deletion error: $error');
      await CrashlyticsService.recordError(error, StackTrace.current, reason: 'Account deletion failed');
      rethrow;
    }
  }

  /// 重新認證用戶（用於敏感操作）
  Future<void> reauthenticateWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google re-authentication cancelled');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _currentUser?.reauthenticateWithCredential(credential);
      debugPrint('✅ Re-authentication successful');
    } catch (error) {
      debugPrint('❌ Re-authentication error: $error');
      await CrashlyticsService.recordError(error, StackTrace.current, reason: 'Re-authentication failed');
      rethrow;
    }
  }

  /// 產生隨機數字串用於 Apple Sign In
  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// 計算字串的 SHA256 雜湊值
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// 處理 Firebase Auth 例外並提供友善的錯誤訊息
  String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return '找不到此電子郵件對應的帳號';
        case 'wrong-password':
          return '密碼錯誤';
        case 'email-already-in-use':
          return '此電子郵件已被使用';
        case 'weak-password':
          return '密碼強度不足';
        case 'invalid-email':
          return '電子郵件格式不正確';
        case 'user-disabled':
          return '此帳號已被停用';
        case 'too-many-requests':
          return '請求過於頻繁，請稍後再試';
        case 'operation-not-allowed':
          return '此登入方式未啟用';
        case 'account-exists-with-different-credential':
          return '此電子郵件已使用其他登入方式註冊';
        case 'invalid-credential':
          return '認證資訊無效';
        case 'credential-already-in-use':
          return '此認證已被其他帳號使用';
        case 'requires-recent-login':
          return '需要重新登入以完成此操作';
        default:
          return '登入失敗：${error.message}';
      }
    }
    return '發生未知錯誤：${error.toString()}';
  }
}