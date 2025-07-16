import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService extends ChangeNotifier {
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;
  
  bool get isInitialized => _isInitialized;

  /// 初始化通知服務
  static Future<void> initialize() async {
    try {
      // 初始化本地通知
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      await _localNotifications.initialize(initSettings);
      
      debugPrint('Local notifications initialized');
    } catch (e) {
      debugPrint('Notification initialization error: $e');
    }
  }

  /// 完成初始化設置
  Future<void> completeInitialization() async {
    try {
      _isInitialized = true;
      notifyListeners();
      debugPrint('Notification service initialization completed');
    } catch (e) {
      debugPrint('Complete initialization error: $e');
    }
  }

  /// 顯示本地通知
  static Future<void> _showLocalNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'step_challenge_channel',
      'Step Challenge Notifications',
      channelDescription: 'Notifications for step challenges and goals',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  /// 發送目標達成通知
  Future<void> showGoalAchievedNotification(int steps, int goal) async {
    await _showLocalNotification(
      '🎉 目標達成！',
      '恭喜！您今天已走了 $steps 步，超越了 $goal 步的目標！',
    );
  }

  /// 發送挑戰邀請通知
  Future<void> showChallengeInviteNotification(String challengeName, String inviterName) async {
    await _showLocalNotification(
      '挑戰邀請',
      '$inviterName 邀請您參加「$challengeName」挑戰！',
    );
  }

  /// 發送挑戰完成通知
  Future<void> showChallengeCompletedNotification(String challengeName, String userName) async {
    await _showLocalNotification(
      '🏆 挑戰完成！',
      '$userName 完成了「$challengeName」挑戰！',
    );
  }

  /// 發送挑戰進度更新通知
  Future<void> showChallengeProgressNotification(String challengeName, int progress, int total) async {
    final percentage = ((progress / total) * 100).round();
    await _showLocalNotification(
      '挑戰進度更新',
      '「$challengeName」已完成 $percentage%！還差一點就達成目標了！',
    );
  }

  /// 取消所有通知
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// 取消特定通知
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }
}