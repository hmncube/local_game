import 'package:equatable/equatable.dart';

class WordModel extends Equatable {
  final int? id;
  final int groupId;
  final String word;
  final String language;
  final int wordLength;
  final int difficulty;
  final String? definition;
  final bool isActive;
  final int createdAt;

  const WordModel({
    this.id,
    required this.groupId,
    required this.word,
    required this.language,
    required this.wordLength,
    this.difficulty = 2,
    this.definition,
    this.isActive = true,
    required this.createdAt,
  });

  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      id: map['id'],
      groupId: map['group_id'],
      word: map['word'],
      language: map['language'],
      wordLength: map['word_length'],
      difficulty: map['difficulty'],
      definition: map['definition'],
      isActive: map['is_active'] == 1,
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'word': word,
      'language': language,
      'word_length': wordLength,
      'difficulty': difficulty,
      'definition': definition,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        groupId,
        word,
        language,
        wordLength,
        difficulty,
        definition,
        isActive,
        createdAt,
      ];
}
