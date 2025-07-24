import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/social_auth_service.dart';
import '../utils/app_theme.dart';
import 'registration_screen.dart';
import 'home_screen.dart';

class SocialLoginScreen extends StatefulWidget {
  const SocialLoginScreen({super.key});

  @override
  State<SocialLoginScreen> createState() => _SocialLoginScreenState();
}

class _SocialLoginScreenState extends State<SocialLoginScreen> {
  bool _isLoading = false;
  String? _loadingProvider;
  bool _isAppleSignInAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkAppleSignInAvailability();
  }

  Future<void> _checkAppleSignInAvailability() async {
    try {
      final socialAuthService = context.read<SocialAuthService>();
      final isAvailable = await socialAuthService.isAppleSignInAvailable;
      
      if (mounted) {
        setState(() {
          _isAppleSignInAvailable = isAvailable;
        });
      }
    } catch (e) {
      debugPrint('Error checking Apple Sign-In availability: $e');
      if (mounted) {
        setState(() {
          _isAppleSignInAvailable = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App logo/title
              const Icon(
                Icons.directions_walk,
                size: 80,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 24),
              
              const Text(
                'Step Challenge',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              
              Text(
                '開始您的健康運動之旅',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 48),
              
              // Social login buttons
              _buildGoogleSignInButton(l10n),
              
              // 條件性顯示 Apple Sign-In 按鈕
              if (_isAppleSignInAvailable) ...[
                const SizedBox(height: 16),
                _buildAppleSignInButton(l10n),
              ],
              const SizedBox(height: 32),
              
              // Or divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '或',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              const SizedBox(height: 32),
              
              // Traditional registration button
              OutlinedButton(
                onPressed: _isLoading ? null : () => _navigateToTraditionalRegistration(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppTheme.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '使用電子郵件註冊',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton(AppLocalizations l10n) {
    final isGoogleLoading = _isLoading && _loadingProvider == 'google';
    
    return ElevatedButton(
      onPressed: _isLoading ? null : () => _signInWithGoogle(),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: Colors.grey[300]!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isGoogleLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            SvgPicture.asset(
              'assets/images/google_g_logo.svg',
              width: 20,
              height: 20,
            ),
          const SizedBox(width: 12),
          Text(
            isGoogleLoading ? '正在登入...' : '使用 Google 繼續',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppleSignInButton(AppLocalizations l10n) {
    final isAppleLoading = _isLoading && _loadingProvider == 'apple';
    
    return ElevatedButton(
      onPressed: _isLoading ? null : () => _signInWithApple(),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isAppleLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else
            const Icon(Icons.apple, size: 20),
          const SizedBox(width: 12),
          Text(
            isAppleLoading ? '正在登入...' : '使用 Apple 繼續',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _loadingProvider = 'google';
    });

    try {
      final socialAuthService = context.read<SocialAuthService>();
      final result = await socialAuthService.signInWithGoogle();
      
      if (result.success && result.account != null) {
        await _handleSocialLoginSuccess(result.account!);
      } else {
        _showErrorMessage(result.error ?? '登入失敗');
      }
    } catch (e) {
      _showErrorMessage('Google 登入時發生錯誤：$e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingProvider = null;
        });
      }
    }
  }

  Future<void> _signInWithApple() async {
    setState(() {
      _isLoading = true;
      _loadingProvider = 'apple';
    });

    try {
      final socialAuthService = context.read<SocialAuthService>();
      final result = await socialAuthService.signInWithApple();
      
      if (result.success && result.account != null) {
        await _handleSocialLoginSuccess(result.account!);
      } else {
        _showErrorMessage(result.error ?? '登入失敗');
      }
    } catch (e) {
      _showErrorMessage('Apple 登入時發生錯誤：$e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingProvider = null;
        });
      }
    }
  }

  Future<void> _handleSocialLoginSuccess(LinkedAccount account) async {
    final authService = context.read<AuthService>();
    
    // Check if user is already registered
    if (authService.isUserRegistered) {
      // User already registered, update profile photo if available
      if (account.photoUrl != null && account.photoUrl!.isNotEmpty) {
        await authService.updateProfilePhoto(account.photoUrl);
      }
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
      return;
    }

    // New user, initialize with social account data first
    try {
      await authService.initSocialLoginUser(
        socialAccount: account,
      );

      // Navigate to registration screen starting from step 1 (gender/birthdate)
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const RegistrationScreen(
              initialStep: 1,
              isSocialLogin: true,
            ),
          ),
        );
      }
    } catch (e) {
      _showErrorMessage('註冊失敗：$e');
    }
  }

  void _navigateToTraditionalRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegistrationScreen()),
    );
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}