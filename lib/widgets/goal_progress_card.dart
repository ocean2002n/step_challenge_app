import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/health_service.dart';
import '../utils/app_theme.dart';

class GoalProgressCard extends StatelessWidget {
  const GoalProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthService>(
      builder: (context, healthService, child) {
        final todaySteps = healthService.todaySteps;
        final dailyGoal = 10000; // 預設目標
        final progress = (todaySteps / dailyGoal).clamp(0.0, 1.0);
        final remainingSteps = (dailyGoal - todaySteps).clamp(0, dailyGoal);
        final isGoalAchieved = todaySteps >= dailyGoal;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '目標進度',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isGoalAchieved 
                            ? AppTheme.primaryGreen.withOpacity(0.1)
                            : AppTheme.lightGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isGoalAchieved ? Icons.check_circle : Icons.flag,
                            size: 16,
                            color: isGoalAchieved 
                                ? AppTheme.primaryGreen 
                                : AppTheme.darkGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isGoalAchieved ? '已達成' : '進行中',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isGoalAchieved 
                                  ? AppTheme.primaryGreen 
                                  : AppTheme.darkGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // 圓形進度指示器
                Center(
                  child: SizedBox(
                    width: 160,
                    height: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 背景圓環
                        SizedBox(
                          width: 160,
                          height: 160,
                          child: CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.grey[200]!,
                            ),
                          ),
                        ),
                        // 進度圓環
                        SizedBox(
                          width: 160,
                          height: 160,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 12,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isGoalAchieved 
                                  ? AppTheme.accentOrange 
                                  : AppTheme.primaryGreen,
                            ),
                          ).animate().rotate(duration: 1000.ms),
                        ),
                        // 中央內容
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(progress * 100).round()}%',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: isGoalAchieved 
                                    ? AppTheme.accentOrange 
                                    : AppTheme.darkGreen,
                              ),
                            ).animate().fadeIn(duration: 800.ms).scale(),
                            const SizedBox(height: 4),
                            Text(
                              isGoalAchieved ? '目標達成！' : '繼續加油',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 詳細資訊
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        context,
                        '今日步數',
                        todaySteps.toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match match) => '${match[1]},',
                        ),
                        Icons.directions_walk,
                        AppTheme.secondaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        context,
                        isGoalAchieved ? '超出目標' : '剩餘步數',
                        isGoalAchieved 
                            ? (todaySteps - dailyGoal).toString().replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match match) => '${match[1]},',
                              )
                            : remainingSteps.toString().replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match match) => '${match[1]},',
                              ),
                        isGoalAchieved ? Icons.trending_up : Icons.flag_outlined,
                        isGoalAchieved ? AppTheme.accentOrange : AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 鼓勵訊息
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isGoalAchieved ? Icons.celebration : Icons.lightbulb_outline,
                        color: AppTheme.darkGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getMotivationalMessage(progress, isGoalAchieved),
                          style: TextStyle(
                            color: AppTheme.darkGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getMotivationalMessage(double progress, bool isGoalAchieved) {
    if (isGoalAchieved) {
      return '太棒了！您已經達成今日目標，繼續保持健康的生活習慣！';
    } else if (progress >= 0.8) {
      return '快要達成目標了！再走一點就成功了，加油！';
    } else if (progress >= 0.5) {
      return '已經完成一半了！繼續努力，目標就在眼前！';
    } else if (progress >= 0.2) {
      return '好的開始！每一步都讓您更接近健康目標。';
    } else {
      return '新的一天開始了！走出第一步，向目標邁進！';
    }
  }
}