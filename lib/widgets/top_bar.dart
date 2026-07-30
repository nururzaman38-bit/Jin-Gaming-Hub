import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Top bar widget used on the Home Screen.
class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String? avatarUrl;
  final String username;
  final int coinBalance;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationTap;
  final int notificationCount;

  const TopBar({
    super.key,
    this.avatarUrl,
    required this.username,
    required this.coinBalance,
    required this.onProfileTap,
    required this.onNotificationTap,
    this.notificationCount = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // ── Avatar ────────────────────────────────────
            GestureDetector(
              onTap: onProfileTap,
              child: CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.primary,
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                child: avatarUrl == null
                    ? Text(
                        username.isNotEmpty ? username[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),

            // ── Username & Coins ──────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hello, $username',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.monetization_on,
                          color: AppTheme.accent, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        coinBalance.toString(),
                        style: const TextStyle(
                          color: AppTheme.accent,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Notification Bell ─────────────────────────
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: AppTheme.textPrimary, size: 28),
                  onPressed: onNotificationTap,
                ),
                if (notificationCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppTheme.error,
                        shape: BoxShape.circle,
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        notificationCount > 9
                            ? '9+'
                            : notificationCount.toString(),
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
