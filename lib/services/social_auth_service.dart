import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import 'crashlytics_service.dart';

enum SocialProvider { google, apple }

class LinkedAccount {
  final SocialProvider provider;
  final String providerId;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final DateTime linkedAt;

  LinkedAccount({
    required this.provider,
    required this.providerId,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.linkedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'provider': provider.name,
      'providerId': providerId,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'linkedAt': linkedAt.toIso8601String(),
    };
  }

  factory LinkedAccount.fromJson(Map<String, dynamic> json) {
    return LinkedAccount(
      provider: SocialProvider.values.firstWhere((e) => e.name == json['provider']),
      providerId: json['providerId'],
      email: json['email'],
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      linkedAt: DateTime.parse(json['linkedAt']),
    );
  }
}

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

class SocialAuthService extends ChangeNotifier {
  static const String _linkedAccountsKey = 'linked_accounts';
  
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  List<LinkedAccount> _linkedAccounts = [];
  
  List<LinkedAccount> get linkedAccounts => List.unmodifiable(_linkedAccounts);
  
  bool get hasGoogleAccount => _linkedAccounts.any((account) => account.provider == SocialProvider.google);
  bool get hasAppleAccount => _linkedAccounts.any((account) => account.provider == SocialProvider.apple);
  
  /// 檢查 Apple Sign-In 是否可用且正確配置
  Future<bool> get isAppleSignInAvailable async {
    try {
      // 檢查設備是否支援 Apple Sign-In
      if (!await SignInWithApple.isAvailable()) {
        debugPrint('📱 Apple Sign-In not available on this device');
        return false;
      }
      
      // 嘗試檢查權限配置 - 這裡會捕獲配置錯誤
      return true;
    } catch (e) {
      debugPrint('⚠️ Apple Sign-In configuration issue: $e');
      // 如果是 entitlement 或 provisioning profile 問題，返回 false
      if (e.toString().contains('entitlement') || 
          e.toString().contains('provisioning') ||
          e.toString().contains('ASAuthorizationError')) {
        return false;
      }
      return false;
    }
  }

  Future<void> initialize() async {
    await _loadLinkedAccounts();
  }

  Future<void> _loadLinkedAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountsJson = prefs.getStringList(_linkedAccountsKey) ?? [];
      
      _linkedAccounts = accountsJson.map((json) {
        final Map<String, dynamic> accountMap = Map<String, dynamic>.from(
          jsonDecode(json) as Map
        );
        return LinkedAccount.fromJson(accountMap);
      }).toList();
      
