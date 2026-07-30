import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/score_model.dart';
import '../config/constants.dart';

/// Manages leaderboard data (global and daily).
class LeaderboardProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ScoreModel> _globalLeaderboard = [];
  List<ScoreModel> _dailyLeaderboard = [];
  bool _isLoading = false;
  String? _error;
  LeaderboardTab _activeTab = LeaderboardTab.global;

  // ── Getters ─────────────────────────────────────────────
  List<ScoreModel> get globalLeaderboard => _globalLeaderboard;
  List<ScoreModel> get dailyLeaderboard => _dailyLeaderboard;
  bool get isLoading => _isLoading;
  String? get error => _error;
  LeaderboardTab get activeTab => _activeTab;

  // ── Tab Switch ──────────────────────────────────────────
  void setTab(LeaderboardTab tab) {
    _activeTab = tab;
    notifyListeners();
  }

  // ── Fetch Global Leaderboard ────────────────────────────
  Future<void> fetchGlobalLeaderboard({String? gameId}) async {
    _setLoading(true);
    _error = null;
    try {
      Query query = _firestore
          .collection(AppConstants.scoresCollection)
          .orderBy('score', descending: true)
          .limit(AppConstants.pageSize);

      if (gameId != null) {
        query = query.where('gameId', isEqualTo: gameId);
      }

      final snapshot = await query.get();
      _globalLeaderboard = snapshot.docs
          .map((doc) => ScoreModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load leaderboard.';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // ── Fetch Daily Leaderboard ─────────────────────────────
  Future<void> fetchDailyLeaderboard({String? gameId}) async {
    _setLoading(true);
    _error = null;
    try {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));

      Query query = _firestore
          .collection(AppConstants.scoresCollection)
          .where('playedAt', isGreaterThanOrEqualTo: yesterday)
          .orderBy('playedAt', descending: true)
          .orderBy('score', descending: true)
          .limit(AppConstants.pageSize);

      if (gameId != null) {
        query = query.where('gameId', isEqualTo: gameId);
      }

      final snapshot = await query.get();
      _dailyLeaderboard = snapshot.docs
          .map((doc) => ScoreModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load daily leaderboard.';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // ── Helpers ─────────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

/// Enum for leaderboard tabs
enum LeaderboardTab { global, daily }
