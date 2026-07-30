import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/score_model.dart';
import '../utils/helpers.dart';

/// A single leaderboard list tile.
class LeaderboardTile extends StatelessWidget {
  final int rank;
  final ScoreModel score;
  final String? userAvatarUrl;
  final String? username;

  const LeaderboardTile({
    super.key,
    required this.rank,
    required this.score,
    this.userAvatarUrl,
    this.username,
  });

  @override
  Widget build(BuildContext context) {
    final isTopThree = rank <= 3;

    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            child: isTopThree
                ? Text(
                    _getMedalEmoji(rank),
                    style: const TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  )
                : Text(
                    '#$rank',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.primary,
            backgroundImage:
                userAvatarUrl != null ? NetworkImage(userAvatarUrl!) : null,
            child: userAvatarUrl == null
                ? Text(
                    Helpers.getInitials(username ?? 'P'),
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
        ],
      ),
      title: Text(
        username ?? 'Player',
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        Helpers.timeAgo(score.playedAt),
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            Helpers.formatNumber(score.score),
            style: TextStyle(
              color: isTopThree ? AppTheme.accent : AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            score.gameTitle,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _getMedalEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '';
    }
  }
}
