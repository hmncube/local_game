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

    if (maps.isNotEmpty) {
      final levelWordsList = await db.query(
        'level_words',
        where: 'level_id = ?',
        whereArgs: [id],
      );

      final List<WordModel> words = [];
      for (final levelWordMap in levelWordsList) {
        final levelWord = LevelWordModel.fromMap(levelWordMap);
        final word = await _wordDao.find(levelWord.wordId);
        if (word != null) {
          words.add(word);
        }
      }

      final level = LevelModel.fromMap(maps.first);
      return level.copyWith(words: words);
    }
    return null;
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
