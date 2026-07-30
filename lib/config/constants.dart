/// App-wide constants for Jin Gaming Hub
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Jin Gaming Hub';
  static const String appVersion = '1.0.0';

  // Collections (Firestore)
  static const String usersCollection = 'users';
  static const String gamesCollection = 'games';
  static const String scoresCollection = 'scores';
  static const String leaderboardCollection = 'leaderboard';

  // Hive Boxes
  static const String userBox = 'userBox';
  static const String scoresBox = 'scoresBox';
  static const String preferencesBox = 'preferencesBox';

  // Game Categories
  static const List<String> categories = [
    'All',
    'Puzzle',
    'Action',
    'Arcade',
    'Strategy',
  ];

  // Animation Durations
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration fadeInDuration = Duration(milliseconds: 500);

  // Pagination
  static const int pageSize = 20;

  // Score
  static const int defaultCoins = 100;
}
