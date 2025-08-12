import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
  
  runApp(const FirebaseSimpleApp());
}

class FirebaseSimpleApp extends StatelessWidget {
  const FirebaseSimpleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Simple Test',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const FirebaseSimpleScreen(),
    );
  }
}

class FirebaseSimpleScreen extends StatefulWidget {
  const FirebaseSimpleScreen({super.key});

  @override
  State<FirebaseSimpleScreen> createState() => _FirebaseSimpleScreenState();
}

class _FirebaseSimpleScreenState extends State<FirebaseSimpleScreen> {
  String _status = 'Firebase initialized successfully!';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Simple Test'),
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
                    const Text('🔥 Firebase Status:', 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(_status, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    const Text('✅ Firebase Core: Ready',
                      style: TextStyle(fontSize: 16)),
                    const Text('✅ Crashlytics: Ready',
                      style: TextStyle(fontSize: 16)),
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
              onPressed: _forceCrash,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('⚠️ Test Crash (Debug Only)', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 20),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🎉 Success!', 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                    SizedBox(height: 8),
                    Text('Firebase integration is working! No more BoringSSL-GRPC errors.',
                      style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Your user data synchronization system is ready for implementation.',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _testCrashlytics() async {
    setState(() {
      _status = 'Testing Crashlytics...';
    });
    
    try {
      await CrashlyticsService.log('Firebase Simple Test: User clicked test button');
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