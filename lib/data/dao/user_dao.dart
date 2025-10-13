import 'package:injectable/injectable.dart';
import 'package:local_game/data/database_provider.dart';
import 'package:local_game/data/model/user_model.dart';
import 'package:sqflite/sqflite.dart';

@injectable
class UserDao {
  final DatabaseProvider _dbProvider;

  UserDao(this._dbProvider);

  Future<int> insert(UserModel user) async {
    final db = await _dbProvider.database;
    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> getUser() async {
    final db = await _dbProvider.database;
    final maps = await db.query('users');
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<UserModel?> find(String id) async {
    final db = await _dbProvider.database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<UserModel?> findByUsername(String username) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> update(UserModel? user) async {
    if (user == null) return 0;
    final db = await _dbProvider.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> updateTotalScore(String userId, int totalScore) async {
    final db = await _dbProvider.database;
    return await db.update(
      'users',
      {'total_score': totalScore},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> updateHints(String userId, int hint) async {
    final db = await _dbProvider.database;
    return await db.update(
      'users',
      {'hints': hint},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
