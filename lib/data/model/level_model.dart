import 'package:equatable/equatable.dart';

import 'word_model.dart';

class LevelModel extends Equatable {
  final int id;
  final int status; //0 not done and 1 done
  final int points;
  final int difficulty; //1 easy ; 2 moderate; 3 Hard
  final int? finishedAt;
  final int? startedAt;
  final List<WordModel> words;

  const LevelModel({
    required this.id,
    required this.difficulty,
    this.status = 0,
    this.points = 0,
    this.finishedAt,
    this.startedAt,
    this.words = const [],
  });

  factory LevelModel.fromMap(Map<String, dynamic> map) {
    return LevelModel(
      id: map['id'],
      status: map['status'],
      points: map['points'],
      difficulty: map['difficulty'],
      finishedAt: map['finishedAt'],
      startedAt: map['startedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status,
      'points': points,
      'difficulty': difficulty,
      'finishedAt': finishedAt,
      'startedAt': startedAt,
    };
  }

  LevelModel copyWith({
    int? id,
    int? status,
    int? points,
    int? difficulty,
    int? finishedAt,
    int? startedAt,
    List<WordModel>? words,
  }) {
    return LevelModel(
      id: id ?? this.id,
      status: status ?? this.status,
      points: points ?? this.points,
      difficulty: difficulty ?? this.difficulty,
      finishedAt: finishedAt ?? this.finishedAt,
      startedAt: startedAt ?? this.startedAt,
      words: words ?? this.words,
    );
  }

  @override
  List<Object?> get props => [
        id,
        status,
        points,
        difficulty,
        finishedAt,
        startedAt,
        words,
      ];
}
