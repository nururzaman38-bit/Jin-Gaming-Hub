/// Represents a single score entry for a game.
class ScoreModel {
  final String id;
  final String userId;
  final String gameId;
  final String gameTitle;
  final int score;
  final DateTime playedAt;

  const ScoreModel({
    required this.id,
    required this.userId,
    required this.gameId,
    required this.gameTitle,
    required this.score,
    required this.playedAt,
  });

  /// Factory from Firestore
  factory ScoreModel.fromMap(Map<String, dynamic> map, String id) {
    return ScoreModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      gameId: map['gameId'] as String? ?? '',
      gameTitle: map['gameTitle'] as String? ?? '',
      score: map['score'] as int? ?? 0,
      playedAt: (map['playedAt'] as dynamic?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore-compatible map
  Map<String, dynamic> toMap() => {
        'userId': userId,
        'gameId': gameId,
        'gameTitle': gameTitle,
        'score': score,
        'playedAt': playedAt,
      };

  /// Factory from Hive (local storage)
  factory ScoreModel.fromHive(Map<dynamic, dynamic> map, String id) {
    return ScoreModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      gameId: map['gameId'] as String? ?? '',
      gameTitle: map['gameTitle'] as String? ?? '',
      score: map['score'] as int? ?? 0,
      playedAt: DateTime.tryParse(map['playedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  /// Convert to Hive-compatible map
  Map<String, dynamic> toHiveMap() => {
        'userId': userId,
        'gameId': gameId,
        'gameTitle': gameTitle,
        'score': score,
        'playedAt': playedAt.toIso8601String(),
      };
}
