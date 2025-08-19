class WordModel {
  final int? id;
  final String word;
  final String language;
  final int wordLength;
  final int difficulty;
  final String englishTranslation;
  final String? definition;
  final bool isActive;
  final int createdAt;

  WordModel({
    this.id,
    required this.word,
    required this.language,
    required this.wordLength,
    this.difficulty = 2,
    required this.englishTranslation,
    this.definition,
    this.isActive = true,
    required this.createdAt,
  });

  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      id: map['id'],
      word: map['word'],
      language: map['language'],
      wordLength: map['word_length'],
      difficulty: map['difficulty'],
      englishTranslation: map['english_translation'],
      definition: map['definition'],
      isActive: map['is_active'] == 1,
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'language': language,
      'word_length': wordLength,
      'difficulty': difficulty,
      'english_translation': englishTranslation,
      'definition': definition,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
    };
  }
}
