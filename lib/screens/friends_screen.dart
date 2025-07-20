import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/friend_model.dart';
import '../services/friend_service.dart';
import '../services/health_service.dart';
import '../utils/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'friend_qr_screen.dart';
import 'qr_scanner_screen.dart';

import 'package:intl/intl.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  int _currentMonthOffset = 0; // 0 = current month, -1 = last month, etc.

  @override
  void initState() {
    super.initState();
    // Add some mock friends for demo if none exist
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final friendService = context.read<FriendService>();
      if (friendService.friends.isEmpty) {
        friendService.addMockFriends();
      }
    });
  }

  DateTime get _selectedMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month + _currentMonthOffset);
  }

  String _getMonthYearString(DateTime date, AppLocalizations l10n) {
    final locale = l10n.localeName;
    return DateFormat.yMMMM(locale).format(date);
  }

  // Convert steps to kilometers (assuming 1 km ≈ 1,250 steps)
  double _stepsToKm(int steps) {
    return steps / 1250.0;
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noFriendsYet,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.addFriendsPrompt,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FriendQrScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.qr_code),
                    label: Text(l10n.myQrCode),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QrScannerScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: Text(l10n.scanQrCode),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: BorderSide(color: AppTheme.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardHeader(List<Friend> friends) {
    final l10n = AppLocalizations.of(context)!;
    final healthService = context.watch<HealthService>();
    
    // Get current user steps for selected month
    final currentUserSteps = _currentMonthOffset == 0 
        ? healthService.monthlySteps 
        : healthService.lastMonthSteps;
    
    // Create combined list for ranking
    final allParticipants = <Map<String, dynamic>>[];
    
    // Add current user
    allParticipants.add({
      'id': 'current_user',
      'nickname': l10n.you,
      'steps': currentUserSteps,
      'isCurrentUser': true,
    });
    
    // Add friends
    for (final friend in friends) {
      allParticipants.add({
        'id': friend.id,
        'nickname': friend.nickname,
        'steps': friend.getStepsForMonth(_selectedMonth),
        'avatarPath': friend.avatarPath,
        'isCurrentUser': false,
        'friend': friend,
      });
    }
    
    // Sort by steps (descending)
    allParticipants.sort((a, b) => (b['steps'] as int).compareTo(a['steps'] as int));
    
    // Find current user's position
    final userRank = allParticipants.indexWhere((p) => p['isCurrentUser'] == true) + 1;
    final userSteps = allParticipants.firstWhere((p) => p['isCurrentUser'] == true)['steps'] as int;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // User stats
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.primaryColor,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.yourMonthlyPerformance,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.userRank(userRank),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${_stepsToKm(userSteps).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        l10n.km,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Steps info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.steps,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      l10n.userSteps(userSteps),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildFriendsRanking(List<Friend> friends) {
    final l10n = AppLocalizations.of(context)!;
    final healthService = context.watch<HealthService>();
    
    final currentUserSteps = _currentMonthOffset == 0 
        ? healthService.monthlySteps 
        : healthService.lastMonthSteps;
    
    // Create combined list for ranking
    final allParticipants = <Map<String, dynamic>>[];
    
    // Add current user
    allParticipants.add({
      'id': 'current_user',
      'nickname': l10n.you,
      'steps': currentUserSteps,
      'isCurrentUser': true,
    });
    
    // Add friends
    for (final friend in friends) {
      allParticipants.add({
        'id': friend.id,
        'nickname': friend.nickname,
        'steps': friend.getStepsForMonth(_selectedMonth),
        'avatarPath': friend.avatarPath,
        'isCurrentUser': false,
        'friend': friend,
      });
    }
    
    // Sort by steps (descending)
    allParticipants.sort((a, b) => (b['steps'] as int).compareTo(a['steps'] as int));
    
    // Filter out participants with 0 steps for the "no kilometers" message
    final participantsWithSteps = allParticipants.where((p) => (p['steps'] as int) > 0).toList();
    final participantsWithoutSteps = allParticipants.where((p) => (p['steps'] as int) == 0).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.friendsMonthlyRanking,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        // Ranking list
        ...participantsWithSteps.asMap().entries.map((entry) {
          final index = entry.key;
          final participant = entry.value;
          final rank = index + 1;
          final isCurrentUser = participant['isCurrentUser'] as bool;
          final steps = participant['steps'] as int;
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Card(
              elevation: isCurrentUser ? 2 : 0,
              color: isCurrentUser ? Colors.white : Colors.grey[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isCurrentUser 
                    ? BorderSide(color: AppTheme.primaryColor, width: 2)
                    : BorderSide.none,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Rank with medal or number
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _getRankColor(rank),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$rank',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: rank <= 3 ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Avatar
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: isCurrentUser ? AppTheme.primaryColor : Colors.grey[300],
                      child: Icon(
                        isCurrentUser ? Icons.person : Icons.person_outline,
                        color: isCurrentUser ? Colors.white : Colors.grey[600],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            participant['nickname'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isCurrentUser ? FontWeight.w600 : FontWeight.w500,
                              color: isCurrentUser ? AppTheme.primaryColor : Colors.black87,
                            ),
                          ),
                          if (isCurrentUser)
                            Text(
                              l10n.youParentheses,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Steps and distance
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l10n.kmValue(_stepsToKm(steps)),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isCurrentUser ? AppTheme.primaryColor : Colors.black87,
                          ),
                        ),
                        Text(
                          l10n.userSteps(steps),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
        
        // No kilometers message
        if (participantsWithoutSteps.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.friendsWithoutSteps(participantsWithoutSteps.length),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber; // 金色
      case 2:
        return Colors.grey[400]!; // 銀色
      case 3:
        return Colors.orange[700]!; // 銅色
      default:
        return Colors.grey[200]!; // 其他
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.friends,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FriendQrScreen(),
                ),
              );
            },
            icon: const Icon(Icons.person_add, color: Colors.black),
          ),
        ],
      ),
      body: Consumer<FriendService>(
        builder: (context, friendService, child) {
          if (friendService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (friendService.friends.isEmpty) {
            return _buildEmptyState();
          }
          
          return Column(
            children: [
              const SizedBox(height: 16),
              
              // Month navigation
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _currentMonthOffset--;
                        });
                      },
                      icon: const Icon(Icons.chevron_left, size: 32),
                    ),
                    Text(
                      _getMonthYearString(_selectedMonth, l10n),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: _currentMonthOffset < 0 ? () {
                        setState(() {
                          _currentMonthOffset++;
                        });
                      } : null,
                      icon: Icon(
                        Icons.chevron_right, 
                        size: 32,
                        color: _currentMonthOffset < 0 ? Colors.black : Colors.grey[300],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildLeaderboardHeader(friendService.friends),
                      _buildFriendsRanking(friendService.friends),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

