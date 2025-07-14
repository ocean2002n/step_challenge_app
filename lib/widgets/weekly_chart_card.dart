import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/health_service.dart';
import '../utils/app_theme.dart';

class WeeklyChartCard extends StatelessWidget {
  const WeeklyChartCard({super.key});

  @override
  Widget build(BuildContext context) {
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
                  '本週走路紀錄',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Icon(
                  Icons.show_chart,
                  color: AppTheme.primaryGreen,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Consumer<HealthService>(
              builder: (context, healthService, child) {
                final weeklySteps = healthService.weeklySteps;
                
                if (weeklySteps.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text('暫無數據'),
                    ),
                  );
                }

                return Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: _getMaxY(weeklySteps.map((e) => e.steps.toDouble()).toList()),
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              tooltipBgColor: AppTheme.darkGreen,
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                return BarTooltipItem(
                                  '${rod.toY.round()} 步',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() < weeklySteps.length) {
                                    final date = weeklySteps[value.toInt()].date;
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        DateFormat('E', 'zh_TW').format(date),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  if (value == 0) return const Text('0');
                                  if (value >= 1000) {
                                    return Text(
                                      '${(value / 1000).toStringAsFixed(0)}k',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    );
                                  }
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: weeklySteps.asMap().entries.map((entry) {
                            final index = entry.key;
                            final daySteps = entry.value;
                            final isToday = _isToday(daySteps.date);
                            final isGoalAchieved = daySteps.goalAchieved;
                            
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: daySteps.steps.toDouble(),
                                  color: isToday
                                      ? AppTheme.accentOrange
                                      : isGoalAchieved
                                          ? AppTheme.primaryGreen
                                          : AppTheme.primaryGreen.withOpacity(0.5),
                                  width: 20,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    topRight: Radius.circular(4),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: _getMaxY(
                              weeklySteps.map((e) => e.steps.toDouble()).toList(),
                            ) / 4,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.withOpacity(0.2),
                                strokeWidth: 1,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildWeeklyStats(context, healthService),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyStats(BuildContext context, HealthService healthService) {
    final totalSteps = healthService.getWeeklyTotalSteps();
    final averageSteps = healthService.getWeeklyAverageSteps();
    final goalsAchieved = healthService.getWeeklyGoalsAchieved(10000);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          context,
          '本週總計',
          '${totalSteps.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match match) => '${match[1]},',
          )} 步',
          Icons.trending_up,
          AppTheme.primaryGreen,
        ),
        _buildStatItem(
          context,
          '日均步數',
          '${averageSteps.round().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match match) => '${match[1]},',
          )} 步',
          Icons.timeline,
          AppTheme.secondaryBlue,
        ),
        _buildStatItem(
          context,
          '達標天數',
          '$goalsAchieved/7 天',
          Icons.emoji_events,
          AppTheme.accentOrange,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  double _getMaxY(List<double> values) {
    if (values.isEmpty) return 10000;
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final roundedMax = ((maxValue / 1000).ceil() * 1000).toDouble();
    return roundedMax < 5000 ? 10000 : roundedMax;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}