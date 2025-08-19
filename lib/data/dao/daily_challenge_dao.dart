
import 'package:local_game/data/database_provider.dart';
import 'package:local_game/data/model/daily_challenge_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';


class DailyChallengeDao {
  final DatabaseProvider _dbProvider;
  static final _dateFormat = DateFormat('yyyy-MM-dd');

  DailyChallengeDao(this._dbProvider);

  Future<int> insert(DailyChallengeModel challenge) async {
    final db = await _dbProvider.database;
    return await db.insert('daily_challenges', challenge.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<DailyChallengeModel?> getForDate(DateTime date, String language) async {
    final db = await _dbProvider.database;
    final dateString = _dateFormat.format(date.toUtc());
    final maps = await db.query(
      'daily_challenges',
      where: 'challenge_date = ? AND language = ?',
      whereArgs: [dateString, language],
    );
    if (maps.isNotEmpty) {
      return DailyChallengeModel.fromMap(maps.first);
    }
    return null;
  }
}
