import 'package:share_plus/share_plus.dart';

/// Utility for sharing scores via the native share sheet.
class ShareService {
  ShareService._();

  /// Share a game score on social media / messaging apps
  static Future<void> shareScore({
    required String gameTitle,
    required int score,
    int? highScore,
  }) async {
    final buffer = StringBuffer()
      ..writeln('🎮 Jin Gaming Hub')
      ..writeln()
      ..writeln('I scored $score in $gameTitle!');

    if (highScore != null && highScore > 0) {
      buffer.writeln('🏆 My high score: $highScore');
    }

    buffer
      ..writeln()
      ..writeln('Can you beat my score? Download Jin Gaming Hub now!');

    await Share.share(buffer.toString());
  }
}
