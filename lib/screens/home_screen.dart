import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../widgets/top_bar.dart';
import '../widgets/banner_slider.dart';
import '../widgets/category_chips.dart';
import '../widgets/game_card.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/profile_screen.dart';

/// Screen 3: Home Screen (Main Dashboard)
/// - Top bar with profile, coins, notifications
/// - Featured games banner slider
/// - Category filter chips
/// - Game grid with Play buttons
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load games on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().fetchGames();
    });
  }

  // ── Pages ───────────────────────────────────────────────
  final List<Widget> _pages = const [
    _HomeContent(),
    LeaderboardScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            activeIcon: Icon(Icons.emoji_events),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// The actual home dashboard content
class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final gameProvider = context.watch<GameProvider>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => gameProvider.fetchGames(),
          color: AppTheme.primary,
          child: CustomScrollView(
            slivers: [
              // ── Top Bar ─────────────────────────────────
              SliverToBoxAdapter(
                child: TopBar(
                  avatarUrl: auth.user?.photoUrl,
                  username: auth.user?.displayName ?? 'Player',
                  coinBalance: auth.user?.totalCoins ?? 0,
                  notificationCount: 0,
                  onProfileTap: () =>
                      AppRoutes.push(context, AppRoutes.profile),
                  onNotificationTap: () =>
                      AppRoutes.push(context, AppRoutes.notifications),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ── Banner Slider ───────────────────────────
              SliverToBoxAdapter(
                child: BannerSlider(
                  featuredGames: gameProvider.featuredGames,
                  onGameTap: (game) {
                    gameProvider.selectGame(game);
                    AppRoutes.push(context, AppRoutes.gameDetails);
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── Category Chips ──────────────────────────
              SliverToBoxAdapter(
                child: CategoryChips(
                  selectedCategory: gameProvider.selectedCategory,
                  onCategorySelected: gameProvider.setCategory,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ── Game Grid ───────────────────────────────
              if (gameProvider.isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  ),
                )
              else if (gameProvider.games.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sports_esports,
                            size: 64, color: AppTheme.textSecondary),
                        const SizedBox(height: 16),
                        Text(
                          gameProvider.error ?? 'No games found',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => gameProvider.fetchGames(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final game = gameProvider.games[index];
                        return GameCard(
                          game: game,
                          onPlay: () {
                            gameProvider.selectGame(game);
                            AppRoutes.push(context, AppRoutes.gameDetails);
                          },
                        );
                      },
                      childCount: gameProvider.games.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}
