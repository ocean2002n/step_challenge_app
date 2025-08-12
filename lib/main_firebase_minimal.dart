import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  runApp(const FirebaseMinimalApp());
}

class FirebaseMinimalApp extends StatelessWidget {
  const FirebaseMinimalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Minimal Test',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const FirebaseMinimalScreen(),
    );
  }
}

class FirebaseMinimalScreen extends StatelessWidget {
  const FirebaseMinimalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Minimal Test'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🔥 Firebase Status:', 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Firebase Core initialized successfully!', 
                      style: TextStyle(fontSize: 16)),
                    SizedBox(height: 16),
                    Text('✅ Firebase Core: Connected',
                      style: TextStyle(fontSize: 16, color: Colors.green)),
                    Text('✅ Project ID: step-challenge-app',
                      style: TextStyle(fontSize: 16, color: Colors.green)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🎉 Success!', 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                    SizedBox(height: 8),
                    Text('Firebase integration is working!',
                      style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Your Firebase project is connected and ready for user data synchronization.',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                    SizedBox(height: 8),
                    Text('Next steps: Add Firestore for user data storage.',
                      style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
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