import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:io' show Platform;
import 'crashlytics_service_stub.dart' as crashlytics;

enum SocialProvider { google, apple, facebook }

class SocialAuthResult {
  final bool success;
  final String? error;
  final LinkedAccount? account;

  SocialAuthResult({
    required this.success,
    this.error,
    this.account,
  });
}

class LinkedAccount {
  final SocialProvider provider;
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;

  LinkedAccount({
    required this.provider,
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'provider': provider.name,
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }

  factory LinkedAccount.fromJson(Map<String, dynamic> json) {
    return LinkedAccount(
      provider: SocialProvider.values.firstWhere(
        (e) => e.name == json['provider'],
        orElse: () => SocialProvider.apple,
      ),
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      photoUrl: json['photoUrl'],
    );
  }
}

class SocialAuthService extends ChangeNotifier {
  static const String _linkedAccountsKey = 'linked_accounts';
  
  List<LinkedAccount> _linkedAccounts = [];
  bool _isInitialized = false;

  List<LinkedAccount> get linkedAccounts => _linkedAccounts;
  bool get isInitialized => _isInitialized;

  /// Check if running on iOS simulator (simple method)
  bool get _isIOSSimulator {
    if (!Platform.isIOS) return false;
    // In debug mode, assume we're on simulator if kDebugMode is true
    return kDebugMode;
  }

  /// Check if Apple Sign-In is available and configured
  Future<bool> get isAppleSignInAvailable async {
    try {
      // Check if the device supports Apple Sign-In
      if (!await SignInWithApple.isAvailable()) {
        if (kDebugMode) {
          print('📱 Apple Sign-In not available on this device');
        }
        return false;
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Apple Sign-In configuration issue: $e');
      }
      // If there's an entitlement or provisioning profile issue, return false
      if (e.toString().contains('entitlement') || 
          e.toString().contains('provisioning') ||
          e.toString().contains('ASAuthorizationError')) {
        return false;
      }
      return false;
    }
  }

  Future<void> initialize() async {
    try {
      await _loadLinkedAccounts();
      _isInitialized = true;
      if (kDebugMode) {
        print('SocialAuthService initialized successfully');
      }
    } catch (e) {
      await crashlytics.CrashlyticsService.recordError(e, StackTrace.current);
      if (kDebugMode) {
        print('SocialAuthService initialization failed: $e');
      }
    }
  }

  // Google Sign In temporarily disabled
  Future<SocialAuthResult> signInWithGoogle() async {
    if (kDebugMode) {
      print('Google Sign In is temporarily disabled due to Firebase conflicts');
    }
    return SocialAuthResult(success: false, error: 'Google Sign In 暫時停用');
  }


  Future<SocialAuthResult> signInWithApple() async {
    try {
      if (kDebugMode) {
        print('🍎 Starting Apple Sign In process...');
      }
      
      // Check if Apple Sign In is available first
      if (!await SignInWithApple.isAvailable()) {
        if (kDebugMode) {
          print('❌ Apple Sign In not available on this device/simulator');
        }
        return SocialAuthResult(
          success: false, 
          error: '此設備不支援 Apple Sign In 或您需要在設置中登入 Apple ID'
        );
      }

      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      if (kDebugMode) {
        print('🍎 Requesting Apple ID credential...');
      }

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      if (kDebugMode) {
        print('🍎 Apple ID credential received');
        print('User ID: ${appleCredential.userIdentifier}');
        print('Email: ${appleCredential.email}');
        print('Given Name: ${appleCredential.givenName}');
        print('Family Name: ${appleCredential.familyName}');
      }

      if (appleCredential.userIdentifier == null || appleCredential.userIdentifier!.isEmpty) {
        if (kDebugMode) {
          print('❌ Apple Sign In: User identifier is null or empty');
        }
        return SocialAuthResult(success: false, error: '取消登入或獲取用戶資訊失敗');
      }

      final displayName = appleCredential.givenName != null && appleCredential.familyName != null
          ? '${appleCredential.givenName} ${appleCredential.familyName}'
          : appleCredential.email ?? 'Apple User';

      final account = LinkedAccount(
        provider: SocialProvider.apple,
        id: appleCredential.userIdentifier ?? '',
        email: appleCredential.email ?? '',
        displayName: displayName,
      );

      await _addLinkedAccount(account);
      if (kDebugMode) {
        print('✅ Apple Sign In successful, account saved');
      }
      return SocialAuthResult(success: true, account: account);
    } catch (e) {
      await crashlytics.CrashlyticsService.recordError(e, StackTrace.current);
      if (kDebugMode) {
        print('❌ Apple Sign In failed with error: $e');
        print('Error type: ${e.runtimeType}');
      }
      
      // Provide more user-friendly error messages
      String friendlyError;
      if (e.toString().contains('ASAuthorizationError')) {
        friendlyError = 'Apple Sign In 已取消或失敗';
      } else if (e.toString().contains('entitlement')) {
        friendlyError = '應用程式未正確配置 Apple Sign In';
      } else if (e.toString().contains('network')) {
        friendlyError = '網路連接問題，請檢查網路設定';
      } else {
        friendlyError = 'Apple Sign In 發生未知錯誤：${e.toString()}';
      }
      
      return SocialAuthResult(success: false, error: friendlyError);
    }
  }

