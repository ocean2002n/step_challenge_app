import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/firestore_user.dart';
import 'crashlytics_service.dart';

/// Firestore 用戶資料同步服務
/// 負責處理用戶資料的雲端存儲和本地同步
class FirestoreUserService extends ChangeNotifier {
  static const String _usersCollection = 'users';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  FirestoreUser? _currentUser;
  StreamSubscription<DocumentSnapshot>? _userSubscription;
  bool _isInitialized = false;
  bool _isSyncing = false;
  
  /// 當前用戶資料
  FirestoreUser? get currentUser => _currentUser;
  
  /// 是否已初始化
  bool get isInitialized => _isInitialized;
  
  /// 是否正在同步
  bool get isSyncing => _isSyncing;
  
  /// 初始化服務
  Future<void> initialize() async {
    try {
      debugPrint('🔥 Initializing FirestoreUserService...');
      
      // 監聽認證狀態變化
      _auth.authStateChanges().listen(_onAuthStateChanged);
      
      // 如果已有登入用戶，立即開始監聽
      final currentAuthUser = _auth.currentUser;
      if (currentAuthUser != null) {
        await _startUserListener(currentAuthUser.uid);
      }
      
      _isInitialized = true;
      debugPrint('✅ FirestoreUserService initialized');
    } catch (e, stack) {
      debugPrint('❌ FirestoreUserService initialization failed: $e');
      await CrashlyticsService.recordError(e, stack, reason: 'FirestoreUserService initialization failed');
    }
  }
  
  /// 處理認證狀態變化
  Future<void> _onAuthStateChanged(User? user) async {
    try {
      if (user != null) {
        debugPrint('🔥 Auth state changed: User signed in (${user.uid})');
        await _startUserListener(user.uid);
      } else {
        debugPrint('🔥 Auth state changed: User signed out');
        await _stopUserListener();
        _currentUser = null;
        notifyListeners();
      }
    } catch (e, stack) {
      debugPrint('❌ Error handling auth state change: $e');
      await CrashlyticsService.recordError(e, stack, reason: 'Auth state change handling failed');
    }
  }
  
  /// 開始監聽用戶資料變化
  Future<void> _startUserListener(String uid) async {
    try {
      debugPrint('👂 Starting user listener for UID: $uid');
      
      // 停止之前的監聽
      await _stopUserListener();
      
      // 開始新的監聽
      _userSubscription = _firestore
          .collection(_usersCollection)
          .doc(uid)
          .snapshots()
          .listen(
            _onUserDocumentChanged,
            onError: (error, stack) async {
              debugPrint('❌ User document listener error: $error');
              await CrashlyticsService.recordError(error, stack, reason: 'User document listener error');
            },
          );
    } catch (e, stack) {
      debugPrint('❌ Error starting user listener: $e');
      await CrashlyticsService.recordError(e, stack, reason: 'Failed to start user listener');
    }
  }
  
  /// 停止監聽用戶資料變化
  Future<void> _stopUserListener() async {
    await _userSubscription?.cancel();
    _userSubscription = null;
  }
  
  /// 處理用戶文檔變化
  void _onUserDocumentChanged(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    try {
      if (snapshot.exists) {
        _currentUser = FirestoreUser.fromFirestore(snapshot);
        debugPrint('📄 User document updated: ${_currentUser?.nickname ?? _currentUser?.uid}');
      } else {
        _currentUser = null;
        debugPrint('📄 User document does not exist');
      }
      notifyListeners();
    } catch (e, stack) {
      debugPrint('❌ Error processing user document change: $e');
      CrashlyticsService.recordError(e, stack, reason: 'User document processing failed');
    }
  }
  
