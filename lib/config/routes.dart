import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/home_screen.dart';
import '../screens/game_details_screen.dart';
import '../screens/game_play_screen.dart';
import '../screens/game_over_screen.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/notification_screen.dart';

/// Named route definitions for Jin Gaming Hub
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String gameDetails = '/game-details';
  static const String gamePlay = '/game-play';
  static const String gameOver = '/game-over';
  static const String leaderboard = '/leaderboard';
  static const String profile = '/profile';
  static const String notifications = '/notifications';

  /// Route table
  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        auth: (_) => const AuthScreen(),
        home: (_) => const HomeScreen(),
        gameDetails: (_) => const GameDetailsScreen(),
        gamePlay: (_) => const GamePlayScreen(),
        gameOver: (_) => const GameOverScreen(),
        leaderboard: (_) => const LeaderboardScreen(),
        profile: (_) => const ProfileScreen(),
        notifications: (_) => const NotificationScreen(),
      };

  /// Convenience navigation helpers
  static Future<T?> push<T>(BuildContext context, String route,
      {Object? arguments}) {
    return Navigator.of(context).pushNamed<T>(route, arguments: arguments);
  }

  static Future<T?> pushReplacement<T>(BuildContext context, String route,
      {Object? arguments}) {
    return Navigator.of(context)
        .pushReplacementNamed<T, dynamic>(route, arguments: arguments);
  }

  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }

  static void popUntil(BuildContext context, String route) {
    Navigator.of(context).popUntil(ModalRoute.withName(route));
  }
}
