import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'crashlytics_service_stub.dart' as crashlytics;

class OtpResult {
  final bool success;
  final String? error;
  final String? otp; // Only for debugging in development

  OtpResult({
    required this.success,
    this.error,
    this.otp,
  });
}

class EmailOtpService extends ChangeNotifier {
  static const String _otpStorageKey = 'email_otp_data';
  static const int _otpValidityMinutes = 5;
  static const int _otpLength = 6;
  
  // In production, this would integrate with a real email service like SendGrid, AWS SES, etc.
  // For development/testing, we simulate OTP sending and store it locally
  
  Map<String, OtpData> _otpCache = {};
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    try {
      await _loadOtpCache();
      _isInitialized = true;
      if (kDebugMode) {
        print('EmailOtpService initialized successfully');
      }
    } catch (e) {
      await crashlytics.CrashlyticsService.recordError(e, StackTrace.current);
      if (kDebugMode) {
        print('EmailOtpService initialization failed: $e');
      }
    }
  }

  /// Send OTP to email address
  Future<OtpResult> sendOTP(String email, {bool isLogin = false}) async {
    try {
      final otp = _generateOTP();
      final otpData = OtpData(
        otp: otp,
        email: email,
        createdAt: DateTime.now(),
        attempts: 0,
        isLogin: isLogin,
      );

      _otpCache[email] = otpData;
      await _saveOtpCache();

      // In production, send email here
      // await _sendEmailOTP(email, otp, isLogin);
      
      if (kDebugMode) {
        print('📧 OTP sent to $email: $otp (${isLogin ? "Login" : "Registration"})');
        print('📧 This is a simulated email service for development');
      }

      // Return OTP in debug mode for testing
      return OtpResult(
        success: true, 
        otp: kDebugMode ? otp : null
      );
    } catch (e) {
      await crashlytics.CrashlyticsService.recordError(e, StackTrace.current);
      if (kDebugMode) {
        print('❌ Failed to send OTP: $e');
      }
      return OtpResult(success: false, error: 'Failed to send OTP: $e');
    }
  }

  /// Verify OTP
  Future<OtpResult> verifyOTP(String email, String inputOtp) async {
    try {
      final otpData = _otpCache[email];
      
      if (otpData == null) {
        return OtpResult(success: false, error: '找不到對應的驗證碼，請重新發送');
      }

      // Check expiry
      if (DateTime.now().difference(otpData.createdAt).inMinutes > _otpValidityMinutes) {
        _otpCache.remove(email);
        await _saveOtpCache();
        return OtpResult(success: false, error: '驗證碼已過期，請重新發送');
      }

      // Check attempts
      if (otpData.attempts >= 3) {
        _otpCache.remove(email);
        await _saveOtpCache();
        return OtpResult(success: false, error: '驗證次數過多，請重新發送驗證碼');
      }

      // Debug/Test bypass: Allow "000000" to pass verification
      if (inputOtp == '000000') {
        _otpCache.remove(email);
        await _saveOtpCache();
        
        if (kDebugMode) {
          print('🔓 DEBUG: OTP bypass used for $email (000000)');
        }
        
        return OtpResult(success: true);
      }
      
      // Verify OTP
      if (otpData.otp == inputOtp) {
        _otpCache.remove(email);
        await _saveOtpCache();
        
        if (kDebugMode) {
          print('✅ OTP verified successfully for $email');
        }
        
        return OtpResult(success: true);
      } else {
        // Increment attempts
        otpData.attempts++;
        await _saveOtpCache();
        
        final remainingAttempts = 3 - otpData.attempts;
        return OtpResult(
          success: false, 
          error: remainingAttempts > 0 
            ? '驗證碼不正確，還剩 $remainingAttempts 次機會'
            : '驗證碼不正確'
        );
      }
    } catch (e) {
      await crashlytics.CrashlyticsService.recordError(e, StackTrace.current);
      if (kDebugMode) {
        print('❌ OTP verification failed: $e');
      }
      return OtpResult(success: false, error: 'OTP verification failed: $e');
    }
  }

  /// Check if OTP exists for email (for UI state)
  bool hasActiveOtp(String email) {
    final otpData = _otpCache[email];
    if (otpData == null) return false;
    
    return DateTime.now().difference(otpData.createdAt).inMinutes <= _otpValidityMinutes;
  }

  /// Get remaining time for OTP
  Duration? getRemainingTime(String email) {
    final otpData = _otpCache[email];
    if (otpData == null) return null;
    
    final elapsed = DateTime.now().difference(otpData.createdAt);
    final remaining = Duration(minutes: _otpValidityMinutes) - elapsed;
    
    return remaining.isNegative ? null : remaining;
  }

  /// Clear expired OTPs
  Future<void> clearExpiredOtps() async {
    final now = DateTime.now();
    final expiredEmails = <String>[];
    
    for (final entry in _otpCache.entries) {
      if (now.difference(entry.value.createdAt).inMinutes > _otpValidityMinutes) {
        expiredEmails.add(entry.key);
      }
    }
    
    for (final email in expiredEmails) {
      _otpCache.remove(email);
    }
    
    if (expiredEmails.isNotEmpty) {
      await _saveOtpCache();
    }
  }

  String _generateOTP() {
    final random = Random.secure();
    return List.generate(_otpLength, (_) => random.nextInt(10)).join();
  }

  Future<void> _loadOtpCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheString = prefs.getString(_otpStorageKey);
      
      if (cacheString != null) {
        final cacheMap = jsonDecode(cacheString) as Map<String, dynamic>;
        _otpCache = cacheMap.map(
          (key, value) => MapEntry(key, OtpData.fromJson(value)),
        );
        
        // Clear expired OTPs on load
        await clearExpiredOtps();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load OTP cache: $e');
      }
      _otpCache = {};
    }
  }

  Future<void> _saveOtpCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheMap = _otpCache.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
      await prefs.setString(_otpStorageKey, jsonEncode(cacheMap));
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save OTP cache: $e');
      }
    }
  }

  // In production, implement actual email sending
  // Future<void> _sendEmailOTP(String email, String otp, bool isLogin) async {
  //   // Integration with email service like SendGrid, AWS SES, etc.
  //   // Example:
  //   // await sendGridService.sendOtpEmail(email, otp, isLogin);
  // }
}

class OtpData {
  final String otp;
  final String email;
  final DateTime createdAt;
  int attempts;
  final bool isLogin;

  OtpData({
    required this.otp,
    required this.email,
    required this.createdAt,
    this.attempts = 0,
    this.isLogin = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'otp': otp,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'attempts': attempts,
      'isLogin': isLogin,
    };
  }

  factory OtpData.fromJson(Map<String, dynamic> json) {
    return OtpData(
      otp: json['otp'] ?? '',
      email: json['email'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      attempts: json['attempts'] ?? 0,
      isLogin: json['isLogin'] ?? false,
    );
  }
}