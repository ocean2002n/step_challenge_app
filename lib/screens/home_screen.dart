import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:step_challenge_app/l10n/app_localizations.dart';
import '../services/health_service.dart';
import '../services/sheets_service.dart';
import '../widgets/step_counter_card.dart';
import '../widgets/weekly_chart_card.dart';
import '../widgets/goal_progress_card.dart';
import '../widgets/challenge_list_card.dart';
import 'profile_screen.dart';
import 'language_settings_screen.dart';
import 'friends_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      final healthService = context.read<HealthService>();
      final sheetsService = context.read<SheetsService>();

      // Initialize services in parallel
      await Future.wait([
        healthService.initialize(),
        sheetsService.initialize(),
      ]);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Initialization error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(l10n.initializingApp),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          _buildChallengesTab(),
          const FriendsScreen(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.emoji_events),
            label: l10n.challenges,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: l10n.friends,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: _createNewChallenge,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreetingHeader(),
              const SizedBox(height: 24),
              const StepCounterCard(),
              const SizedBox(height: 16),
              const GoalProgressCard(),
              const SizedBox(height: 16),
              const WeeklyChartCard(),
              const SizedBox(height: 16),
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingHeader() {
    final l10n = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;
    String greeting;
    
    if (hour < 12) {
      greeting = l10n.goodMorning;
    } else if (hour < 18) {
      greeting = l10n.goodAfternoon;
    } else {
      greeting = l10n.goodEvening;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 4),
        Text(
          l10n.stayActive,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.sync,
                title: l10n.syncData,
                onTap: _syncHealthData,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.settings,
                title: l10n.setGoal,
                onTap: _setDailyGoal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengesTab() {
    final l10n = AppLocalizations.of(context)!;
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.challengeActivities,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            const ChallengeListCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    final l10n = AppLocalizations.of(context)!;
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.personalSettings,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(l10n.personalProfile),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(l10n.language),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LanguageSettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: Text(l10n.notificationSettings),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to notification settings page
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.health_and_safety),
                    title: Text(l10n.healthDataPermission),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _checkHealthPermissions,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    final healthService = context.read<HealthService>();
    await healthService.syncHealthData();
  }

  Future<void> _syncHealthData() async {
    final l10n = AppLocalizations.of(context)!;
    final healthService = context.read<HealthService>();
    await healthService.syncHealthData();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.dataSyncComplete)),
      );
    }
  }

  void _setDailyGoal() {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.setDailyStepGoal),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l10n.goalSteps,
            suffixText: l10n.steps,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Save goal logic
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _createNewChallenge() {
    final l10n = AppLocalizations.of(context)!;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.createChallengeInDevelopment)),
    );
  }

  void _checkHealthPermissions() async {
    final l10n = AppLocalizations.of(context)!;
    final healthService = context.read<HealthService>();
    final isAuthorized = await healthService.initialize();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAuthorized ? l10n.healthDataAuthorized : l10n.pleaseEnableHealthData,
          ),
        ),
      );
    }
  }
}