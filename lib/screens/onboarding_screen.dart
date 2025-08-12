import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_theme.dart';
import 'registration_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  final int _totalPages = 3;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildOnboardingPage(
                  icon: Icons.favorite,
                  iconColor: const Color(0xFFFF6B6B),
                  title: l10n.onboardingHealthTitle,
                  description: l10n.onboardingHealthDescription,
                  image: 'health',
                ),
                _buildOnboardingPage(
                  icon: Icons.groups,
                  iconColor: const Color(0xFF4ECDC4),
                  title: l10n.onboardingFriendsTitle,
                  description: l10n.onboardingFriendsDescription,
                  image: 'friends',
                ),
                _buildOnboardingPage(
                  icon: Icons.emoji_events,
                  iconColor: const Color(0xFFFFE66D),
                  title: l10n.onboardingChallengesTitle,
                  description: l10n.onboardingChallengesDescription,
                  image: 'challenges',
                ),
              ],
            ),
          ),
          _buildBottomSection(l10n),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String image,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          
          // Icon with animation
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 60,
              color: iconColor,
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Description
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildBottomSection(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        32,
        24,
        32,
        32 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        children: [
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _totalPages,
              (index) => _buildPageIndicator(index),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Buttons
          Row(
            children: [
              // Skip button
              if (_currentPage < _totalPages - 1)
                TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    l10n.skip,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ),
              
              const Spacer(),
              
              // Next/Get Started button
              ElevatedButton(
                onPressed: _currentPage == _totalPages - 1
                    ? _completeOnboarding
                    : _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _currentPage == _totalPages - 1
                          ? l10n.getStarted
                          : l10n.next,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_currentPage < _totalPages - 1) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryColor : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() async {
    final authService = context.read<AuthService>();
    await authService.completeOnboarding();
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const RegistrationScreen(),
        ),
      );
    }
  }
}