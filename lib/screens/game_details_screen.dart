import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/game_provider.dart';
import '../models/game_model.dart';
import '../utils/helpers.dart';

/// Screen 4: Game Details / Loading Screen
/// - Full-screen preview of the selected game
/// - High score display
/// - Global leaderboard preview
/// - Play Now button
class GameDetailsScreen extends StatefulWidget {
  const GameDetailsScreen({super.key});

  @override
  State<GameDetailsScreen> createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends State<GameDetailsScreen> {
  bool _isAssetsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    // Simulate asset loading (in production, download game assets here)
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isAssetsLoaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final game = gameProvider.currentGame;

    if (game == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(title: const Text('Game')),
        body: const Center(
          child: Text('No game selected.',
              style: TextStyle(color: AppTheme.textSecondary)),
        ),
      );
    }

    final highScore = gameProvider.getHighScore(game.id);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ── Game Preview Header ──────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
              onPressed: () => AppRoutes.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  game.bannerUrl != null
                      ? Image.network(
                          game.bannerUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(game),
                        )
                      : _buildPlaceholder(game),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [AppTheme.background, Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Game Title
                  Text(
                    game.title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Category & Rating
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(GameModel.categoryIcon(game.category),
                                color: AppTheme.primary, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              game.category,
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (game.rating > 0)
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: AppTheme.accent, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              game.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      const Spacer(),
                      Text(
                        '${Helpers.formatNumber(game.playsCount)} plays',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text(
                    game.description,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // High Score Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppTheme.cardGradient,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.accent.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.emoji_events,
                            color: AppTheme.accent, size: 36),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your High Score',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Helpers.formatNumber(highScore),
                              style: const TextStyle(
                                color: AppTheme.accent,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Play Now Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isAssetsLoaded
                          ? () {
                              gameProvider.startGame();
                              AppRoutes.pushReplacement(
                                context,
                                AppRoutes.gamePlay,
                              );
                            }
                          : null,
                      icon: _isAssetsLoaded
                          ? const Icon(Icons.play_arrow, size: 28)
                          : const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: AppTheme.textPrimary,
                                strokeWidth: 2,
                              ),
                            ),
                      label: Text(
                        _isAssetsLoaded ? 'Play Now' : 'Loading Assets...',
                        style: const TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(GameModel game) {
    return Container(
      color: AppTheme.surface,
      child: Center(
        child: Icon(
          GameModel.categoryIcon(game.category),
          size: 64,
          color: AppTheme.primary,
        ),
      ),
    );
  }
}
