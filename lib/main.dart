import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/friend_qr_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/social_login_screen.dart';
import 'widgets/deep_link_handler.dart';
import 'services/health_service.dart';
import 'services/sheets_service.dart';
import 'services/locale_service.dart';
import 'services/friend_service.dart';
import 'services/deep_link_service.dart';
import 'services/auth_service.dart';
import 'services/social_auth_service.dart';
import 'services/marathon_service.dart';
import 'utils/app_theme.dart';
import 'package:step_challenge_app/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final localeService = LocaleService();
  await localeService.loadSavedLanguage();
  
  final deepLinkService = DeepLinkService();
  await deepLinkService.initialize();
  
  final authService = AuthService();
  await authService.initialize();
  
  final socialAuthService = SocialAuthService();
  await socialAuthService.initialize();
  
  runApp(StepChallengeApp(
    localeService: localeService, 
    deepLinkService: deepLinkService,
    authService: authService,
    socialAuthService: socialAuthService,
  ));
}

class StepChallengeApp extends StatelessWidget {
  final LocaleService localeService;
  final DeepLinkService deepLinkService;
  final AuthService authService;
  final SocialAuthService socialAuthService;
  
  const StepChallengeApp({
    super.key, 
    required this.localeService,
    required this.deepLinkService,
    required this.authService,
    required this.socialAuthService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HealthService()),
        ChangeNotifierProvider(create: (_) => SheetsService()),
        ChangeNotifierProvider(create: (_) => FriendService()..initialize()),
        ChangeNotifierProvider(create: (_) => MarathonService()),
        ChangeNotifierProvider.value(value: localeService),
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider.value(value: socialAuthService),
      ],
      child: Consumer<LocaleService>(
        builder: (context, localeService, child) {
          return DeepLinkHandler(
            deepLinkService: deepLinkService,
            child: MaterialApp(
              title: 'Step Challenge',
              theme: AppTheme.lightTheme,
              home: _getHomeScreen(authService),
              debugShowCheckedModeBanner: false,
              routes: {
                '/friend_qr': (context) => const FriendQrScreen(),
                '/scan_qr': (context) => const QrScannerScreen(),
              },
              locale: localeService.locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
            ),
          );
        },
      ),
    );
  }
  
  Widget _getHomeScreen(AuthService authService) {
    // 首先檢查是否是首次啟動（選擇語言）
    if (authService.isFirstLaunch) {
      return const WelcomeScreen();
    }
    
    // 如果用戶還沒註冊，顯示社群登入畫面
    if (!authService.isUserRegistered) {
      return const SocialLoginScreen();
    }
    
    // 如果需要完成其他設定（引導流程等）
    if (authService.needsSetup()) {
      return const HomeScreen();
    } else {
      return const HomeScreen();
    }
  }
}