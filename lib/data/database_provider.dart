import 'dart:convert';

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
    final cleanedSql = sql.split('\n').where((line) => !line.trim().startsWith('--')).join('\n');

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
      final statementsBeforeTrigger = cleanedSql.substring(0, triggerStartIndex);
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

  Future<void> _seedDatabase(Database db) async {
    // Load words into a map for efficient lookup
    final List<Map<String, dynamic>> wordMaps = await db.query('words', columns: ['id', 'word']);
    final Map<String, int> wordIdMap = {
      for (var map in wordMaps) map['word'] as String: map['id'] as int
    };

    final String content = await rootBundle.loadString('assets/resources/proccessed_word_groups.json');
    final List<dynamic> levels = json.decode(content);

    await db.transaction((txn) async {
      for (final levelData in levels) {
        final List<dynamic> words = levelData;
        final String mainWord = words[0];
        
        int difficulty = 1;
        if (mainWord.length > 7) {
          difficulty = 2;
        }
        if (mainWord.length > 11) {
          difficulty = 3;
        }

        final levelId = await txn.insert('levels', {'difficulty': difficulty});

        for (var j = 0; j < words.length; j++) {
          final word = words[j] as String;
          final wordId = wordIdMap[word];
          if (wordId != null) {
            await txn.insert('level_words', {
              'level_id': levelId,
              'word_id': wordId,
              'display_order': j,
            });
          }
        }
      }
    });
  }
}