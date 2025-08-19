
class DailyChallengeModel {
  final String challengeDate; // Using ISO8601 format (YYYY-MM-DD)
  final int wordId;
  final String language;
  final double bonusMultiplier;

  DailyChallengeModel({
    required this.challengeDate,
    required this.wordId,
    required this.language,
    this.bonusMultiplier = 1.0,
  });

  factory DailyChallengeModel.fromMap(Map<String, dynamic> map) {
    return DailyChallengeModel(
      challengeDate: map['challenge_date'],
      wordId: map['word_id'],
      language: map['language'],
      bonusMultiplier: map['bonus_multiplier'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'challenge_date': challengeDate,
      'word_id': wordId,
      'language': language,
      'bonus_multiplier': bonusMultiplier,
    };
  }
}
