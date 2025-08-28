import 'dart:convert';

class UserModel {
  final String id;
  final String? username;
  final String preferredLanguage;
  final int currentStreak;
  final int longestStreak;
  final int totalScore;
  final int hints;
  final Map<String, dynamic> settings;
  final int createdAt;
  final int lastPlayed;

  UserModel({
    required this.id,
    this.username,
    this.preferredLanguage = 'shona',
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalScore = 0,
    this.hints = 0,
    required this.settings,
    required this.createdAt,
    required this.lastPlayed,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'],
      preferredLanguage: map['preferred_language'],
      hints: map['hints'],
      currentStreak: map['current_streak'],
      longestStreak: map['longest_streak'],
      totalScore: map['total_score'],
      settings: jsonDecode(map['settings']),
      createdAt: map['created_at'],
      lastPlayed: map['last_played'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'preferred_language': preferredLanguage,
      'hints': hints,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'total_score': totalScore,
      'settings': jsonEncode(settings),
      'created_at': createdAt,
      'last_played': lastPlayed,
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? preferredLanguage,
    int? currentStreak,
    int? longestStreak,
    int? totalScore,
    int? hints,
    Map<String, dynamic>? settings,
    int? createdAt,
    int? lastPlayed,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalScore: totalScore ?? this.totalScore,
      hints: hints ?? this.hints,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      lastPlayed: lastPlayed ?? this.lastPlayed,
    );
  }
}
