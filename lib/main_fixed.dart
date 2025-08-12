import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/social_login_screen.dart';
import 'services/health_service.dart';
import 'services/locale_service.dart';
import 'services/friend_service.dart';
import 'services/marathon_service.dart';
import 'utils/app_theme.dart';
import 'package:step_challenge_app/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 啟動 Step Challenge APP (修復版本)');
  
  runApp(StepChallengeFixedApp());
}

class StepChallengeFixedApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HealthService()),
        ChangeNotifierProvider(create: (_) => LocaleService()),
        ChangeNotifierProvider(create: (_) => FriendService()),
        ChangeNotifierProvider(create: (_) => MarathonService()),
      ],
      child: MaterialApp(
        title: 'Step Challenge',
        theme: AppTheme.lightTheme,
        home: AppNavigator(),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}

class AppNavigator extends StatefulWidget {
  @override
  _AppNavigatorState createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  int _currentStep = 0; // 0: Welcome, 1: Login, 2: Home
  
  @override
  Widget build(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return WelcomeScreenFixed(
          onNext: () {
            setState(() {
              _currentStep = 1;
            });
          },
        );
      case 1:
        return SocialLoginScreenFixed(
          onNext: () {
            setState(() {
              _currentStep = 2;
            });
          },
          onBack: () {
            setState(() {
              _currentStep = 0;
            });
          },
        );
      case 2:
        return HomeScreenFixed(
          onBack: () {
            setState(() {
              _currentStep = 0;
            });
          },
        );
      default:
        return WelcomeScreenFixed(
          onNext: () {
            setState(() {
              _currentStep = 1;
            });
          },
        );
    }
  }
}

class WelcomeScreenFixed extends StatelessWidget {
  final VoidCallback onNext;
  
  const WelcomeScreenFixed({Key? key, required this.onNext}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade700,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Spacer(flex: 2),
                
                // App Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Icon(
                    Icons.directions_walk,
                    size: 60,
                    color: Colors.blue.shade700,
                  ),
                ),
                
                SizedBox(height: 24),
                
                Text(
                  'Step Challenge',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                Spacer(flex: 1),
                
                Text(
                  '歡迎使用',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 16),
                
                Text(
                  '開始您的健康挑戰之旅\n追蹤步數、參與挑戰、與朋友競賽',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                Spacer(flex: 2),
                
                // Language selection
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        '選擇語言 / Choose Language',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _LanguageButton(
                              text: '中文',
                              isSelected: true,
                              onTap: () {},
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _LanguageButton(
                              text: 'English',
                              isSelected: false,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Continue button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      '開始使用',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _LanguageButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white,
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.blue.shade700 : Colors.white,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class SocialLoginScreenFixed extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  
  const SocialLoginScreenFixed({
    Key? key,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('登入'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '選擇登入方式',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 40),
            
            ElevatedButton.icon(
              onPressed: onNext,
              icon: Icon(Icons.login),
              label: Text('Google 登入'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            
            SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: onNext,
              icon: Icon(Icons.apple),
              label: Text('Apple ID 登入'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            
            SizedBox(height: 24),
            
            TextButton(
              onPressed: onNext,
              child: Text('暫時跳過，稍後登入'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreenFixed extends StatelessWidget {
  final VoidCallback onBack;
  
  const HomeScreenFixed({Key? key, required this.onBack}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step Challenge'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: onBack,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_walk,
              size: 100,
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              '主畫面載入成功！',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('這是您的原始APP流程'),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: onBack,
              child: Text('返回歡迎畫面'),
            ),
          ],
        ),
      ),
    );
  }
}