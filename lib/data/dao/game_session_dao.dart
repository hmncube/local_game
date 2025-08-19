
import 'package:local_game/data/database_provider.dart';
import 'package:local_game/data/model/game_session_model.dart';

class GameSessionDao {
  final DatabaseProvider _dbProvider;

  GameSessionDao(this._dbProvider);

  Future<int> insert(GameSessionModel session) async {
    final db = await _dbProvider.database;
    return await db.insert('game_sessions', session.toMap());
  }

  Future<GameSessionModel?> find(String id) async {
    final db = await _dbProvider.database;
    final maps = await db.query('game_sessions', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return GameSessionModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<GameSessionModel>> findSessionsForUser(String userId, {int limit = 50}) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'game_sessions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'played_at DESC',
      limit: limit,
    );
    return maps.map((map) => GameSessionModel.fromMap(map)).toList();
  }

  Future<int> update(GameSessionModel session) async {
    final db = await _dbProvider.database;
    return await db.update('game_sessions', session.toMap(), where: 'id = ?', whereArgs: [session.id]);
  }
}
