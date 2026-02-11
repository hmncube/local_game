class Points {
  final int initialTotalPoints;
  final int runPoints;
  final int bonusPoints;
  final int addedPoints; // The actual delta added to the user's total score
  final int? nextLevelId;
  final String? gameRoute;

  Points({
    required this.initialTotalPoints,
    required this.runPoints,
    required this.bonusPoints,
    required this.addedPoints,
    this.nextLevelId,
    this.gameRoute,
  });
}
