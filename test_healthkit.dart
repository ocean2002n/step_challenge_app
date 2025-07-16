import 'package:flutter/material.dart';
import 'package:health/health.dart';

void main() {
  runApp(const HealthKitTestApp());
}

class HealthKitTestApp extends StatelessWidget {
  const HealthKitTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthKit Test',
      home: const HealthKitTestScreen(),
    );
  }
}

class HealthKitTestScreen extends StatefulWidget {
  const HealthKitTestScreen({super.key});

  @override
  State<HealthKitTestScreen> createState() => _HealthKitTestScreenState();
}

class _HealthKitTestScreenState extends State<HealthKitTestScreen> {
  String _status = 'Testing HealthKit integration...';
  String _result = '';

  @override
  void initState() {
    super.initState();
    _testHealthKit();
  }

  Future<void> _testHealthKit() async {
    try {
      final health = Health();
      
      setState(() {
        _status = '🏃‍♂️ Testing HealthKit availability...';
      });

      // 測試權限請求
      const types = [
        HealthDataType.STEPS,
        HealthDataType.HEART_RATE,
        HealthDataType.DISTANCE_WALKING_RUNNING,
      ];
      
      const permissions = [
        HealthDataAccess.READ,
        HealthDataAccess.READ,
        HealthDataAccess.READ,
      ];

      setState(() {
        _status = '🔐 Requesting HealthKit permissions...';
      });

      final isAuthorized = await health.requestAuthorization(types, permissions: permissions);
      
      print('🔐 HealthKit authorization result: $isAuthorized');
      
      if (isAuthorized) {
        setState(() {
          _status = '✅ HealthKit authorized! Reading data...';
        });
        
        // 讀取今日步數
        final now = DateTime.now();
        final startOfDay = DateTime(now.year, now.month, now.day);
        final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
        
        final healthData = await health.getHealthDataFromTypes(
          types: [HealthDataType.STEPS],
          startTime: startOfDay,
          endTime: endOfDay,
        );
        
        int todaySteps = 0;
        if (healthData.isNotEmpty) {
          todaySteps = healthData
              .where((point) => point.type == HealthDataType.STEPS)
              .map((point) => (point.value as NumericHealthValue).numericValue.toInt())
              .fold(0, (sum, steps) => sum + steps);
        }
        
        setState(() {
          _status = '🎉 Success!';
          _result = '''
✅ HealthKit integration working!
📊 Today's steps: $todaySteps
📱 Data points found: ${healthData.length}
🏥 Authorization: $isAuthorized

Now check:
Settings → Privacy & Security → Health → Data Access & Devices
Your app should appear in the list!
          ''';
        });
        
        print('📊 Today\'s steps: $todaySteps');
        print('📱 Data points found: ${healthData.length}');
        
      } else {
        setState(() {
          _status = '❌ HealthKit authorization denied';
          _result = '''
❌ HealthKit authorization was denied.

Please check:
1. Are you running on a real iOS device?
2. Is HealthKit available on this device?
3. Check iOS Settings → Privacy & Security → Health

If the app doesn't appear in Health settings, the entitlements may not be properly configured.
          ''';
        });
      }
    } catch (e) {
      setState(() {
        _status = '💥 Error occurred';
        _result = '''
💥 HealthKit test failed: $e

This could mean:
1. Running on simulator (HealthKit requires real device)
2. HealthKit entitlements not properly configured
3. iOS version compatibility issues

Please ensure:
- Running on real iOS device
- HealthKit capability is added in Xcode
- Proper entitlements file is referenced
        ''';
      });
      
      print('💥 HealthKit test error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthKit Test'),
        backgroundColor: Colors.red[400],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status:',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_result.isNotEmpty)
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Result:',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _result,
                            style: const TextStyle(fontSize: 14, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _testHealthKit,
                child: const Text('Test Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}