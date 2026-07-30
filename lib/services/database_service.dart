import 'package:hive_flutter/hive_flutter.dart';
import '../models/score_model.dart';
import '../config/constants.dart';

/// Local database service using Hive for offline scores and preferences.
class DatabaseService {
  static DatabaseService? _instance;
  DatabaseService._();
  static DatabaseService get instance => _instance ??= DatabaseService._();

  late Box _scoresBox;
  late Box _preferencesBox;

  /// Initialise Hive and open boxes
  Future<void> init() async {
    await Hive.initFlutter();
    _scoresBox = await Hive.openBox(AppConstants.scoresBox);
    _preferencesBox = await Hive.openBox(AppConstants.preferencesBox);
  }

  // ── Score Operations ────────────────────────────────────

  /// Save a score locally
  Future<void> saveScore(ScoreModel score) async {
    await _scoresBox.put(score.id, score.toHiveMap());
  }

  /// Get all local scores for a specific game
  List<ScoreModel> getScoresForGame(String gameId) {
    final scores = <ScoreModel>[];
    for (final key in _scoresBox.keys) {
      final map = _scoresBox.get(key);
      if (map != null && map['gameId'] == gameId) {
        scores.add(ScoreModel.fromHive(Map<dynamic, dynamic>.from(map), key.toString()));
      }
    }
    scores.sort((a, b) => b.score.compareTo(a.score));
    return scores;
  }

  /// Get the high score for a specific game
  int getHighScore(String gameId) {
    final scores = getScoresForGame(gameId);
    return scores.isEmpty ? 0 : scores.first.score;
  }

  /// Get all scores for a user
  List<ScoreModel> getScoresForUser(String userId) {
    final scores = <ScoreModel>[];
    for (final key in _scoresBox.keys) {
      final map = _scoresBox.get(key);
      if (map != null && map['userId'] == userId) {
        scores.add(ScoreModel.fromHive(Map<dynamic, dynamic>.from(map), key.toString()));
      }
    }
    scores.sort((a, b) => b.playedAt.compareTo(a.playedAt));
    return scores;
  }

  // ── Preference Operations ────────────────────────────────

  /// Save a user preference
  Future<void> setPreference(String key, dynamic value) async {
    await _preferencesBox.put(key, value);
  }

  /// Get a user preference
  T? getPreference<T>(String key) {
    return _preferencesBox.get(key) as T?;
  }

  /// Clear all local data
  Future<void> clearAll() async {
    await _scoresBox.clear();
    await _preferencesBox.clear();
  }
}