  /// 創建新用戶資料
  Future<FirestoreUser> createUser({
    required String uid,
    String? email,
    String? nickname,
    String? gender,
    DateTime? birthDate,
    double? height,
    double? weight,
    String? profilePhotoUrl,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? socialAccounts,
  }) async {
    try {
      debugPrint('👤 Creating new user: $uid');
      _isSyncing = true;
      notifyListeners();
      
      final now = DateTime.now();
      final newUser = FirestoreUser(
        uid: uid,
        email: email,
        nickname: nickname,
        gender: gender,
        birthDate: birthDate,
        height: height,
        weight: weight,
        profilePhotoUrl: profilePhotoUrl,
        registrationDate: now,
        lastUpdated: now,
        preferences: preferences ?? UserPreferences().toMap(),
        socialAccounts: socialAccounts ?? {},
      );
      
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .set(newUser.toFirestore());
      
      debugPrint('✅ User created successfully: $uid');
      await CrashlyticsService.recordUserAction('user_created');
      
      return newUser;
    } catch (e, stack) {
      debugPrint('❌ Error creating user: $e');
      await CrashlyticsService.recordError(e, stack, reason: 'User creation failed');
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
  
  /// 更新用戶資料
  Future<void> updateUser({
    String? email,
    String? nickname,
    String? gender,
    DateTime? birthDate,
    double? height,
    double? weight,
    String? profilePhotoUrl,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? socialAccounts,
  }) async {
    try {
      final currentAuthUser = _auth.currentUser;
      if (currentAuthUser == null) {
        throw Exception('No authenticated user');
      }
      
      debugPrint('📝 Updating user: ${currentAuthUser.uid}');
      _isSyncing = true;
      notifyListeners();
      
      final updateData = <String, dynamic>{
        'lastUpdated': Timestamp.fromDate(DateTime.now()),
      };
      
      if (email != null) updateData['email'] = email;
      if (nickname != null) updateData['nickname'] = nickname;
      if (gender != null) updateData['gender'] = gender;
      if (birthDate != null) updateData['birthDate'] = Timestamp.fromDate(birthDate);
      if (height != null) updateData['height'] = height;
      if (weight != null) updateData['weight'] = weight;
      if (profilePhotoUrl != null) updateData['profilePhotoUrl'] = profilePhotoUrl;
      if (preferences != null) updateData['preferences'] = preferences;
      if (socialAccounts != null) updateData['socialAccounts'] = socialAccounts;
      
      await _firestore
          .collection(_usersCollection)
          .doc(currentAuthUser.uid)
          .update(updateData);
      
      debugPrint('✅ User updated successfully');
      await CrashlyticsService.recordUserAction('user_updated');
      
    } catch (e, stack) {
      debugPrint('❌ Error updating user: $e');
      await CrashlyticsService.recordError(e, stack, reason: 'User update failed');
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
  
  /// 更新用戶偏好設定
  Future<void> updatePreferences(UserPreferences preferences) async {
    await updateUser(preferences: preferences.toMap());
  }
  
  /// 添加或更新社交帳戶資訊
  Future<void> addSocialAccount(SocialAccountInfo accountInfo) async {
    try {
      final currentSocialAccounts = _currentUser?.socialAccounts ?? {};
      currentSocialAccounts[accountInfo.provider] = accountInfo.toMap();
      
      await updateUser(socialAccounts: currentSocialAccounts);
      
      debugPrint('✅ Social account added: ${accountInfo.provider}');
    } catch (e, stack) {
      debugPrint('❌ Error adding social account: $e');
      await CrashlyticsService.recordError(e, stack, reason: 'Add social account failed');
      rethrow;
    }
  }
  
  /// 移除社交帳戶資訊
  Future<void> removeSocialAccount(String provider) async {
    try {
      final currentSocialAccounts = Map<String, dynamic>.from(_currentUser?.socialAccounts ?? {});
      currentSocialAccounts.remove(provider);
      
      await updateUser(socialAccounts: currentSocialAccounts);
      
      debugPrint('✅ Social account removed: $provider');
    } catch (e, stack) {
      debugPrint('❌ Error removing social account: $e');
      await CrashlyticsService.recordError(e, stack, reason: 'Remove social account failed');
      rethrow;
    }
  }
  
  /// 獲取用戶資料（一次性）
  Future<FirestoreUser?> getUser(String uid) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .get();
      
      if (doc.exists) {
        return FirestoreUser.fromFirestore(doc);
      }
      return null;
    } catch (e, stack) {
      debugPrint('❌ Error getting user: $e');
      await CrashlyticsService.recordError(e, stack, reason: 'Get user failed');
      return null;
    }
  }
  
  /// 檢查用戶是否存在
  Future<bool> userExists(String uid) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .get();
      return doc.exists;
    } catch (e, stack) {
      debugPrint('❌ Error checking user existence: $e');
      await CrashlyticsService.recordError(e, stack, reason: 'Check user existence failed');
      return false;
    }
  }
  
