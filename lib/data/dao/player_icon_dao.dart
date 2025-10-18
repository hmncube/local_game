import 'package:sqflite/sqflite.dart';
import '../model/player_icon_model.dart';

class PlayerIconDao {
  final Database _db;

  PlayerIconDao(this._db);

  Future<void> insertPlayerIcon(PlayerIconModel playerIcon) async {
    await _db.insert(
      'player_icons',
      playerIcon.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PlayerIconModel>> getAllPlayerIcons() async {
    final List<Map<String, dynamic>> maps = await _db.query('player_icons');
    return List.generate(maps.length, (i) {
      return PlayerIconModel.fromMap(maps[i]);
    });
  }

  Future<PlayerIconModel?> getPlayerIconById(int id) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'player_icons',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return PlayerIconModel.fromMap(maps.first);
    }
    return null;
  }
}
