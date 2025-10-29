import 'package:injectable/injectable.dart';
import 'package:local_game/data/dao/word_dao.dart';
import 'package:local_game/data/database_provider.dart';
import 'package:local_game/data/model/level_model.dart';
import 'package:local_game/data/model/level_word_model.dart';
import 'package:local_game/data/model/word_model.dart';

@injectable
class LevelDao {
  final DatabaseProvider _dbProvider;
  final WordDao _wordDao;

  LevelDao(this._dbProvider, this._wordDao);

  Future<List<LevelModel>> getAllLevels() async {
    final db = await _dbProvider.database;
    final maps = await db.query('levels', orderBy: 'id ASC');
    if (maps.isNotEmpty) {
      return maps.map((map) => LevelModel.fromMap(map)).toList();
    }
    return [];
  }

  Future<LevelModel?> getLevelById(int id) async {
    final db = await _dbProvider.database;
    final maps = await db.query('levels', where: 'id = ?', whereArgs: [id]);
    return LevelModel.fromMap(maps.first);
  }

  Future<void> updateLevel(LevelModel? level) async {
    if (level == null) return;
    final db = await _dbProvider.database;
    await db.update(
      'levels',
      level.toMap(),
      where: 'id = ?',
      whereArgs: [level.id],
    );
  }
}
