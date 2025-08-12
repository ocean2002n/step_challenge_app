import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
// Firebase Crashlytics temporarily removed to avoid gRPC issues
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
import 'services/social_auth_service_simplified.dart';
import 'services/marathon_service.dart';
import 'services/email_otp_service.dart';
import 'services/crashlytics_service_stub.dart' as crashlytics;
// import 'services/firestore_user_service.dart';
import 'utils/app_theme.dart';
import 'package:step_challenge_app/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase Core only
  try {
    await Firebase.initializeApp();
    print('✅ Firebase Core initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
    // Continue without Firebase if initialization fails
  }
  
  // Crashlytics temporarily disabled to avoid gRPC issues
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //   return true;
  // };
  // Initialize stub Crashlytics service
  await crashlytics.CrashlyticsService.initialize();
  
  final localeService = LocaleService();
  await localeService.loadSavedLanguage();
  
  final deepLinkService = DeepLinkService();
  await deepLinkService.initialize();
  
  final authService = AuthService();
  await authService.initialize();
  
  final socialAuthService = SocialAuthService();
  await socialAuthService.initialize();
  
  final emailOtpService = EmailOtpService();
  await emailOtpService.initialize();
  
  // FirestoreUserService temporarily disabled until Firestore is added
  // final firestoreUserService = FirestoreUserService();
  // await firestoreUserService.initialize();
  
  runApp(StepChallengeApp(
    localeService: localeService, 
    deepLinkService: deepLinkService,
    authService: authService,
    socialAuthService: socialAuthService,
    emailOtpService: emailOtpService,
    // firestoreUserService: firestoreUserService,
  ));
}

class StepChallengeApp extends StatelessWidget {
  final LocaleService localeService;
  final DeepLinkService deepLinkService;
  final AuthService authService;
  final SocialAuthService socialAuthService;
  final EmailOtpService emailOtpService;
  // final FirestoreUserService firestoreUserService;
  
  const StepChallengeApp({
    super.key, 
    required this.localeService,
    required this.deepLinkService,
    required this.authService,
    required this.socialAuthService,
    required this.emailOtpService,
    // required this.firestoreUserService,
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
        ChangeNotifierProvider.value(value: emailOtpService),
        // ChangeNotifierProvider.value(value: firestoreUserService),
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
    
    // 其他情況都顯示主畫面
    return const HomeScreen();
  }
}