      debugPrint('🔗 Loaded ${_linkedAccounts.length} linked accounts');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading linked accounts: $e');
      _linkedAccounts = [];
    }
  }

  Future<void> _saveLinkedAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountsJson = _linkedAccounts.map((account) {
        return jsonEncode(account.toJson());
      }).toList();
      
      await prefs.setStringList(_linkedAccountsKey, accountsJson);
      debugPrint('💾 Saved ${_linkedAccounts.length} linked accounts');
    } catch (e) {
      debugPrint('❌ Error saving linked accounts: $e');
    }
  }

  /// Save or update a single linked account
  Future<void> _saveLinkedAccount(LinkedAccount account) async {
    try {
      // Check if account already exists (same provider and providerId)
      final existingIndex = _linkedAccounts.indexWhere(
        (acc) => acc.provider == account.provider && acc.providerId == account.providerId
      );

      if (existingIndex >= 0) {
        // Update existing account
        _linkedAccounts[existingIndex] = account;
        debugPrint('🔄 Updated existing ${account.provider.name} account');
      } else {
        // Add new account
        _linkedAccounts.add(account);
        debugPrint('➕ Added new ${account.provider.name} account');
      }

      await _saveLinkedAccounts();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error saving linked account: $e');
    }
  }

  /// Sign in with Google
  Future<SocialAuthResult> signInWithGoogle() async {
    try {
      debugPrint('🔍 Attempting Google sign in...');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        debugPrint('❌ Google sign in cancelled by user');
        return SocialAuthResult(success: false, error: 'Google 登入已取消');
      }

      // Obtain the auth details from the request  
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      debugPrint('✅ Google sign in successful: ${googleUser.email}');
      debugPrint('   Display Name: ${googleUser.displayName}');
      debugPrint('   Photo URL: ${googleUser.photoUrl}');

      // Create LinkedAccount object
      final account = LinkedAccount(
        provider: SocialProvider.google,
        providerId: googleUser.id,
        email: googleUser.email,
        displayName: googleUser.displayName,
        photoUrl: googleUser.photoUrl,
        linkedAt: DateTime.now(),
      );

      // Save or update the account
      await _saveLinkedAccount(account);
      await CrashlyticsService.recordUserAction('google_sign_in_success');
      
      return SocialAuthResult(success: true, account: account);

    } catch (error) {
      debugPrint('❌ Google sign in error: $error');
      await CrashlyticsService.recordError(error, StackTrace.current, reason: 'Google sign in failed');
      return SocialAuthResult(success: false, error: 'Google 登入失敗: ${error.toString()}');
    }
  }

  /// Sign in with Apple
  Future<SocialAuthResult> signInWithApple() async {
    try {
      debugPrint('🍎 Attempting Apple sign in...');

      // Check if Apple Sign In is available
      if (!await SignInWithApple.isAvailable()) {
        debugPrint('❌ Apple Sign In not available on this device');
        return SocialAuthResult(success: false, error: 'Apple Sign In 在此裝置上不支援');
      }

      // Generate nonce for security
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );
      
      // Check if user cancelled
      if (appleCredential.userIdentifier == null || appleCredential.userIdentifier!.isEmpty) {
        debugPrint('❌ Apple Sign In: User identifier is null or empty');
        return SocialAuthResult(success: false, error: '取消登入或獲取用戶資訊失敗');
      }

      final account = LinkedAccount(
        provider: SocialProvider.apple,
        providerId: appleCredential.userIdentifier ?? '',
        email: appleCredential.email,
        displayName: appleCredential.givenName != null && appleCredential.familyName != null
            ? '${appleCredential.givenName} ${appleCredential.familyName}'
            : appleCredential.givenName ?? appleCredential.familyName,
        photoUrl: null, // Apple doesn't provide profile photos
        linkedAt: DateTime.now(),
      );

      // Check if account already exists
      final existingIndex = _linkedAccounts.indexWhere(
        (acc) => acc.provider == SocialProvider.apple && acc.providerId == (appleCredential.userIdentifier ?? '')
      );

      if (existingIndex >= 0) {
        // Update existing account
        _linkedAccounts[existingIndex] = account;
      } else {
        // Add new account
        _linkedAccounts.add(account);
      }

      await _saveLinkedAccounts();
      notifyListeners();

      debugPrint('✅ Apple sign in successful: ${appleCredential.email}');
      return SocialAuthResult(success: true, account: account);

    } catch (e, stack) {
      await CrashlyticsService.recordAuthError('Apple Sign-In', e, stack);
      debugPrint('❌ Apple sign in error: $e');
      return SocialAuthResult(success: false, error: e.toString());
    }
  }

  /// Unlink a social account
  Future<bool> unlinkAccount(SocialProvider provider) async {
    try {
      final accountIndex = _linkedAccounts.indexWhere((acc) => acc.provider == provider);
      if (accountIndex < 0) {
        return false;
      }

      if (provider == SocialProvider.google) {
        try {
          await _googleSignIn.signOut();
          debugPrint('🔓 Google Sign-In signed out');
        } catch (e) {
          debugPrint('⚠️ Error signing out from Google: $e');
        }
      }

      _linkedAccounts.removeAt(accountIndex);
      await _saveLinkedAccounts();
      notifyListeners();

      debugPrint('🔓 ${provider.name} account unlinked');
      return true;
    } catch (e) {
      debugPrint('❌ Error unlinking ${provider.name} account: $e');
      return false;
    }
  }

  /// Get account by provider
  LinkedAccount? getAccountByProvider(SocialProvider provider) {
    try {
      return _linkedAccounts.firstWhere((account) => account.provider == provider);
    } catch (e) {
      return null;
    }
  }

  /// Clear all linked accounts (for logout)
  Future<void> clearAllAccounts() async {
    try {
      // Sign out from Google if there's a linked Google account
      if (hasGoogleAccount) {
        try {
          await _googleSignIn.signOut();
          debugPrint('🔓 Google Sign-In signed out during clear all');
        } catch (e) {
          debugPrint('⚠️ Error signing out from Google during clear all: $e');
        }
      }
      
      _linkedAccounts.clear();
      await _saveLinkedAccounts();
      notifyListeners();
      debugPrint('🔐 All linked accounts cleared');
    } catch (e) {
      debugPrint('❌ Error clearing accounts: $e');
    }
  }

  /// Generate nonce for Apple Sign In
  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// SHA256 hash of string
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Get the display name for a provider
  String getProviderDisplayName(SocialProvider provider) {
    switch (provider) {
      case SocialProvider.google:
        return 'Google';
      case SocialProvider.apple:
        return 'Apple';
    }
  }

  /// Get the icon for a provider
  String getProviderIcon(SocialProvider provider) {
    switch (provider) {
      case SocialProvider.google:
        return '🔍'; // Can be replaced with proper icon
      case SocialProvider.apple:
        return '🍎'; // Can be replaced with proper icon
    }
  }
}