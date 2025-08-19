import 'package:injectable/injectable.dart';
import 'package:local_game/data/database_provider.dart';
import 'package:sqflite/sqflite.dart';

@module
abstract class AppModule {
  @preResolve
  Future<Database> get database async {
    final databaseProvider = DatabaseProvider();
    return await databaseProvider.database;
  }
}