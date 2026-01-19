import 'package:equatable/equatable.dart';

class LevelModel extends Equatable {
  final int id;
  final int status; //0 not done and 1 done
  final int points;
  final int difficulty; //1 easy ; 2 moderate; 3 Hard
  final int type; //1 word search;  2 word match; 3 word link;
  final int languageId; //1 English; 2 Shona; 3 Ndebele
  final int? finishedAt;
  final int? startedAt;
  final List<String> wordsEn;
  final List<String> wordsSn;
  final List<String> wordsNd;

  const LevelModel({
    required this.id,
    required this.difficulty,
    required this.type,
    this.status = 0,
    this.points = 0,
    this.finishedAt,
    this.startedAt,
    this.languageId = 1,
    this.wordsEn = const [],
    this.wordsSn = const [],
    this.wordsNd = const [],
  });

  factory LevelModel.fromMap(Map<String, dynamic> map) {
    return LevelModel(
      id: map['id'],
      status: map['status'],
      points: map['points'],
      type: map['level_type'],
      difficulty: map['difficulty'],
      finishedAt: map['finished_at'],
      startedAt: map['started_at'],
      languageId: map['language_id'],
      wordsEn: _splitStringToList(map['words_en']),
      wordsSn: _splitStringToList(map['words_sn']),
      wordsNd: _splitStringToList(map['words_nd']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status,
      'points': points,
      'level_type': type,
      'difficulty': difficulty,
      'finished_at': finishedAt,
      'started_at': startedAt,
      'language_id': languageId,
      'words_en': wordsEn.join(','),
      'words_sn': wordsSn.join(','),
      'words_nd': wordsNd.join(','),
    };
  }

  LevelModel copyWith({
    int? id,
    int? status,
    int? points,
    int? difficulty,
    int? finishedAt,
    int? startedAt,
    int? type,
    List<String>? wordsEn,
    List<String>? wordsSn,
    List<String>? wordsNd,
  }) {
    return LevelModel(
      id: id ?? this.id,
      status: status ?? this.status,
      points: points ?? this.points,
      difficulty: difficulty ?? this.difficulty,
      finishedAt: finishedAt ?? this.finishedAt,
      startedAt: startedAt ?? this.startedAt,
      wordsEn: wordsEn ?? this.wordsEn,
      wordsSn: wordsSn ?? this.wordsSn,
      wordsNd: wordsNd ?? this.wordsNd,
      type: type ?? this.type,
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
    wordsEn,
    wordsNd,
    wordsSn,
    type,
  ];

  static List<String> _splitStringToList(String map) {
    return map.split(',');
  }
}
