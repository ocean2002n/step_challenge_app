import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/challenge_model.dart';
import '../utils/app_theme.dart';

class ChallengeListCard extends StatefulWidget {
  const ChallengeListCard({super.key});

  @override
  State<ChallengeListCard> createState() => _ChallengeListCardState();
}

class _ChallengeListCardState extends State<ChallengeListCard> {
  List<Challenge> _challenges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    // 模擬載入挑戰資料
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _challenges = [
        Challenge(
          id: '1',
          title: '週末健走挑戰',
          description: '這個週末讓我們一起走路，目標是每天8000步！',
          creatorId: 'user1',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 2)),
          goalType: ChallengeGoalType.daily,
          goalValue: 8000,
          status: ChallengeStatus.active,
          createdDate: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        Challenge(
          id: '2',
          title: '萬步達人月挑戰',
          description: '一整個月每天都要達到10000步，你敢挑戰嗎？',
          creatorId: 'user2',
          startDate: DateTime.now().subtract(const Duration(days: 5)),
          endDate: DateTime.now().add(const Duration(days: 25)),
          goalType: ChallengeGoalType.daily,
          goalValue: 10000,
          status: ChallengeStatus.active,
          createdDate: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Challenge(
          id: '3',
          title: '100萬步總挑戰',
          description: '團隊合作達成100萬步總目標！',
          creatorId: 'user3',
          startDate: DateTime.now().subtract(const Duration(days: 10)),
          endDate: DateTime.now().add(const Duration(days: 20)),
          goalType: ChallengeGoalType.total,
          goalValue: 1000000,
          status: ChallengeStatus.active,
          createdDate: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_challenges.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                '目前沒有進行中的挑戰',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '創建一個新挑戰邀請朋友一起運動吧！',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _challenges.asMap().entries.map((entry) {
        final index = entry.key;
        final challenge = entry.value;
        return Padding(
          padding: EdgeInsets.only(bottom: index < _challenges.length - 1 ? 12 : 0),
          child: _buildChallengeCard(challenge, index),
        );
      }).toList(),
    );
  }

  Widget _buildChallengeCard(Challenge challenge, int index) {
    final daysRemaining = challenge.endDate.difference(DateTime.now()).inDays;
    final isExpiringSoon = daysRemaining <= 3 && daysRemaining > 0;
    final isExpired = daysRemaining < 0;
    
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: () => _onChallengeSelected(challenge),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 標題和狀態
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.title,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          challenge.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(challenge, isExpiringSoon, isExpired),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 挑戰詳情
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      icon: _getChallengeIcon(challenge.goalType),
                      label: _getChallengeTypeLabel(challenge.goalType),
                      value: _formatGoalValue(challenge.goalValue, challenge.goalType),
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.timer_outlined,
                      label: '剩餘時間',
                      value: isExpired ? '已結束' : '$daysRemaining 天',
                      color: isExpiringSoon ? AppTheme.accentOrange : AppTheme.secondaryBlue,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 進度條 (模擬數據)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '挑戰進度',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${_getProgress(challenge.id)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _getProgress(challenge.id) / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProgress(challenge.id) >= 100 
                            ? AppTheme.accentOrange 
                            : AppTheme.primaryGreen,
                      ),
                      minHeight: 6,
                    ),
                  ).animate().scaleX(duration: 800.ms, delay: Duration(milliseconds: index * 100)),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 參與者和操作按鈕
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_getParticipantCount(challenge.id)} 位參與者',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (!isExpired)
                        TextButton.icon(
                          onPressed: () => _joinChallenge(challenge),
                          icon: const Icon(Icons.person_add, size: 16),
                          label: const Text('加入'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primaryGreen,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          ),
                        ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _shareChallenge(challenge),
                        icon: const Icon(Icons.share, size: 20),
                        color: Colors.grey[600],
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 150)).slideY(begin: 0.2);
  }

  Widget _buildStatusChip(Challenge challenge, bool isExpiringSoon, bool isExpired) {
    Color chipColor;
    String chipText;
    IconData chipIcon;

    if (isExpired) {
      chipColor = Colors.grey;
      chipText = '已結束';
      chipIcon = Icons.timer_off;
    } else if (isExpiringSoon) {
      chipColor = AppTheme.accentOrange;
      chipText = '即將結束';
      chipIcon = Icons.timer;
    } else {
      chipColor = AppTheme.primaryGreen;
      chipText = '進行中';
      chipIcon = Icons.play_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(chipIcon, size: 12, color: chipColor),
          const SizedBox(width: 4),
          Text(
            chipText,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getChallengeIcon(ChallengeGoalType type) {
    switch (type) {
      case ChallengeGoalType.daily:
        return Icons.today;
      case ChallengeGoalType.total:
        return Icons.timeline;
      case ChallengeGoalType.duration:
        return Icons.timer;
    }
  }

  String _getChallengeTypeLabel(ChallengeGoalType type) {
    switch (type) {
      case ChallengeGoalType.daily:
        return '每日目標';
      case ChallengeGoalType.total:
        return '總計目標';
      case ChallengeGoalType.duration:
        return '持續時間';
    }
  }

  String _formatGoalValue(int value, ChallengeGoalType type) {
    switch (type) {
      case ChallengeGoalType.daily:
      case ChallengeGoalType.total:
        return '${value.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]},',
        )} 步';
      case ChallengeGoalType.duration:
        return '$value 天';
    }
  }

  int _getProgress(String challengeId) {
    // 模擬進度數據
    switch (challengeId) {
      case '1':
        return 65;
      case '2':
        return 42;
      case '3':
        return 78;
      default:
        return 0;
    }
  }

  int _getParticipantCount(String challengeId) {
    // 模擬參與者數據
    switch (challengeId) {
      case '1':
        return 8;
      case '2':
        return 23;
      case '3':
        return 15;
      default:
        return 0;
    }
  }

  void _onChallengeSelected(Challenge challenge) {
    // 導航到挑戰詳情頁面
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('點選了挑戰: ${challenge.title}')),
    );
  }

  void _joinChallenge(Challenge challenge) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已加入挑戰: ${challenge.title}')),
    );
  }

  void _shareChallenge(Challenge challenge) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('分享挑戰: ${challenge.title}')),
    );
  }
}