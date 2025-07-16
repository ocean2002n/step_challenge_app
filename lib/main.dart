import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/friend_qr_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'services/health_service.dart';
import 'services/sheets_service.dart';
import 'services/locale_service.dart';
import 'services/friend_service.dart';
import 'utils/app_theme.dart';
import 'package:step_challenge_app/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final localeService = LocaleService();
  await localeService.loadSavedLanguage();
  
  runApp(StepChallengeApp(localeService: localeService));
}

class StepChallengeApp extends StatelessWidget {
  final LocaleService localeService;
  
  const StepChallengeApp({super.key, required this.localeService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HealthService()),
        ChangeNotifierProvider(create: (_) => SheetsService()),
        ChangeNotifierProvider(create: (_) => FriendService()..initialize()),
        ChangeNotifierProvider.value(value: localeService),
      ],
      child: Consumer<LocaleService>(
        builder: (context, localeService, child) {
          return MaterialApp(
            title: 'Step Challenge',
            theme: AppTheme.lightTheme,
            home: const HomeScreen(),
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
            supportedLocales: localeService.supportedLocales,
          );
        },
      ),
    );
  }
}