import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Pause modal shown during gameplay.
class PauseModal extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const PauseModal({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pause_circle, size: 64, color: AppTheme.primary),
            const SizedBox(height: 16),
            const Text(
              'Game Paused',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            _buildButton(
              icon: Icons.play_arrow,
              label: 'Resume',
              color: AppTheme.success,
              onTap: onResume,
            ),
            const SizedBox(height: 12),
            _buildButton(
              icon: Icons.refresh,
              label: 'Restart',
              color: AppTheme.accent,
              onTap: onRestart,
            ),
            const SizedBox(height: 12),
            _buildButton(
              icon: Icons.home,
              label: 'Exit to Home',
              color: AppTheme.error,
              onTap: onExit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: AppTheme.textPrimary),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
