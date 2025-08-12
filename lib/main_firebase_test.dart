import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'services/firestore_user_service.dart';
import 'services/crashlytics_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  
  // Initialize Crashlytics service
  await CrashlyticsService.initialize();
  
  final firestoreUserService = FirestoreUserService();
  await firestoreUserService.initialize();
  
  runApp(FirebaseTestApp(
    firestoreUserService: firestoreUserService,
  ));
}

class FirebaseTestApp extends StatelessWidget {
  final FirestoreUserService firestoreUserService;
  
  const FirebaseTestApp({
    super.key, 
    required this.firestoreUserService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: firestoreUserService),
      ],
      child: MaterialApp(
        title: 'Firebase Test App',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
        ),
        home: const FirebaseTestScreen(),
      ),
    );
  }
}

class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  String _status = 'Firebase initialized successfully!';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Integration Test'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Consumer<FirestoreUserService>(
        builder: (context, firestoreService, child) {
          return Padding(
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
                        const Text('🔥 Firebase Status:', 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(_status, style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 16),
                        Text('Firestore Service: ${firestoreService.isInitialized ? "✅ Ready" : "❌ Not Ready"}',
                          style: const TextStyle(fontSize: 16)),
                        Text('Is Syncing: ${firestoreService.isSyncing ? "🔄 Yes" : "⏸️ No"}',
                          style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _testCrashlytics,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text('Test Crashlytics', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _testCreateUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text('Test Create User', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _forceCrash,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text('⚠️ Test Crash (Debug Only)', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Future<void> _testCrashlytics() async {
    setState(() {
      _status = 'Testing Crashlytics...';
    });
    
    try {
      await CrashlyticsService.log('Firebase Test: User clicked test button');
      await CrashlyticsService.recordError(
        'Test Error', 
        StackTrace.current, 
        reason: 'Testing Firebase Crashlytics integration',
        fatal: false,
      );
      
      setState(() {
        _status = 'Crashlytics test completed! Check Firebase Console.';
      });
    } catch (e) {
      setState(() {
        _status = 'Crashlytics test failed: $e';
      });
    }
  }
  
  Future<void> _testCreateUser() async {
    setState(() {
      _status = 'Testing Firestore user creation...';
    });
    
    try {
      final firestoreService = Provider.of<FirestoreUserService>(context, listen: false);
      
      await firestoreService.createUser(
        uid: 'test_user_${DateTime.now().millisecondsSinceEpoch}',
        email: 'test@example.com',
        nickname: 'Firebase Test User',
      );
      
      setState(() {
        _status = 'User created successfully! Check Firebase Console.';
      });
    } catch (e) {
      setState(() {
        _status = 'User creation failed: $e';
      });
    }
  }
  
  void _forceCrash() {
    // Only crash in debug mode
    if (const bool.fromEnvironment('dart.vm.product')) {
      setState(() {
        _status = 'Crash test only available in debug mode';
      });
      return;
    }
    
    setState(() {
      _status = 'Forcing crash for testing...';
    });
    
    // This will cause a crash to test Crashlytics
    throw Exception('Test crash for Firebase Crashlytics');
  }
}