  Future<SocialAuthResult> signInWithFacebook() async {
    try {
      if (kDebugMode) {
        print('📘 Starting Facebook Sign In process...');
      }
      
      final LoginResult result = await FacebookAuth.instance.login();
      
      if (result.status == LoginStatus.success) {
        if (kDebugMode) {
          print('📘 Facebook login successful, fetching user data...');
        }
        
        final userData = await FacebookAuth.instance.getUserData();
        
        if (kDebugMode) {
          print('📘 Facebook user data received');
          print('User ID: ${userData['id']}');
          print('Email: ${userData['email']}');
          print('Name: ${userData['name']}');
        }
        
        final account = LinkedAccount(
          provider: SocialProvider.facebook,
          id: userData['id'] ?? '',
          email: userData['email'] ?? '',
          displayName: userData['name'] ?? 'Facebook User',
          photoUrl: userData['picture']?['data']?['url'],
        );
        
        await _addLinkedAccount(account);
        if (kDebugMode) {
          print('✅ Facebook Sign In successful, account saved');
        }
        return SocialAuthResult(success: true, account: account);
      } else {
        if (kDebugMode) {
          print('❌ Facebook login failed: ${result.status} - ${result.message}');
        }
        return SocialAuthResult(
          success: false, 
          error: 'Facebook 登入失敗: ${result.message ?? "未知錯誤"}'
        );
      }
    } catch (e) {
      await crashlytics.CrashlyticsService.recordError(e, StackTrace.current);
      if (kDebugMode) {
        print('❌ Facebook Sign In failed with error: $e');
        print('Error type: ${e.runtimeType}');
      }
      
      // Provide user-friendly error messages
      String friendlyError;
      if (e.toString().contains('network')) {
        friendlyError = '網路連接問題，請檢查網路設定';
      } else if (e.toString().contains('cancelled')) {
        friendlyError = 'Facebook 登入已取消';
      } else {
        friendlyError = 'Facebook 登入發生錯誤：${e.toString()}';
      }
      
      return SocialAuthResult(success: false, error: friendlyError);
    }
  }

  Future<void> signOut(SocialProvider provider) async {
    try {
      _linkedAccounts.removeWhere((account) => account.provider == provider);
      await _saveLinkedAccounts();
      notifyListeners();
    } catch (e) {
      await crashlytics.CrashlyticsService.recordError(e, StackTrace.current);
      if (kDebugMode) {
        print('Sign out failed: $e');
      }
    }
  }

  Future<void> _addLinkedAccount(LinkedAccount account) async {
    _linkedAccounts.removeWhere((existingAccount) => 
        existingAccount.provider == account.provider);
    
    _linkedAccounts.add(account);
    await _saveLinkedAccounts();
    notifyListeners();
  }

  Future<void> _saveLinkedAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountsJson = _linkedAccounts.map((account) => account.toJson()).toList();
      await prefs.setString(_linkedAccountsKey, jsonEncode(accountsJson));
    } catch (e) {
      await crashlytics.CrashlyticsService.recordError(e, StackTrace.current);
      if (kDebugMode) {
        print('Failed to save linked accounts: $e');
      }
    }
  }

  Future<void> _loadLinkedAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountsJsonString = prefs.getString(_linkedAccountsKey);
      
      if (accountsJsonString != null) {
        final accountsJson = jsonDecode(accountsJsonString) as List;
        _linkedAccounts = accountsJson
            .map((json) => LinkedAccount.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      await crashlytics.CrashlyticsService.recordError(e, StackTrace.current);
      if (kDebugMode) {
        print('Failed to load linked accounts: $e');
      }
      _linkedAccounts = [];
    }
  }

  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Get account by provider
  LinkedAccount? getAccountByProvider(SocialProvider provider) {
    try {
      return _linkedAccounts.firstWhere((account) => account.provider == provider);
    } catch (e) {
      return null;
    }
  }

  /// Get the display name for a provider
  String getProviderDisplayName(SocialProvider provider) {
    switch (provider) {
      case SocialProvider.google:
        return 'Google';
      case SocialProvider.apple:
        return 'Apple';
      case SocialProvider.facebook:
        return 'Facebook';
    }
  }

  /// Get the icon for a provider
  String getProviderIcon(SocialProvider provider) {
    switch (provider) {
      case SocialProvider.google:
        return '🔍'; // Can be replaced with proper icon
      case SocialProvider.apple:
        return '🍎'; // Can be replaced with proper icon
      case SocialProvider.facebook:
        return '📘'; // Can be replaced with proper icon
    }
  }

  /// Unlink a social account
  Future<bool> unlinkAccount(SocialProvider provider) async {
    try {
      final accountIndex = _linkedAccounts.indexWhere((acc) => acc.provider == provider);
      if (accountIndex < 0) {
        return false;
      }

      // Sign out from the specific provider

      _linkedAccounts.removeAt(accountIndex);
      await _saveLinkedAccounts();
      notifyListeners();

      if (kDebugMode) {
        print('🔓 ${provider.name} account unlinked');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error unlinking ${provider.name} account: $e');
      }
      return false;
    }
  }

  bool get hasGoogleAccount => _linkedAccounts.any((account) => account.provider == SocialProvider.google);
  bool get hasAppleAccount => _linkedAccounts.any((account) => account.provider == SocialProvider.apple);
  bool get hasFacebookAccount => _linkedAccounts.any((account) => account.provider == SocialProvider.facebook);

  /// Clear all linked accounts (for logout)
  Future<void> clearAllAccounts() async {
    try {

      _linkedAccounts.clear();
      await _saveLinkedAccounts();
      notifyListeners();
      if (kDebugMode) {
        print('🔐 All linked accounts cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing accounts: $e');
      }
    }
  }
}