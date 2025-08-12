import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';
// import 'screens/social_login_screen.dart';  // Temporarily disabled for testing
import 'services/health_service.dart';
import 'services/sheets_service.dart';
import 'services/locale_service.dart';
import 'services/friend_service.dart';
import 'services/marathon_service.dart';
import 'utils/app_theme.dart';
import 'package:step_challenge_app/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化基本服務（不包含Firebase）
  final localeService = LocaleService();
  await localeService.loadSavedLanguage();
  
  runApp(StepChallengeApp(localeService: localeService));
}

class StepChallengeApp extends StatelessWidget {
  final LocaleService localeService;
  
  const StepChallengeApp({
    super.key, 
    required this.localeService,
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
      ],
      child: Consumer<LocaleService>(
        builder: (context, localeService, child) {
          return MaterialApp(
            title: 'Step Challenge',
            theme: AppTheme.lightTheme,
            home: HomeScreen(), // 直接顯示主畫面進行測試
            debugShowCheckedModeBanner: false,
            locale: localeService.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );
  }
}