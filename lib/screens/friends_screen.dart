import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:step_challenge_app/l10n/app_localizations.dart';
import '../models/friend_model.dart';
import '../services/friend_service.dart';
import '../services/health_service.dart';
import '../utils/app_theme.dart';
import 'friend_qr_screen.dart';
import 'qr_scanner_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  bool _showCurrentMonth = true;

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

  Widget _buildFriendsList(List<Friend> friends) {
    final l10n = AppLocalizations.of(context)!;
    final healthService = context.watch<HealthService>();
    final currentUserSteps = _showCurrentMonth 
        ? healthService.monthlySteps 
        : healthService.lastMonthSteps;
    
    // Create a combined list with user and friends for ranking
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
      final month = _showCurrentMonth 
          ? DateTime.now()
          : DateTime(DateTime.now().year, DateTime.now().month - 1);
      allParticipants.add({
        'id': friend.id,
        'nickname': friend.nickname,
        'steps': friend.getStepsForMonth(month),
        'avatarPath': friend.avatarPath,
        'isCurrentUser': false,
        'friend': friend,
      });
    }
    
    // Sort by steps (descending)
    allParticipants.sort((a, b) => (b['steps'] as int).compareTo(a['steps'] as int));
    
    return Column(
      children: [
        // Header with month toggle
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.friendsRanking,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: true,
                    label: Text(l10n.thisMonth),
                    icon: const Icon(Icons.calendar_today),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text(l10n.lastMonth),
                    icon: const Icon(Icons.calendar_month),
                  ),
                ],
                selected: {_showCurrentMonth},
                onSelectionChanged: (Set<bool> selection) {
                  setState(() {
                    _showCurrentMonth = selection.first;
                  });
                },
              ),
            ],
          ),
        ),
        
        // Friends ranking list
        Expanded(
          child: ListView.builder(
            itemCount: allParticipants.length,
            itemBuilder: (context, index) {
              final participant = allParticipants[index];
              final rank = index + 1;
              final isCurrentUser = participant['isCurrentUser'] as bool;
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                color: isCurrentUser ? AppTheme.primaryColor.withOpacity(0.1) : null,
                child: ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Rank badge
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Avatar
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: isCurrentUser 
                            ? AppTheme.primaryColor 
                            : Colors.grey[300],
                        child: isCurrentUser
                            ? const Icon(Icons.person, color: Colors.white)
                            : Icon(Icons.person, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          participant['nickname'] as String,
                          style: TextStyle(
                            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isCurrentUser)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l10n.you,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    l10n.stepsThisMonth(participant['steps'].toString()),
                  ),
                  trailing: !isCurrentUser
                      ? PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'remove') {
                              final friend = participant['friend'] as Friend;
                              final friendService = context.read<FriendService>();
                              final success = await friendService.removeFriend(friend.id);
                              if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.friendRemoved)),
                                );
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'remove',
                              child: Row(
                                children: [
                                  const Icon(Icons.person_remove, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Text(l10n.removeFriend),
                                ],
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber[600]!; // Gold
      case 2:
        return Colors.grey[400]!;  // Silver
      case 3:
        return Colors.brown[400]!; // Bronze
      default:
        return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.friends),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
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
            icon: const Icon(Icons.qr_code),
            tooltip: l10n.myQrCode,
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QrScannerScreen(),
                ),
              );
            },
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: l10n.scanQrCode,
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
          
          return _buildFriendsList(friendService.friends);
        },
      ),
    );
  }
}