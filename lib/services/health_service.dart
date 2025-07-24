import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import '../models/daily_steps_model.dart';
import 'crashlytics_service.dart';

class HealthService extends ChangeNotifier {
  final Health _health = Health();
  bool _isAuthorized = false;
  int _todaySteps = 0;
  List<DailySteps> _weeklySteps = [];
  int _monthlySteps = 0;
  int _lastMonthSteps = 0;
  
  bool get isAuthorized => _isAuthorized;
  int get todaySteps => _todaySteps;
  List<DailySteps> get weeklySteps => _weeklySteps;
  int get monthlySteps => _monthlySteps;
  int get lastMonthSteps => _lastMonthSteps;

  static const List<HealthDataType> types = [
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.HEART_RATE,
    HealthDataType.WORKOUT,
  ];

  static const List<HealthDataAccess> permissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  /// 初始化健康數據權限
  Future<bool> initialize() async {
    try {
      debugPrint('🏃‍♂️ Starting health data authorization...');
      
      // 檢查 HealthKit 是否可用（iOS 設備默認支援）
      try {
        // 嘗試檢查權限來驗證 HealthKit 是否可用
        await Health().hasPermissions([HealthDataType.STEPS], permissions: [HealthDataAccess.READ]);
        debugPrint('✅ HealthKit available on this device');
      } catch (e, stack) {
        await CrashlyticsService.recordError(e, stack, reason: 'HealthKit availability check failed');
        debugPrint('❌ HealthKit not available on this device: $e');
        _generateMockData();
        notifyListeners();
        return false;
      }
      
      debugPrint('✅ HealthKit available, checking permissions...');
      
      // 檢查現有權限
      final hasPermissions = await Health().hasPermissions(types, permissions: permissions);
      debugPrint('📋 Current permissions status: $hasPermissions');
      
      // 請求健康數據權限
      debugPrint('📝 Requesting health data permissions...');
      _isAuthorized = await _health.requestAuthorization(types, permissions: permissions);
      
      debugPrint('🔐 Health authorization result: $_isAuthorized');
      
      if (_isAuthorized) {
        debugPrint('✅ Health data authorized, loading real data...');
        
        // 嘗試讀取實際的健康數據
        await _loadRealHealthData();
        
        debugPrint('📊 Health data loaded successfully');
      } else {
        debugPrint('❌ Health data not authorized, using mock data');
        _generateMockData();
      }
      
      notifyListeners();
      return _isAuthorized;
    } catch (e, stack) {
      await CrashlyticsService.recordError(e, stack, reason: 'Health service initialization failed');
      debugPrint('💥 Health initialization error: $e');
      _generateMockData();
      notifyListeners();
      return false;
    }
  }

  /// 讀取真實的健康數據 (初始化時使用，失敗會降級到模擬數據)
  Future<void> _loadRealHealthData() async {
    try {
      // 並行讀取所有健康數據
      await Future.wait([
        _loadTodaySteps(),
        _loadWeeklySteps(),
        _loadMonthlySteps(),
        _loadHeartRateData(),
      ]);
    } catch (e, stack) {
      await CrashlyticsService.recordError(e, stack, reason: 'Loading real health data failed');
      debugPrint('Error loading real health data: $e');
      // 如果讀取失敗，使用模擬數據
      _generateMockData();
    }
  }

  /// 強制同步健康數據 (同步時使用，失敗會拋出錯誤)
  Future<void> _forceSyncHealthData() async {
    // 並行讀取所有健康數據，設置 throwOnError: true 讓錯誤向上傳播
    await Future.wait([
      _loadTodaySteps(throwOnError: true),
      _loadWeeklySteps(throwOnError: true),
      _loadMonthlySteps(throwOnError: true),
      _loadHeartRateData(throwOnError: true),
    ]);
  }

