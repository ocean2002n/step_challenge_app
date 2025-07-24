import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/friend_model.dart';
import 'crashlytics_service.dart';

class FriendService extends ChangeNotifier {
  static const String _friendsKey = 'friends_list';
  static const String _userIdKey = 'user_id';
  
  List<Friend> _friends = [];
  String? _currentUserId;
  bool _isLoading = false;

  List<Friend> get friends => List.unmodifiable(_friends);
  String? get currentUserId => _currentUserId;
  bool get isLoading => _isLoading;

  // Initialize service
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get or create user ID
      _currentUserId = prefs.getString(_userIdKey);
      // Force regenerate if current ID is not 5 characters (for upgrade compatibility)
      if (_currentUserId == null || _currentUserId!.length != 5) {
        _currentUserId = _generateUserId();
        await prefs.setString(_userIdKey, _currentUserId!);
        debugPrint('Generated new 5-character user ID: $_currentUserId');
      }

      // Load friends list
      await _loadFriends();
    } catch (e, stack) {
      await CrashlyticsService.recordError(e, stack, reason: 'FriendService initialization failed');
      debugPrint('Error initializing FriendService: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Generate unique user ID (5 characters max, alphanumeric only)
  String _generateUserId() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(5, (index) => chars[random.nextInt(chars.length)]).join();
  }

  // Load friends from SharedPreferences
  Future<void> _loadFriends() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final friendsJson = prefs.getString(_friendsKey);
      
      if (friendsJson != null) {
        final List<dynamic> friendsList = json.decode(friendsJson);
        _friends = friendsList.map((json) => Friend.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading friends: $e');
    }
  }

  // Save friends to SharedPreferences
  Future<void> _saveFriends() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final friendsJson = json.encode(_friends.map((f) => f.toJson()).toList());
      await prefs.setString(_friendsKey, friendsJson);
    } catch (e) {
      debugPrint('Error saving friends: $e');
    }
  }

  // Generate invite code for current user (simplified)
  String generateInviteCode() {
    if (_currentUserId == null) return '';
    // Use user ID directly as invite code
    return _currentUserId!;
  }

  // Generate invite link with app store fallback
  String generateInviteLink() {
    final inviteCode = generateInviteCode();
    // 使用 custom scheme 作為主要分享連結
    // 因為 universal links 需要真實的域名和 AASA 文件
    return 'stepchallenge://invite?code=$inviteCode';
  }

  // Generate deep link for app-to-app sharing (same as invite link for now)
  String generateDeepLink() {
    final inviteCode = generateInviteCode();
    return 'stepchallenge://invite?code=$inviteCode';
  }
  
  // Generate shareable text with deep link
  String generateShareableText() {
    final inviteCode = generateInviteCode();
    final deepLink = generateDeepLink();
    
    return '''🚶 加入我的 Step Challenge 好友！

📱 點擊連結加入：$deepLink

🔍 手動輸入邀請碼：$inviteCode

一起來挑戰每日步數目標吧！🎯''';
  }

  // Parse invite code and extract user ID (simplified)
  String? parseInviteCode(String inviteCode) {
    try {
      // Clean up the invite code (remove whitespace, convert to uppercase)
      final cleanCode = inviteCode.trim().toUpperCase();
      
      // Validate format (should be 5 alphanumeric characters)
      if (cleanCode.length == 5 && RegExp(r'^[A-Z0-9]{5}$').hasMatch(cleanCode)) {
        return cleanCode;
      }
    } catch (e) {
      debugPrint('Error parsing invite code: $e');
    }
    return null;
  }

  // Add friend by invite code
  Future<bool> addFriendByInviteCode(String inviteCode) async {
    try {
      final friendId = parseInviteCode(inviteCode);
      if (friendId == null || friendId == _currentUserId) {
        return false; // Invalid code or trying to add self
      }

      // Check if already friends
      if (_friends.any((friend) => friend.id == friendId)) {
        return false; // Already friends
      }

      // In a real app, you would fetch user details from server
      // For demo, create a mock friend
      final newFriend = Friend(
        id: friendId,
        nickname: 'Friend ${friendId.substring(0, 4)}',
        addedDate: DateTime.now(),
        monthlySteps: _generateMockStepsData(),
      );

      _friends.add(newFriend);
      await _saveFriends();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding friend: $e');
      return false;
    }
  }

  // Remove friend
  Future<bool> removeFriend(String friendId) async {
    try {
      _friends.removeWhere((friend) => friend.id == friendId);
      await _saveFriends();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error removing friend: $e');
      return false;
    }
  }

  // Update friend's monthly steps (simulate receiving data)
  Future<void> updateFriendSteps(String friendId, DateTime month, int steps) async {
    try {
      final friendIndex = _friends.indexWhere((friend) => friend.id == friendId);
      if (friendIndex != -1) {
        final monthKey = '${month.year}-${month.month.toString().padLeft(2, '0')}';
        final updatedSteps = Map<String, int>.from(_friends[friendIndex].monthlySteps);
        updatedSteps[monthKey] = steps;
        
        _friends[friendIndex] = _friends[friendIndex].copyWith(monthlySteps: updatedSteps);
        await _saveFriends();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating friend steps: $e');
    }
  }

  // Get friends sorted by current month steps (descending)
  List<Friend> getFriendsRankedBySteps() {
    final sortedFriends = List<Friend>.from(_friends);
    sortedFriends.sort((a, b) => b.currentMonthSteps.compareTo(a.currentMonthSteps));
    return sortedFriends;
  }

  // Get user's rank among friends (1-based)
  int getUserRank(int userSteps) {
    final allSteps = _friends.map((f) => f.currentMonthSteps).toList();
    allSteps.add(userSteps);
    allSteps.sort((a, b) => b.compareTo(a));
    return allSteps.indexOf(userSteps) + 1;
  }

  // Generate mock steps data for demo purposes
  Map<String, int> _generateMockStepsData() {
    final random = Random();
    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final lastMonth = DateTime(now.year, now.month - 1);
    final lastMonthKey = '${lastMonth.year}-${lastMonth.month.toString().padLeft(2, '0')}';
    
    return {
      currentMonth: random.nextInt(50000) + 10000, // 10K-60K steps
      lastMonthKey: random.nextInt(40000) + 15000,  // 15K-55K steps
    };
  }

  // Add mock friends for testing
  Future<void> addMockFriends() async {
    if (_friends.isNotEmpty) return; // Only add if no friends exist
    
    final mockFriends = [
      Friend(
        id: 'FRIEND01',
        nickname: 'Alice Walker',
        addedDate: DateTime.now().subtract(const Duration(days: 30)),
        monthlySteps: _generateMockStepsData(),
      ),
      Friend(
        id: 'FRIEND02',
        nickname: 'Bob Runner',
        addedDate: DateTime.now().subtract(const Duration(days: 15)),
        monthlySteps: _generateMockStepsData(),
      ),
      Friend(
        id: 'FRIEND03',
        nickname: 'Carol Hiker',
        addedDate: DateTime.now().subtract(const Duration(days: 7)),
        monthlySteps: _generateMockStepsData(),
      ),
    ];

    _friends.addAll(mockFriends);
    await _saveFriends();
    notifyListeners();
  }

  // Clear all friends (for testing)
  Future<void> clearAllFriends() async {
    _friends.clear();
    await _saveFriends();
    notifyListeners();
  }
}