  /// 刪除用戶資料
  Future<void> deleteUser(String uid) async {
    try {
      debugPrint('🗑️ Deleting user: $uid');
      _isSyncing = true;
      notifyListeners();
      
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .delete();
      
      debugPrint('✅ User deleted successfully: $uid');
      await CrashlyticsService.recordUserAction('user_deleted');
      
    } catch (e, stack) {
      debugPrint('❌ Error deleting user: $e');
      await CrashlyticsService.recordError(e, stack, reason: 'User deletion failed');
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
  
  /// 批量操作（事務）
  Future<void> batchUpdate(List<Map<String, dynamic>> updates) async {
    try {
      debugPrint('📦 Performing batch update');
      _isSyncing = true;
      notifyListeners();
      
      final batch = _firestore.batch();
      final currentAuthUser = _auth.currentUser;
      
      if (currentAuthUser == null) {
        throw Exception('No authenticated user');
      }
      
      final userRef = _firestore.collection(_usersCollection).doc(currentAuthUser.uid);
      
      for (final update in updates) {
        batch.update(userRef, {
          ...update,
          'lastUpdated': Timestamp.fromDate(DateTime.now()),
        });
      }
      
      await batch.commit();
      
      debugPrint('✅ Batch update completed');
      await CrashlyticsService.recordUserAction('user_batch_updated');
      
    } catch (e, stack) {
      debugPrint('❌ Error in batch update: $e');
      await CrashlyticsService.recordError(e, stack, reason: 'Batch update failed');
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
  
  /// 手動同步（強制重新獲取）
  Future<void> forcSync() async {
    try {
      final currentAuthUser = _auth.currentUser;
      if (currentAuthUser == null) {
        debugPrint('⚠️ No authenticated user for sync');
        return;
      }
      
      debugPrint('🔄 Force syncing user data');
      _isSyncing = true;
      notifyListeners();
      
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(currentAuthUser.uid)
          .get();
      
      if (doc.exists) {
        _currentUser = FirestoreUser.fromFirestore(doc);
        debugPrint('✅ Force sync completed');
      } else {
        debugPrint('⚠️ User document not found during force sync');
      }
      
    } catch (e, stack) {
      debugPrint('❌ Error in force sync: $e');
      await CrashlyticsService.recordError(e, stack, reason: 'Force sync failed');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
  
  /// 清理資源
  @override
  void dispose() {
    _stopUserListener();
    super.dispose();
  }
  
  /// 獲取用戶統計資訊
  Map<String, dynamic> getUserStats() {
    if (_currentUser == null) return {};
    
    return {
      'uid': _currentUser!.uid,
      'registrationDays': DateTime.now().difference(_currentUser!.registrationDate).inDays,
      'age': _currentUser!.age,
      'bmi': _currentUser!.bmi,
      'bmiCategory': _currentUser!.bmiCategory,
      'hasProfilePhoto': _currentUser!.profilePhotoUrl != null,
      'connectedSocialAccounts': _currentUser!.socialAccounts?.keys.toList() ?? [],
      'lastUpdated': _currentUser!.lastUpdated,
    };
  }
}