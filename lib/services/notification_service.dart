import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService extends ChangeNotifier {
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  static FirebaseMessaging? _firebaseMessaging;
  bool _isInitialized = false;
  String? _fcmToken;
  
  bool get isInitialized => _isInitialized;
  String? get fcmToken => _fcmToken;

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
      
      // 初始化 Firebase Messaging
      _firebaseMessaging = FirebaseMessaging.instance;
      
      // 請求通知權限
      await _requestNotificationPermissions();
    } catch (e) {
      debugPrint('Notification initialization error: $e');
    }
  }

  /// 完成初始化設置
  Future<void> completeInitialization() async {
    try {
      if (_firebaseMessaging != null) {
        // 獲取 FCM Token
        _fcmToken = await _firebaseMessaging!.getToken();
        debugPrint('FCM Token: $_fcmToken');
        
        // 監聽前台消息
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        
        // 監聽後台消息點擊
        FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
        
        _isInitialized = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Complete initialization error: $e');
    }
  }

  /// 請求通知權限
  static Future<void> _requestNotificationPermissions() async {
    try {
      if (_firebaseMessaging != null) {
        NotificationSettings settings = await _firebaseMessaging!.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          announcement: false,
        );
        
        debugPrint('Notification permission status: ${settings.authorizationStatus}');
      }
    } catch (e) {
      debugPrint('Request notification permissions error: $e');
    }
  }

  /// 處理前台消息
  static void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message: ${message.notification?.title}');
    
    if (message.notification != null) {
      _showLocalNotification(
        message.notification!.title ?? '',
        message.notification!.body ?? '',
      );
    }
  }

  /// 處理後台消息點擊
  static void _handleBackgroundMessage(RemoteMessage message) {
    debugPrint('Background message clicked: ${message.notification?.title}');
    // 這裡可以處理特定的導航邏輯
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

  /// 發送每日目標提醒
  Future<void> scheduleDailyGoalReminder(int hour, int minute) async {
    try {
      await _localNotifications.zonedSchedule(
        1, // notification ID
        '步數目標提醒',
        '今天還沒達成步數目標，加油走起來！',
        tz.TZDateTime.from(_nextInstanceOfTime(hour, minute), tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder_channel',
            'Daily Goal Reminder',
            channelDescription: 'Daily step goal reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Schedule daily reminder error: $e');
    }
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

  /// 計算下次指定時間
  static DateTime _nextInstanceOfTime(int hour, int minute) {
    final now = DateTime.now();
    DateTime scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  /// 更新 FCM Token
  Future<void> updateFcmToken() async {
    try {
      if (_firebaseMessaging != null) {
        _fcmToken = await _firebaseMessaging!.getToken();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Update FCM token error: $e');
    }
  }
}