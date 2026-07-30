import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../widgets/pause_modal.dart';
import '../games/game_engine.dart';

/// Screen 5: Game Play Screen
/// - Native game canvas / view
/// - Pause button at top corner
/// - Current score counter
/// - Pause modal with Resume / Restart / Exit
/// - Game Over → saves score and shows Game Over screen
class GamePlayScreen extends StatefulWidget {
  const GamePlayScreen({super.key});

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  late GameEngine _gameEngine;

  @override
  void initState() {
    super.initState();
    _gameEngine = DemoGameEngine();
    _gameEngine.onScoreUpdate = _onScoreUpdate;
    _gameEngine.onGameOver = _onGameOver;
  }

  @override
  void dispose() {
    _gameEngine.dispose();
    super.dispose();
  }

  // ── Score Update Callback ───────────────────────────────
  void _onScoreUpdate(int score) {
    final gameProvider = context.read<GameProvider>();
    gameProvider.updateScore(score);
  }

  // ── Game Over Callback ──────────────────────────────────
  Future<void> _onGameOver() async {
    final gameProvider = context.read<GameProvider>();
    final authProvider = context.read<AuthProvider>();

    if (authProvider.user != null) {
      final scoreModel = await gameProvider.endGame(
        userId: authProvider.user!.uid,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.gameOver,
        arguments: scoreModel,
      );
    }
  }

  // ── Pause ───────────────────────────────────────────────
  void _showPauseModal() {
    _gameEngine.pause();
    context.read<GameProvider>().pauseGame();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PauseModal(
        onResume: () {
          Navigator.pop(ctx);
          _gameEngine.resume();
          context.read<GameProvider>().resumeGame();
        },
        onRestart: () {
          Navigator.pop(ctx);
          _gameEngine.restart();
          context.read<GameProvider>().startGame();
        },
        onExit: () {
          Navigator.pop(ctx);
          _gameEngine.dispose();
          AppRoutes.popUntil(context, AppRoutes.home);
        },
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final game = gameProvider.currentGame;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Game Canvas ────────────────────────────────
            Positioned.fill(
              child: _gameEngine.buildWidget(
                game: game,
              ),
            ),

            // ── HUD Overlay ───────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // Pause Button
                    GestureDetector(
                      onTap: _showPauseModal,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.surface.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.pause,
                          color: AppTheme.textPrimary,
                          size: 24,
                        ),
                      ),
                    ),
                    const Spacer(),

                    // Game Title
                    if (game != null)
                      Text(
                        game.title,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const Spacer(),

                    // Score Counter
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.surface.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star,
                              color: AppTheme.accent, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            gameProvider.currentScore.toString(),
                            style: const TextStyle(
                              color: AppTheme.accent,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
