import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import '../models/daily_steps_model.dart';

class HealthService extends ChangeNotifier {
  Health _health = Health();
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
  ];

  static const List<HealthDataAccess> permissions = [
    HealthDataAccess.READ,
  ];

  /// 初始化健康數據權限
  Future<bool> initialize() async {
    try {
      debugPrint('Starting health data authorization...');
      
      // 檢查平台是否支持 HealthKit
      if (!await Health().hasPermissions(types, permissions: permissions)) {
        debugPrint('Health permissions not granted, requesting...');
      }
      
      // 請求健康數據權限
      _isAuthorized = await _health.requestAuthorization(types, permissions: permissions);
      
      debugPrint('Health authorization result: $_isAuthorized');
      
      if (_isAuthorized) {
        debugPrint('Health data authorized, loading data...');
        await _loadTodaySteps();
        await _loadWeeklySteps();
        _generateMockMonthlyData();
      } else {
        debugPrint('Health data not authorized, using mock data');
        // Generate mock data for demo purposes when health access is not available
        _generateMockData();
      }
      
      notifyListeners();
      return _isAuthorized;
    } catch (e) {
      debugPrint('Health initialization error: $e');
      // 如果發生錯誤，使用模擬數據
      _generateMockData();
      notifyListeners();
      return false;
    }
  }

  /// 獲取今日步數
  Future<void> _loadTodaySteps() async {
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
    } catch (e) {
      debugPrint('Error loading today steps: $e');
    }
  }

  /// 獲取過去7天步數
  Future<void> _loadWeeklySteps() async {
    try {
      final now = DateTime.now();
      final oneWeekAgo = now.subtract(const Duration(days: 7));
      
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
    } catch (e) {
      debugPrint('Error loading weekly steps: $e');
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
    } catch (e) {
      debugPrint('Error getting steps in range: $e');
      return [];
    }
  }

  /// 重新同步健康數據
  Future<void> syncHealthData() async {
    debugPrint('Syncing health data...');
    
    if (!_isAuthorized) {
      debugPrint('Not authorized, reinitializing...');
      await initialize();
      return;
    }

    try {
      await _loadTodaySteps();
      await _loadWeeklySteps();
      debugPrint('Health data sync completed');
    } catch (e) {
      debugPrint('Health sync error: $e');
    }
  }

  /// 檢查健康數據權限狀態
  Future<Map<String, dynamic>> checkHealthPermissions() async {
    try {
      final hasPermissions = await Health().hasPermissions(types, permissions: permissions);
      final isAuthorized = await _health.requestAuthorization(types, permissions: permissions);
      
      return {
        'hasPermissions': hasPermissions,
        'isAuthorized': isAuthorized,
        'currentAuthStatus': _isAuthorized,
        'supportedTypes': types.map((type) => type.name).toList(),
      };
    } catch (e) {
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