  /// 讀取真實的月度步數數據
  Future<void> _loadMonthlySteps({bool throwOnError = false}) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));
      
      final lastMonthStart = DateTime(now.year, now.month - 1, 1);
      final lastMonthEnd = DateTime(now.year, now.month, 1).subtract(const Duration(days: 1));
      
      // 讀取本月步數
      final thisMonthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: startOfMonth,
        endTime: endOfMonth,
      );
      
      _monthlySteps = thisMonthData
          .where((point) => point.type == HealthDataType.STEPS)
          .map((point) => (point.value as NumericHealthValue).numericValue.toInt())
          .fold(0, (sum, steps) => sum + steps);
      
      // 讀取上月步數
      final lastMonthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: lastMonthStart,
        endTime: lastMonthEnd,
      );
      
      _lastMonthSteps = lastMonthData
          .where((point) => point.type == HealthDataType.STEPS)
          .map((point) => (point.value as NumericHealthValue).numericValue.toInt())
          .fold(0, (sum, steps) => sum + steps);
      
      debugPrint('📊 Monthly steps loaded: This month: $_monthlySteps, Last month: $_lastMonthSteps');
    } catch (e, stack) {
      await CrashlyticsService.recordError(e, stack, reason: 'Loading monthly steps failed');
      debugPrint('Error loading monthly steps: $e');
      if (throwOnError) {
        rethrow;
      } else {
        _generateMockMonthlyData();
      }
    }
  }

  /// 讀取心率數據
  Future<void> _loadHeartRateData({bool throwOnError = false}) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
      
      final heartRateData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: startOfDay,
        endTime: endOfDay,
      );
      
      if (heartRateData.isNotEmpty) {
        final averageHeartRate = heartRateData
            .where((point) => point.type == HealthDataType.HEART_RATE)
            .map((point) => (point.value as NumericHealthValue).numericValue.toInt())
            .fold(0, (sum, hr) => sum + hr) / heartRateData.length;
        
        debugPrint('❤️ Average heart rate today: ${averageHeartRate.toInt()} bpm');
      }
    } catch (e, stack) {
      await CrashlyticsService.recordError(e, stack, reason: 'Loading heart rate data failed');
      debugPrint('Error loading heart rate data: $e');
      if (throwOnError) {
        rethrow;
      }
    }
  }

  /// 獲取今日步數
  Future<void> _loadTodaySteps({bool throwOnError = false}) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: types,
        startTime: startOfDay,
        endTime: endOfDay,
      );

      if (healthData.isNotEmpty) {
        _todaySteps = healthData
            .where((point) => point.type == HealthDataType.STEPS)
            .map((point) => (point.value as NumericHealthValue).numericValue.toInt())
            .fold(0, (sum, steps) => sum + steps);
      }

      notifyListeners();
    } catch (e, stack) {
      await CrashlyticsService.recordError(e, stack, reason: 'Loading today steps failed');
      debugPrint('Error loading today steps: $e');
      if (throwOnError) {
        rethrow; // 重新拋出錯誤
      }
    }
  }

  /// 獲取過去7天步數
  Future<void> _loadWeeklySteps({bool throwOnError = false}) async {
    try {
      final now = DateTime.now();
      
      List<DailySteps> weeklyData = [];

      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

        List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
          types: types,
          startTime: startOfDay,
          endTime: endOfDay,
        );

        int daySteps = 0;
        if (healthData.isNotEmpty) {
          daySteps = healthData
              .where((point) => point.type == HealthDataType.STEPS)
              .map((point) => (point.value as NumericHealthValue).numericValue.toInt())
              .fold(0, (sum, steps) => sum + steps);
        }

        weeklyData.add(DailySteps(
          userId: 'current_user', // 將由用戶管理系統提供
          date: startOfDay,
          steps: daySteps,
          goalAchieved: daySteps >= 10000, // 預設目標
          syncTime: DateTime.now(),
          deviceType: _getDeviceType(),
        ));
      }

      _weeklySteps = weeklyData.reversed.toList();
      notifyListeners();
    } catch (e, stack) {
      await CrashlyticsService.recordError(e, stack, reason: 'Loading weekly steps failed');
      debugPrint('Error loading weekly steps: $e');
      if (throwOnError) {
        rethrow;
      }
    }
  }

  /// 獲取指定日期範圍的步數數據
  Future<List<DailySteps>> getStepsInRange(DateTime startDate, DateTime endDate) async {
    try {
      List<DailySteps> rangeData = [];
      
      for (DateTime date = startDate; 
           date.isBefore(endDate) || date.isAtSameMomentAs(endDate); 
           date = date.add(const Duration(days: 1))) {
        
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

        List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
          types: types,
          startTime: startOfDay,
          endTime: endOfDay,
        );

        int daySteps = 0;
        if (healthData.isNotEmpty) {
          daySteps = healthData
              .where((point) => point.type == HealthDataType.STEPS)
              .map((point) => (point.value as NumericHealthValue).numericValue.toInt())
              .fold(0, (sum, steps) => sum + steps);
        }

        rangeData.add(DailySteps(
          userId: 'current_user',
          date: startOfDay,
          steps: daySteps,
          goalAchieved: daySteps >= 10000,
          syncTime: DateTime.now(),
          deviceType: _getDeviceType(),
        ));
      }

      return rangeData;
    } catch (e, stack) {
      await CrashlyticsService.recordError(e, stack, reason: 'Getting steps in range failed');
      debugPrint('Error getting steps in range: $e');
      return [];
    }
  }

  /// 重新同步健康數據
  Future<void> syncHealthData() async {
    debugPrint('🔄 Starting health data sync...');
    
    // 如果沒有授權，先嘗試初始化
    if (!_isAuthorized) {
      debugPrint('📝 Not authorized, reinitializing...');
      final success = await initialize();
      if (!success || !_isAuthorized) {
        debugPrint('❌ Authorization failed');
        throw Exception('無法獲取健康數據權限，請在設定中授權健康數據存取');
      }
    }

    try {
      debugPrint('📱 Syncing health data from Apple Health...');
      
      // 強制同步真實健康數據，失敗會拋出錯誤
      await _forceSyncHealthData();
      
      debugPrint('✅ Health data sync completed successfully');
      notifyListeners();
      
    } catch (e, stack) {
      await CrashlyticsService.recordError(e, stack, reason: 'Health data sync failed');
      debugPrint('💥 Health sync error: $e');
      
      // 拋出用戶友好的錯誤訊息
      if (e.toString().contains('Permission')) {
        throw Exception('健康數據權限不足，請檢查設定中的健康數據權限');
      } else if (e.toString().contains('Network') || e.toString().contains('network')) {
        throw Exception('網路連線問題，請檢查網路連線後重試');
      } else {
        throw Exception('健康數據同步失敗，請稍後重試');
      }
    }
  }

  /// 強制重新授權並同步
  Future<bool> forceReauthorizeAndSync() async {
    debugPrint('🔐 Force reauthorizing health data...');
    
    try {
      // 重新請求權限
      _isAuthorized = await _health.requestAuthorization(types, permissions: permissions);
      
      if (_isAuthorized) {
        debugPrint('✅ Reauthorization successful, syncing data...');
        await _loadRealHealthData();
        notifyListeners();
        return true;
      } else {
        debugPrint('❌ Reauthorization failed');
        return false;
      }
    } catch (e, stack) {
      await CrashlyticsService.recordError(e, stack, reason: 'Force reauthorization failed');
      debugPrint('💥 Force reauthorization error: $e');
      return false;
    }
  }

  /// 檢查健康數據權限狀態
  Future<Map<String, dynamic>> checkHealthPermissions() async {
    try {
      final hasPermissions = await Health().hasPermissions(types, permissions: permissions);
      final isAuthorized = await _health.requestAuthorization(types, permissions: permissions);
      
      return {
        'hasPermissions': hasPermissions ?? false,
        'isAuthorized': isAuthorized,
        'currentAuthStatus': _isAuthorized,
        'supportedTypes': types.map((type) => type.name).toList(),
      };
    } catch (e, stack) {
      await CrashlyticsService.recordError(e, stack, reason: 'Checking health permissions failed');
      debugPrint('Error checking health permissions: $e');
      return {
        'hasPermissions': false,
        'isAuthorized': false,
        'currentAuthStatus': false,
        'error': e.toString(),
      };
    }
  }

  /// 檢查是否達成今日目標
  bool checkTodayGoalAchieved(int dailyGoal) {
    return _todaySteps >= dailyGoal;
  }

  /// 獲取設備類型
  String _getDeviceType() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'iOS';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'Android';
    }
    return 'Unknown';
  }

  /// 獲取本週總步數
  int getWeeklyTotalSteps() {
    return _weeklySteps.fold(0, (sum, day) => sum + day.steps);
  }

  /// 獲取本週平均步數
  double getWeeklyAverageSteps() {
    if (_weeklySteps.isEmpty) return 0.0;
    return getWeeklyTotalSteps() / _weeklySteps.length;
  }

  /// 獲取本週達成目標天數
  int getWeeklyGoalsAchieved(int dailyGoal) {
    return _weeklySteps.where((day) => day.steps >= dailyGoal).length;
  }

  /// Generate mock monthly steps data for demo purposes
  void _generateMockMonthlyData() {
    final random = Random();
    _monthlySteps = random.nextInt(40000) + 20000; // 20K-60K steps this month
    _lastMonthSteps = random.nextInt(35000) + 25000; // 25K-60K steps last month
  }

  /// Generate all mock data for demo when health access is not available
  void _generateMockData() {
    final random = Random();
    
    // Generate today's steps
    _todaySteps = random.nextInt(8000) + 2000; // 2K-10K steps
    
    // Generate weekly steps
    final weeklyData = <DailySteps>[];
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final steps = random.nextInt(12000) + 3000; // 3K-15K steps per day
      weeklyData.add(DailySteps(
        userId: 'current_user',
        date: date,
        steps: steps,
        goalAchieved: steps >= 10000,
        syncTime: DateTime.now(),
        deviceType: 'Demo Device',
      ));
    }
    _weeklySteps = weeklyData;
    
    // Generate monthly data
    _generateMockMonthlyData();
  }
}