import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/leaderboard_provider.dart';
import '../widgets/leaderboard_tile.dart';

/// Screen 7: Leaderboard Screen
/// - Global and Daily rankings
/// - Switch between Global and Friends tabs
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LeaderboardProvider>();
      provider.fetchGlobalLeaderboard();
      provider.fetchDailyLeaderboard();
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final provider = context.read<LeaderboardProvider>();
    provider.setTab(
      _tabController.index == 0
          ? LeaderboardTab.global
          : LeaderboardTab.daily,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeaderboardProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accent,
          labelColor: AppTheme.textPrimary,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'Global', icon: Icon(Icons.public)),
            Tab(text: 'Daily', icon: Icon(Icons.today)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaderboardList(
            provider.globalLeaderboard,
            provider.isLoading,
            provider.error,
          ),
          _buildLeaderboardList(
            provider.dailyLeaderboard,
            provider.isLoading,
            provider.error,
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList(
    List<dynamic> scores,
    bool isLoading,
    String? error,
  ) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: AppTheme.error),
            const SizedBox(height: 16),
            Text(error,
                style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<LeaderboardProvider>().fetchGlobalLeaderboard();
                context.read<LeaderboardProvider>().fetchDailyLeaderboard();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (scores.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events_outlined,
                size: 64, color: AppTheme.textSecondary),
            SizedBox(height: 16),
            Text(
              'No scores yet. Be the first!',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: scores.length,
      separatorBuilder: (_, __) => const Divider(
        color: AppTheme.surface,
        height: 1,
      ),
      itemBuilder: (context, index) {
        final score = scores[index];
        return LeaderboardTile(
          rank: index + 1,
          score: score,
          username: score.userId.substring(0, 8), // Simplified
        );
      },
    );
  }
}
