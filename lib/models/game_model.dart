import 'package:flutter/material.dart';

/// Represents a game available in the hub.
class GameModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String thumbnailUrl;
  final String? bannerUrl;
  final bool isOnline;
  final bool isFeatured;
  final int playsCount;
  final double rating;
  final DateTime updatedAt;

  const GameModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.thumbnailUrl,
    this.bannerUrl,
    this.isOnline = false,
    this.isFeatured = false,
    this.playsCount = 0,
    this.rating = 0.0,
    required this.updatedAt,
  });

  /// Factory from Firestore document
  factory GameModel.fromMap(Map<String, dynamic> map, String id) {
    return GameModel(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'Arcade',
      thumbnailUrl: map['thumbnailUrl'] as String? ?? '',
      bannerUrl: map['bannerUrl'] as String?,
      isOnline: map['isOnline'] as bool? ?? false,
      isFeatured: map['isFeatured'] as bool? ?? false,
      playsCount: map['playsCount'] as int? ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      updatedAt: (map['updatedAt'] as dynamic?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore-compatible map
  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'category': category,
        'thumbnailUrl': thumbnailUrl,
        'bannerUrl': bannerUrl,
        'isOnline': isOnline,
        'isFeatured': isFeatured,
        'playsCount': playsCount,
        'rating': rating,
        'updatedAt': updatedAt,
      };

  /// Category icon helper
  static IconData categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'puzzle':
        return Icons.extension;
      case 'action':
        return Icons.sports_esports;
      case 'arcade':
        return Icons.videogame_asset;
      case 'strategy':
        return Icons.psychology;
      default:
        return Icons.games;
    }
  }
}
