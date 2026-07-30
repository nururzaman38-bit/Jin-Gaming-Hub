/// Represents a user in the system.
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final int totalCoins;
  final int gamesPlayed;
  final DateTime createdAt;
  final DateTime? lastLogin;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.totalCoins = 0,
    this.gamesPlayed = 0,
    required this.createdAt,
    this.lastLogin,
  });

  /// Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'Player',
      photoUrl: map['photoUrl'] as String?,
      totalCoins: map['totalCoins'] as int? ?? 0,
      gamesPlayed: map['gamesPlayed'] as int? ?? 0,
      createdAt: (map['createdAt'] as dynamic?)?.toDate() ?? DateTime.now(),
      lastLogin: (map['lastLogin'] as dynamic?)?.toDate(),
    );
  }

  /// Convert to Firestore-compatible map
  Map<String, dynamic> toMap() => {
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'totalCoins': totalCoins,
        'gamesPlayed': gamesPlayed,
        'createdAt': createdAt,
        'lastLogin': lastLogin,
      };

  /// Copy-with helper for immutable updates
  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    int? totalCoins,
    int? gamesPlayed,
    DateTime? lastLogin,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      totalCoins: totalCoins ?? this.totalCoins,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      createdAt: createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
