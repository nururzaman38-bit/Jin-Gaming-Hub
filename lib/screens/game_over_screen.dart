import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../models/score_model.dart';
import '../providers/game_provider.dart';
import '../services/share_service.dart';
import '../utils/helpers.dart';

/// Screen 6: Game Over / Score Screen
/// - Final score & high score comparison
/// - Play Again / Share Score / Home buttons
class GameOverScreen extends StatefulWidget {
  const GameOverScreen({super.key});

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;
  ScoreModel? _scoreModel;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scoreAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get score from route arguments
    _scoreModel ??=
        ModalRoute.of(context)?.settings.arguments as ScoreModel?;

    final gameProvider = context.read<GameProvider>();
    final game = gameProvider.currentGame;
    final highScore =
        game != null ? gameProvider.getHighScore(game.id) : 0;
    final isNewHighScore = _scoreModel != null && _scoreModel!.score >= highScore;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Game Over Title ─────────────────────────
                const Text(
                  'GAME OVER',
                  style: TextStyle(
                    color: AppTheme.error,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Score Display ───────────────────────────
                AnimatedBuilder(
                  animation: _scoreAnimation,
                  builder: (context, child) {
                    final displayScore = (_scoreModel?.score ?? 0)
                        .toDouble();
                    final animatedScore =
                        (displayScore * _scoreAnimation.value).toInt();
                    return Text(
                      Helpers.formatNumber(animatedScore),
                      style: TextStyle(
                        color: isNewHighScore
                            ? AppTheme.accent
                            : AppTheme.textPrimary,
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: (isNewHighScore
                                    ? AppTheme.accent
                                    : AppTheme.primary)
                                .withOpacity(0.4),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),

                // New High Score Badge
                if (isNewHighScore)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.accent),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.emoji_events,
                            color: AppTheme.accent, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'NEW HIGH SCORE!',
                          style: TextStyle(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    'High Score: ${Helpers.formatNumber(highScore)}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),

                const SizedBox(height: 48),

                // ── Play Again ──────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      gameProvider.startGame();
                      AppRoutes.pushReplacement(context, AppRoutes.gamePlay);
                    },
                    icon: const Icon(Icons.refresh, size: 24),
                    label: const Text('Play Again', style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Share Score ─────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (_scoreModel != null && game != null) {
                        ShareService.shareScore(
                          gameTitle: game.title,
                          score: _scoreModel!.score,
                          highScore: highScore,
                        );
                      }
                    },
                    icon: const Icon(Icons.share, size: 24),
                    label: const Text(
                      'Share Score',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPrimary,
                      side: const BorderSide(color: AppTheme.textSecondary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Home ────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: TextButton.icon(
                    onPressed: () =>
                        AppRoutes.popUntil(context, AppRoutes.home),
                    icon: const Icon(Icons.home, size: 24),
                    label: const Text(
                      'Home',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
