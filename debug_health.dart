import 'package:flutter/material.dart';
import 'package:health/health.dart';

void main() {
  runApp(const HealthDebugApp());
}

class HealthDebugApp extends StatelessWidget {
  const HealthDebugApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Debug',
      home: const HealthDebugScreen(),
    );
  }
}

class HealthDebugScreen extends StatefulWidget {
  const HealthDebugScreen({super.key});

  @override
  State<HealthDebugScreen> createState() => _HealthDebugScreenState();
}

class _HealthDebugScreenState extends State<HealthDebugScreen> {
  String _status = 'Testing...';
  
  @override
  void initState() {
    super.initState();
    _testHealthPermissions();
  }

  Future<void> _testHealthPermissions() async {
    try {
      final health = Health();
      const types = [HealthDataType.STEPS];
      const permissions = [HealthDataAccess.READ];
      
      print('=== Health Debug Test ===');
      print('1. Testing health permissions...');
      
      final hasPermissions = await health.hasPermissions(types, permissions: permissions);
      print('2. Has permissions: $hasPermissions');
      
      final isAuthorized = await health.requestAuthorization(types, permissions: permissions);
      print('3. Authorization result: $isAuthorized');
      
      if (isAuthorized) {
        final now = DateTime.now();
        final startOfDay = DateTime(now.year, now.month, now.day);
        final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
        
        print('4. Fetching health data...');
        List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
          types: types,
          startTime: startOfDay,
          endTime: endOfDay,
        );
        
        print('5. Health data count: ${healthData.length}');
        
        if (healthData.isNotEmpty) {
          final steps = healthData
              .where((point) => point.type == HealthDataType.STEPS)
              .map((point) => (point.value as NumericHealthValue).numericValue.toInt())
              .fold(0, (sum, steps) => sum + steps);
          
          print('6. Today\'s steps: $steps');
          
          setState(() {
            _status = '✅ Health data working!\nToday\'s steps: $steps';
          });
        } else {
          setState(() {
            _status = '⚠️ No health data found';
          });
        }
      } else {
        setState(() {
          _status = '❌ Health authorization failed';
        });
      }
    } catch (e) {
      print('Health test error: $e');
      setState(() {
        _status = '❌ Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Debug'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Health Permission Test',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              _status,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _testHealthPermissions,
              child: const Text('Test Again'),
            ),
          ],
        ),
      ),
    );
  }
}