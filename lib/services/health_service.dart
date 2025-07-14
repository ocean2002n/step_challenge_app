import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/daily_steps_model.dart';

class HealthService extends ChangeNotifier {
  Health _health = Health();
  bool _isAuthorized = false;
  int _todaySteps = 0;
  List<DailySteps> _weeklySteps = [];
  
  bool get isAuthorized => _isAuthorized;
  int get todaySteps => _todaySteps;
  List<DailySteps> get weeklySteps => _weeklySteps;

  static const List<HealthDataType> types = [
    HealthDataType.STEPS,
  ];

  static const List<HealthDataAccess> permissions = [
    HealthDataAccess.READ,
  ];

  /// 初始化健康數據權限
  Future<bool> initialize() async {
    try {
      // 請求健康數據權限
      _isAuthorized = await _health.requestAuthorization(types, permissions: permissions);
      
      if (_isAuthorized) {
        await _loadTodaySteps();
        await _loadWeeklySteps();
      }
      
      notifyListeners();
      return _isAuthorized;
    } catch (e) {
      debugPrint('Health initialization error: $e');
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
        startOfDay,
        endOfDay,
        types,
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
          startOfDay,
          endOfDay,
          types,
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
          startOfDay,
          endOfDay,
          types,
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
    if (!_isAuthorized) {
      await initialize();
      return;
    }

    await _loadTodaySteps();
    await _loadWeeklySteps();
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
}