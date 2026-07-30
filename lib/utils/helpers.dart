import 'package:intl/intl.dart';

/// General-purpose helper utilities
class Helpers {
  Helpers._();

  /// Format a number with commas (e.g. 1,234,567)
  static String formatNumber(int number) {
    return NumberFormat.decimalPattern().format(number);
  }

  /// Format a date as a readable string
  static String formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  /// Format date as relative time (e.g. "2 hours ago")
  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatDate(date);
  }

  /// Generate initials from a display name (max 2 chars)
  static String getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '??';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
