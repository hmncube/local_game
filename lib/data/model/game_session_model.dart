
import 'dart:convert';

class GameSessionModel {
  final String id;
  final String userId;
  final int wordId;
  final String gameType;
  final List<Map<String, dynamic>> guesses;
  final bool isCompleted;
  final bool isWon;
  final int attemptsUsed;
  final int score;
  final int? durationSeconds;
  final int playedAt;

  GameSessionModel({
    required this.id,
    required this.userId,
    required this.wordId,
    this.gameType = 'daily',
    required this.guesses,
    this.isCompleted = false,
    this.isWon = false,
    this.attemptsUsed = 0,
    this.score = 0,
    this.durationSeconds,
    required this.playedAt,
  });

  factory GameSessionModel.fromMap(Map<String, dynamic> map) {
    return GameSessionModel(
      id: map['id'],
      userId: map['user_id'],
      wordId: map['word_id'],
      gameType: map['game_type'],
      guesses: List<Map<String, dynamic>>.from(jsonDecode(map['guesses'])),
      isCompleted: map['is_completed'] == 1,
      isWon: map['is_won'] == 1,
      attemptsUsed: map['attempts_used'],
      score: map['score'],
      durationSeconds: map['duration_seconds'],
      playedAt: map['played_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'word_id': wordId,
      'game_type': gameType,
      'guesses': jsonEncode(guesses),
      'is_completed': isCompleted ? 1 : 0,
      'is_won': isWon ? 1 : 0,
      'attempts_used': attemptsUsed,
      'score': score,
      'duration_seconds': durationSeconds,
      'played_at': playedAt,
    };
  }
}
