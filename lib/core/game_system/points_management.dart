class PointsManagement {
  static const int basePoints = 10;
  static const int timeBonus = 20;
  static const int perfectTimeSeconds = 3;
  static const int goodTimeSeconds = 10;

  static const int maxTimeBonus = 50;
  static const int totalGameTime = 90; // seconds

  // Time thresholds (remaining time)
  static const int excellentTimeRemaining = 60; // 30s used = excellent
  static const int goodTimeRemaining = 30; // 60s used = good
  static const int fairTimeRemaining = 10; // 80s used = fair

  static int calculateTimePoints(String word, {required int seconds}) {
    return calculatePoints(word) + calculateTimeBonus(seconds);
  }

  static int calculateTimeBonus(int seconds) {
    if (seconds <= perfectTimeSeconds) {
      return timeBonus; // Full bonus
    } else if (seconds <= goodTimeSeconds) {
      // Linear decay between perfect and good time
      final ratio =
          (seconds - perfectTimeSeconds) /
          (goodTimeSeconds - perfectTimeSeconds);
      return (timeBonus * (1 - ratio)).round();
    }
    return 0; // No bonus after good time threshold
  }

  static int calculatePoints(String word) {
    // Letter frequency scores (rarer letters = higher points)
    final Map<String, int> letterScores = {
      // Very common letters (1 point)
      'a': 1, 'e': 1, 'i': 1, 'o': 1, 'u': 1,
      'n': 1, 'r': 1, 't': 1, 's': 1, 'k': 1,

      // Common letters (2 points)
      'd': 2, 'h': 2, 'm': 2, 'w': 2, 'y': 2,
      'b': 2, 'p': 2, 'g': 2, 'v': 2,

      // Less common letters (3 points)
      'z': 3, 'f': 3, 'l': 3, 'c': 3,

      // Rare letters (4 points)
      'j': 4, 'q': 4, 'x': 4,
    };

    if (word.isEmpty) return 0;

    int totalPoints = 0;
    String lowerWord = word.toLowerCase();

    // Calculate letter scores
    for (int i = 0; i < lowerWord.length; i++) {
      String letter = lowerWord[i];
      totalPoints +=
          letterScores[letter] ?? 2; // Default to 2 if letter not in map
    }

    // Length bonus
    int lengthBonus = 0;
    if (word.length >= 7) {
      lengthBonus = 10;
    } else if (word.length >= 5) {
      lengthBonus = 5;
    } else if (word.length >= 3) {
      lengthBonus = 2;
    }

    totalPoints += lengthBonus;

    return totalPoints;
  }

  static int calculateStars(int points) {
    if (points > 90) {
      return 3;
    } else if (points > 60) {
      return 2;
    } else {
      return 1;
    }
  }

  static int calculateTimeLeftPoints({required int timeLeft}) {
    return _calculateTimeLeftBonus(timeLeft);
  }

  static int _calculateTimeLeftBonus(int remainingSeconds) {
    // Clamp to valid range
    remainingSeconds = remainingSeconds.clamp(0, totalGameTime);

    if (remainingSeconds >= excellentTimeRemaining) {
      // Excellent: Still have 60+ seconds = Full bonus
      return maxTimeBonus;
    } else if (remainingSeconds >= goodTimeRemaining) {
      // Good: 30-60 seconds remaining = 70-100% bonus
      final ratio =
          (remainingSeconds - goodTimeRemaining) /
          (excellentTimeRemaining - goodTimeRemaining);
      final bonusPercent = 0.7 + (ratio * 0.3); // 70% to 100%
      return (maxTimeBonus * bonusPercent).round();
    } else if (remainingSeconds >= fairTimeRemaining) {
      // Fair: 10-30 seconds remaining = 30-70% bonus
      final ratio =
          (remainingSeconds - fairTimeRemaining) /
          (goodTimeRemaining - fairTimeRemaining);
      final bonusPercent = 0.3 + (ratio * 0.4); // 30% to 70%
      return (maxTimeBonus * bonusPercent).round();
    } else if (remainingSeconds > 0) {
      // Poor: 1-10 seconds remaining = 10-30% bonus
      final ratio = remainingSeconds / fairTimeRemaining;
      final bonusPercent = 0.1 + (ratio * 0.2); // 10% to 30%
      return (maxTimeBonus * bonusPercent).round();
    }

    // Time's up: minimum bonus
    return (maxTimeBonus * 0.05).round(); // 5% bonus
  }
}
