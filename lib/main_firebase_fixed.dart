import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }
  
  runApp(const FirebaseFixedApp());
}

class FirebaseFixedApp extends StatelessWidget {
  const FirebaseFixedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Fixed Test',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const FirebaseFixedScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FirebaseFixedScreen extends StatefulWidget {
  const FirebaseFixedScreen({super.key});

  @override
  State<FirebaseFixedScreen> createState() => _FirebaseFixedScreenState();
}

class _FirebaseFixedScreenState extends State<FirebaseFixedScreen> {
  bool _isFirebaseInitialized = false;
  String _firebaseStatus = 'Checking Firebase status...';

  @override
  void initState() {
    super.initState();
    _checkFirebaseStatus();
  }

  void _checkFirebaseStatus() {
    try {
      // Check if Firebase is initialized
      final app = Firebase.app();
      setState(() {
        _isFirebaseInitialized = true;
        _firebaseStatus = 'Firebase connected to: ${app.options.projectId}';
      });
      print('✅ Firebase app found: ${app.name}');
    } catch (e) {
      setState(() {
        _isFirebaseInitialized = false;
        _firebaseStatus = 'Firebase not initialized: $e';
      });
      print('❌ Firebase check failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Status Check'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔥 Firebase Status', 
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          _isFirebaseInitialized ? Icons.check_circle : Icons.error,
                          color: _isFirebaseInitialized ? Colors.green : Colors.red,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _firebaseStatus,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_isFirebaseInitialized) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✅ 成功！',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Firebase 整合運作正常！',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '您的用戶資料同步系統已準備就緒。',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⚠️ 注意',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Firebase 初始化遇到問題，但應用程式仍可正常運作。',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkFirebaseStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('重新檢查 Firebase 狀態'),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🚀 下一步',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('• 添加 Firestore 進行用戶數據存儲'),
                    const Text('• 實現跨設備數據同步'),
                    const Text('• 集成到主應用程式'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}