
import 'package:local_game/data/database_provider.dart';
import 'package:local_game/data/model/word_model.dart';
import 'package:sqflite/sqflite.dart';

class WordDao {
  final DatabaseProvider _dbProvider;

  WordDao(this._dbProvider);

  Future<int> insert(WordModel word) async {
    final db = await _dbProvider.database;
    return await db.insert('words', word.toMap());
  }

  Future<WordModel?> find(int id) async {
    final db = await _dbProvider.database;
    final maps = await db.query('words', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return WordModel.fromMap(maps.first);
    }
    return null;
  }

  Future<WordModel?> getRandomWord(String language, int length, int difficulty) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'words',
      where: 'language = ? AND word_length = ? AND difficulty = ? AND is_active = 1',
      whereArgs: [language, length, difficulty],
      orderBy: 'RANDOM()',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return WordModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> update(WordModel word) async {
    final db = await _dbProvider.database;
    return await db.update('words', word.toMap(), where: 'id = ?', whereArgs: [word.id]);
  }

  Future<int> delete(int id) async {
    final db = await _dbProvider.database;
    return await db.delete('words', where: 'id = ?', whereArgs: [id]);
  }
}
