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
    final String wordsContent =
        await rootBundle.loadString('assets/resources/words.json');
    final Map<String, dynamic> wordsData = json.decode(wordsContent);
    final Map<String, dynamic> wordCategories = wordsData['words'];

    await db.transaction((txn) async {
      int levelId = 0;
      const levelType = 1; // Assuming 1 represents a game type like word search
      final batch = txn.batch();

      for (final category in wordCategories.keys) {
        final List<dynamic> words = wordCategories[category];
        final int totalWords = words.length;
        final int wordsPerLevel = (totalWords / 3).ceil();

        for (int i = 0; i < 3; i++) {
          final int start = i * wordsPerLevel;
          if (start >= totalWords) {
            continue;
          }

          final int end = (start + wordsPerLevel > totalWords)
              ? totalWords
              : start + wordsPerLevel;
          final List<dynamic> levelWords = words.sublist(start, end);

          if (levelWords.isEmpty) {
            continue;
          }

          final List<String> wordsEn =
              levelWords.map((w) => w['en'] as String).toList();
          final List<String> wordsSn =
              levelWords.map((w) => w['sn'] as String).toList();
          final List<String> wordsNd =
              levelWords.map((w) => w['nd'] as String).toList();

          final level = LevelModel(
            id: levelId,
            difficulty: i, // 0, 1, 2
            type: levelType,
            wordsEn: wordsEn,
            wordsNd: wordsNd,
            wordsSn: wordsSn,
          );

          batch.insert('levels', level.toMap());
          levelId++;
        }
      }
      await batch.commit(noResult: true);
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
