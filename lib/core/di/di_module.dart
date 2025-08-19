import 'package:injectable/injectable.dart';
import 'package:local_game/data/database_provider.dart';
import 'package:sqflite/sqflite.dart';

@module
abstract class AppModule {
  @lazySingleton
  DatabaseProvider get databaseProvider => DatabaseProvider.instance;

  @preResolve
  Future<Database> get database => databaseProvider.database;
}