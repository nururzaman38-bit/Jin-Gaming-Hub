import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';
import '../utils/helpers.dart';

/// Screen 8: User Profile & Wallet Screen
/// - User avatar, username, email
/// - Total coins earned, games played
/// - Game history
/// - Edit profile & Logout
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _displayNameCtrl = TextEditingController();

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    super.dispose();
  }

  // ── Logout ──────────────────────────────────────────────
  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Logout',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        AppRoutes.pushReplacement(context, AppRoutes.auth);
      }
    }
  }

  // ── Edit Profile ────────────────────────────────────────
  void _startEditing() {
    final auth = context.read<AuthProvider>();
    _displayNameCtrl.text = auth.user?.displayName ?? '';
    setState(() => _isEditing = true);
  }

  Future<void> _saveProfile() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.updateProfile(
      displayName: _displayNameCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isEditing = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated!'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  // ── Build ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _startEditing,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ── Avatar ─────────────────────────────────────
            Stack(
              children: [
                CircleAvatar(
                  radius: 56,
                  backgroundColor: AppTheme.primary,
                  backgroundImage:
                      user?.photoUrl != null
                          ? NetworkImage(user!.photoUrl!)
                          : null,
                  child: user?.photoUrl == null
                      ? Text(
                          Helpers.getInitials(user?.displayName ?? 'P'),
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.background,
                        width: 3,
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.camera_alt,
                        color: AppTheme.textPrimary, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Display Name (editable) ────────────────────
            if (_isEditing)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _displayNameCtrl,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          hintText: 'Display Name',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check, color: AppTheme.success),
                      onPressed: _saveProfile,
                    ),
                  ],
                ),
              )
            else
              Text(
                user?.displayName ?? 'Player',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 4),

            Text(
              user?.email ?? '',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),

            // ── Stats Cards ────────────────────────────────
            Row(
              children: [
                _buildStatCard(
                  icon: Icons.monetization_on,
                  label: 'Coins',
                  value: Helpers.formatNumber(user?.totalCoins ?? 0),
                  color: AppTheme.accent,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  icon: Icons.sports_esports,
                  label: 'Games Played',
                  value: (user?.gamesPlayed ?? 0).toString(),
                  color: AppTheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Menu Items ─────────────────────────────────
            _buildMenuTile(
              icon: Icons.history,
              title: 'Game History',
              subtitle: 'View your recent game scores',
              onTap: () {
                // Navigate to game history
              },
            ),
            _buildMenuTile(
              icon: Icons.settings,
              title: 'Settings',
              subtitle: 'App preferences and notifications',
              onTap: () {
                // Navigate to settings
              },
            ),
            _buildMenuTile(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'FAQs and contact support',
              onTap: () {
                // Navigate to help
              },
            ),
            _buildMenuTile(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'Jin Gaming Hub v1.0.0',
              onTap: () {
                // Show about dialog
              },
            ),

            const SizedBox(height: 32),

            // ── Logout Button ──────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout, color: AppTheme.error),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: AppTheme.error, fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      onTap: onTap,
    );
  }
}
