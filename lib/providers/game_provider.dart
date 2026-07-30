import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game_model.dart';
import '../models/score_model.dart';
import '../services/database_service.dart';
import '../config/constants.dart';

/// Manages the game catalog, filtering, and score recording.
class GameProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseService _db = DatabaseService.instance;

  List<GameModel> _allGames = [];
  List<GameModel> _filteredGames = [];
  List<GameModel> _featuredGames = [];
  String _selectedCategory = 'All';
  bool _isLoading = false;
  String? _error;

  // ── Current Game Play State ─────────────────────────────
  GameModel? _currentGame;
  int _currentScore = 0;
  bool _isGameRunning = false;

  // ── Getters ─────────────────────────────────────────────
  List<GameModel> get games => _filteredGames;
  List<GameModel> get featuredGames => _featuredGames;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  GameModel? get currentGame => _currentGame;
  int get currentScore => _currentScore;
  bool get isGameRunning => _isGameRunning;

  // ── Fetch Games from Firestore ──────────────────────────
  Future<void> fetchGames() async {
    _setLoading(true);
    _error = null;
    try {
      final snapshot = await _firestore
          .collection(AppConstants.gamesCollection)
          .orderBy('updatedAt', descending: true)
          .get();

      _allGames = snapshot.docs
          .map((doc) => GameModel.fromMap(doc.data(), doc.id))
          .toList();

      _featuredGames =
          _allGames.where((g) => g.isFeatured).toList();

      _applyFilter();
    } catch (e) {
      _error = 'Failed to load games. Pull to refresh.';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // ── Category Filter ─────────────────────────────────────
  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_selectedCategory == 'All') {
      _filteredGames = List.from(_allGames);
    } else {
      _filteredGames = _allGames
          .where((g) => g.category.toLowerCase() == _selectedCategory.toLowerCase())
          .toList();
    }
  }

  // ── Select Game ─────────────────────────────────────────
  void selectGame(GameModel game) {
    _currentGame = game;
    _currentScore = 0;
    notifyListeners();
  }

  // ── Game Play State ─────────────────────────────────────
  void startGame() {
    _isGameRunning = true;
    _currentScore = 0;
    notifyListeners();
  }

  void updateScore(int score) {
    _currentScore = score;
    notifyListeners();
  }

  void pauseGame() {
    _isGameRunning = false;
    notifyListeners();
  }

  void resumeGame() {
    _isGameRunning = true;
    notifyListeners();
  }

  // ── End Game & Save Score ───────────────────────────────
  Future<ScoreModel> endGame({required String userId}) async {
    _isGameRunning = false;

    final score = ScoreModel(
      id: '${_currentGame!.id}_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      gameId: _currentGame!.id,
      gameTitle: _currentGame!.title,
      score: _currentScore,
      playedAt: DateTime.now(),
    );

    // Save locally
    await _db.saveScore(score);

    // Save to cloud
    try {
      await _firestore
          .collection(AppConstants.scoresCollection)
          .doc(score.id)
          .set(score.toMap());
    } catch (_) {
      // Cloud save failed — score is still saved locally
    }

    // Update user's games played count
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'gamesPlayed': FieldValue.increment(1),
        'totalCoins': FieldValue.increment(_currentScore),
      });
    } catch (_) {}

    notifyListeners();
    return score;
  }

  // ── Get High Score for a Game ───────────────────────────
  int getHighScore(String gameId) => _db.getHighScore(gameId);

  // ── Helpers ─────────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
