
import 'package:injectable/injectable.dart';
import 'package:local_game/data/database_provider.dart';
import 'package:local_game/data/model/level_model.dart';

@injectable
class LevelDao {
  final DatabaseProvider _dbProvider;

  LevelDao(this._dbProvider);

  Future<List<LevelModel>> getAllLevels() async {
    final db = await _dbProvider.database;
    final maps = await db.query('levels', orderBy: 'id ASC');
    if (maps.isNotEmpty) {
      return maps.map((map) => LevelModel.fromMap(map)).toList();
    }
    return [];
  }
}
