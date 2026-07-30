import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Notification Screen – shows recent notifications.
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder – in production, wire to a notifications provider
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off_outlined,
                size: 64, color: AppTheme.textSecondary),
            SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
