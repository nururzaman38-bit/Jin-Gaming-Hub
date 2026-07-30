import 'dart:async';
import 'package:flutter/material.dart';
import '../models/game_model.dart';

/// Abstract game engine interface.
/// Each game module implements this interface to plug into the hub.
abstract class GameEngine {
  /// Called when the score updates during gameplay.
  void Function(int score)? onScoreUpdate;

  /// Called when the game ends.
  VoidCallback? onGameOver;

  /// Build the game widget.
  Widget buildWidget({GameModel? game});

  /// Pause the game.
  void pause();

  /// Resume the game.
  void resume();

  /// Restart the game.
  void restart();

  /// Dispose resources.
  void dispose();
}

/// A default demo game engine that renders a tap-to-score game.
/// Replace this with Flame-based game implementations for real games.
class DemoGameEngine implements GameEngine {
  @override
  void Function(int score)? onScoreUpdate;

  @override
  VoidCallback? onGameOver;

  int _score = 0;
  int _targetScore = 50;
  bool _isPaused = false;
  bool _isDisposed = false;

  @override
  Widget buildWidget({GameModel? game}) {
    return _DemoGameWidget(
      onScore: (score) {
        _score = score;
        onScoreUpdate?.call(score);
        if (score >= _targetScore) {
          onGameOver?.call();
        }
      },
      isPaused: _isPaused,
      targetScore: _targetScore,
    );
  }

  @override
  void pause() => _isPaused = true;

  @override
  void resume() => _isPaused = false;

  @override
  void restart() {
    _score = 0;
    _isPaused = false;
    onScoreUpdate?.call(0);
  }

  @override
  void dispose() {
    _isDisposed = true;
  }
}

/// Simple tap-to-score demo game widget.
class _DemoGameWidget extends StatefulWidget {
  final ValueChanged<int> onScore;
  final bool isPaused;
  final int targetScore;

  const _DemoGameWidget({
    required this.onScore,
    required this.isPaused,
    required this.targetScore,
  });

  @override
  State<_DemoGameWidget> createState() => _DemoGameWidgetState();
}

class _DemoGameWidgetState extends State<_DemoGameWidget>
    with TickerProviderStateMixin {
  int _score = 0;
  late AnimationController _pulseController;
  final List<_FloatingPoint> _floatingPoints = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.95,
      upperBound: 1.05,
    );
    _pulseController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (widget.isPaused) return;
    setState(() {
      _score++;
      _pulseController.forward(from: 0.95);
      _floatingPoints.add(
        _FloatingPoint(
          x: 50.0 + (DateTime.now().millisecond % 100) * 2.0,
          y: 300.0,
          value: 1,
          createdAt: DateTime.now(),
        ),
      );
    });
    widget.onScore(_score);

    // Remove old floating points
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _floatingPoints.removeWhere(
            (p) => DateTime.now().difference(p.createdAt).inSeconds > 1,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = _score / widget.targetScore;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D0D1A), Color(0xFF1A1A2E)],
        ),
      ),
      child: GestureDetector(
        onTap: _onTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Center tap target
            Center(
              child: ScaleTransition(
                scale: _pulseController,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF6C5CE7),
                        const Color(0xFF6C5CE7).withOpacity(0.6),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C5CE7).withOpacity(0.4),
                        blurRadius: 40,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.touch_app,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Progress bar
            Positioned(
              left: 32,
              right: 32,
              bottom: 100,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 12,
                      backgroundColor: const Color(0xFF1A1A2E),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFFFA502),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_score / ${widget.targetScore}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Floating points
            ..._floatingPoints.map((p) => _buildFloatingPoint(p)),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingPoint(_FloatingPoint p) {
    return Positioned(
      left: p.x,
      top: p.y - (DateTime.now().difference(p.createdAt).inMilliseconds / 10),
      child: const Text(
        '+1',
        style: TextStyle(
          color: Color(0xFFFFA502),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _FloatingPoint {
  final double x;
  final double y;
  final int value;
  final DateTime createdAt;

  _FloatingPoint({
    required this.x,
    required this.y,
    required this.value,
    required this.createdAt,
  });
}
