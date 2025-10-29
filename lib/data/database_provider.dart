import 'dart:convert';

import 'package:local_game/data/model/level_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';

class DatabaseProvider {
  static const _dbName = 'local_game.db';
  static const _dbVersion = 1;

  factory DatabaseProvider() => DatabaseProvider._internal();

  DatabaseProvider._internal(); // Private constructor

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    final sql = await rootBundle.loadString('lib/data/sql/schema_v1.sql');

    // Remove comments from the SQL script
    final cleanedSql = sql
        .split('\n')
        .where((line) => !line.trim().startsWith('--'))
        .join('\n');

    final triggerKeyword = 'CREATE TRIGGER';
    final triggerStartIndex = cleanedSql.toUpperCase().indexOf(triggerKeyword);

    if (triggerStartIndex == -1) {
      final List<String> queries = cleanedSql.split(';');
      for (final query in queries) {
        if (query.trim().isNotEmpty) {
          await db.execute(query);
        }
      }
    } else {
      final statementsBeforeTrigger = cleanedSql.substring(
        0,
        triggerStartIndex,
      );
      final triggerStatement = cleanedSql.substring(triggerStartIndex);

      final List<String> queries = statementsBeforeTrigger.split(';');
      for (final query in queries) {
        if (query.trim().isNotEmpty) {
          await db.execute(query);
        }
      }

      if (triggerStatement.trim().isNotEmpty) {
        await db.execute(triggerStatement);
      }
    }
    await _seedDatabase(db);
  }

  //todo run in compute??
  Future<void> _seedDatabase(Database db) async {
    // Seed chapters
    final String chaptersContent = await rootBundle.loadString(
      'assets/resources/chapters.json',
    );
    final List<dynamic> chapters = json.decode(chaptersContent);
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final chapter in chapters) {
        batch.insert('chapters', chapter as Map<String, dynamic>);
      }
      await batch.commit(noResult: true);
    });

    final String content = await rootBundle.loadString(
      'assets/resources/chapter1_level.json',
    );
    final List<dynamic> levels = json.decode(content);

    await db.transaction((txn) async {
      int id = 0;
      for (final levelData in levels) {
        final levelMap = levelData as Map<String, dynamic>;

        List<String> wordsEn = safeFlatten(levelMap['words_en'] as List);
        List<String> wordsSn = safeFlatten(levelMap['words_sn'] as List);
        //(levelMap['words_sn'] as List).cast<String>();
        List<String> wordsNd = safeFlatten(levelMap['words_nd'] as List);
        // (levelMap['words_nd'] as List).cast<String>();

        final level = LevelModel(
          id: id,
          difficulty: 0,
          type: int.parse(levelMap['type']),
          wordsEn: wordsEn,
          wordsNd: wordsNd,
          wordsSn: wordsSn,
        );
        id++;
        final batch = txn.batch();
        batch.insert('levels', level.toMap());
        await batch.commit(noResult: true);
      }
    });
  }

  List<String> safeFlatten<String>(List<dynamic> list) {
    if (list.isEmpty) return [];

    if (list.first is List) {
      return list.expand((item) => item as List).cast<String>().toList();
    } else {
      return list.cast<String>().toList();
    }
  }
}
