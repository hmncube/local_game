class LevelModel {
  final int id;
  final int status; //0 not done and 1 done
  final int points;
  final int? finishedAt;
  final int? startedAt;

  LevelModel({
    required this.id,
    this.status = 0,
    this.points = 0,
    this.finishedAt,
    this.startedAt,
  });

  factory LevelModel.fromMap(Map<String, dynamic> map) {
    return LevelModel(
      id: map['id'],
      status: map['status'],
      points: map['points'],
      finishedAt: map['finishedAt'],
      startedAt: map['startedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status,
      'points': points,
      'finishedAt': finishedAt,
      'startedAt': startedAt,
    };
  }
}
