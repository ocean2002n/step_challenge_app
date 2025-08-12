import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/health_service.dart';
import 'services/locale_service.dart';
import 'utils/app_theme.dart';
import 'package:step_challenge_app/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 啟動 Step Challenge APP (Debug模式)');
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Step Challenge',
      theme: AppTheme.lightTheme,
      home: TestHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TestHomePage extends StatefulWidget {
  @override
  _TestHomePageState createState() => _TestHomePageState();
}

class _TestHomePageState extends State<TestHomePage> {
  String status = '正在初始化...';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() {
        status = '正在載入服務...';
      });
      
      await Future.delayed(Duration(seconds: 1));
      
      setState(() {
        status = '初始化完成！';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        status = '初始化失敗: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo 或圖標
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  Icons.directions_walk,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              
              SizedBox(height: 30),
              
              // 標題
              Text(
                'Step Challenge',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              
              SizedBox(height: 20),
              
              // 狀態文字
              Text(
                status,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 30),
              
              // 載入指示器或按鈕
              if (isLoading)
                CircularProgressIndicator()
              else
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WelcomeScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                      child: Text('語言設定'),
                    ),
                    
                    SizedBox(height: 10),
                    
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MultiProvider(
                              providers: [
                                ChangeNotifierProvider(create: (_) => HealthService()),
                                ChangeNotifierProvider(create: (_) => LocaleService()),
                              ],
                              child: HomeScreen(),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                      child: Text('進入主畫面'),
                    ),
                    
                    SizedBox(height: 20),
                    
                    Text(
                      '📱 APP 正常運行中',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}