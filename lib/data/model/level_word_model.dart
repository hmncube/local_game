import 'package:equatable/equatable.dart';

class LevelWordModel extends Equatable {
  final int levelId;
  final int wordId;
  final int displayOrder;

  const LevelWordModel({
    required this.levelId,
    required this.wordId,
    required this.displayOrder,
  });

  factory LevelWordModel.fromMap(Map<String, dynamic> map) {
    return LevelWordModel(
      levelId: map['level_id'],
      wordId: map['word_id'],
      displayOrder: map['display_order'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'level_id': levelId,
      'word_id': wordId,
      'display_order': displayOrder,
    };
  }

  LevelWordModel copyWith({
    int? levelId,
    int? wordId,
    int? displayOrder,
  }) {
    return LevelWordModel(
      levelId: levelId ?? this.levelId,
      wordId: wordId ?? this.wordId,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  @override
  List<Object?> get props => [
        levelId,
        wordId,
        displayOrder,
      ];
}
