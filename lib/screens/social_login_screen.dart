import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/social_auth_service_simplified.dart';
import '../utils/app_theme.dart';
import '../widgets/login_background_animation.dart';
import 'registration_screen.dart';
import 'email_login_screen.dart';
import 'home_screen.dart';

class SocialLoginScreen extends StatefulWidget {
  const SocialLoginScreen({super.key});

  @override
  State<SocialLoginScreen> createState() => _SocialLoginScreenState();
}

class _SocialLoginScreenState extends State<SocialLoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  String? _loadingProvider;
  bool _isAppleSignInAvailable = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _checkAppleSignInAvailability();
    _initAnimations();
  }
  
  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    // Start animation after a small delay to let Hero animation complete
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
      body: LoginBackgroundAnimation(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // App logo/title with Hero Animation
              Hero(
                tag: 'app_logo',
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.directions_walk,
                    size: 50,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Hero(
                tag: 'app_title',
                child: Material(
                  color: Colors.transparent,
                  child: const Text(
                    'Step Challenge',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  '開始您的健康運動之旅',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              
              // Social login buttons with animation
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      _buildGoogleSignInButton(l10n),
                      
                      // 條件性顯示 Apple Sign-In 按鈕
                      if (_isAppleSignInAvailable) ...[
                        const SizedBox(height: 16),
                        _buildAppleSignInButton(l10n),
                      ],
                      
                      // Facebook Sign-In 按鈕
                      const SizedBox(height: 16),
                      _buildFacebookSignInButton(l10n),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Or divider
              FadeTransition(
                opacity: _fadeAnimation,
                child: Row(
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
              ),
              const SizedBox(height: 32),
              
              // Email registration button
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => _navigateToEmailRegistration(),
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
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Login option
              FadeTransition(
                opacity: _fadeAnimation,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '已有帳號？',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading ? null : () => _navigateToEmailLogin(),
                      child: const Text(
                        '立即登入',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildGoogleSignInButton(AppLocalizations l10n) {
    // Google Sign In is disabled
    return ElevatedButton(
      onPressed: null, // Disabled
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.grey[500],
        disabledBackgroundColor: Colors.grey[200],
        disabledForegroundColor: Colors.grey[500],
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
          SvgPicture.asset(
            'assets/images/google_g_logo.svg',
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(Colors.grey[400]!, BlendMode.srcIn),
          ),
          const SizedBox(width: 12),
          Text(
            '使用 Google 註冊 (暫時停用)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppleSignInButton(AppLocalizations l10n) {
    // Apple Sign In is disabled
    return ElevatedButton(
      onPressed: null, // Disabled
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[600],
        foregroundColor: Colors.grey[400],
        disabledBackgroundColor: Colors.grey[600],
        disabledForegroundColor: Colors.grey[400],
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.apple, size: 20, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Text(
            '使用 Apple 註冊 (暫時停用)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacebookSignInButton(AppLocalizations l10n) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _signInWithFacebook,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1877F2),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _loadingProvider == 'facebook'
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.facebook, size: 20),
              const SizedBox(width: 12),
              Text(
                '使用 Facebook 註冊',
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

  Future<void> _signInWithFacebook() async {
    setState(() {
      _isLoading = true;
      _loadingProvider = 'facebook';
    });

    try {
      final socialAuthService = context.read<SocialAuthService>();
      final result = await socialAuthService.signInWithFacebook();
      
      if (result.success && result.account != null) {
        await _handleSocialLoginSuccess(result.account!);
      } else {
        _showErrorMessage(result.error ?? '登入失敗');
      }
    } catch (e) {
      _showErrorMessage('Facebook 登入時發生錯誤：$e');
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

  void _navigateToEmailRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegistrationScreen()),
    );
  }

  void _navigateToEmailLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EmailLoginScreen()),
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