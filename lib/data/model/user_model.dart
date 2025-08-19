
import 'dart:convert';

class UserModel {
  final String id;
  final String? username;
  final String preferredLanguage;
  final int totalGames;
  final int gamesWon;
  final int currentStreak;
  final int longestStreak;
  final int totalScore;
  final Map<String, dynamic> settings;
  final int createdAt;
  final int lastPlayed;

  UserModel({
    required this.id,
    this.username,
    this.preferredLanguage = 'shona',
    this.totalGames = 0,
    this.gamesWon = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalScore = 0,
    required this.settings,
    required this.createdAt,
    required this.lastPlayed,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'],
      preferredLanguage: map['preferred_language'],
      totalGames: map['total_games'],
      gamesWon: map['games_won'],
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
      'total_games': totalGames,
      'games_won': gamesWon,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'total_score': totalScore,
      'settings': jsonEncode(settings),
      'created_at': createdAt,
      'last_played': lastPlayed,
    };
  }
}
