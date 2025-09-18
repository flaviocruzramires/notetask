// lib/services/database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = path.join(documentsDirectory.path, 'notes.db');

    return openDatabase(
      dbPath,
      version: 6, // VERSÃO ATUALIZADA PARA 6
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes(
            id TEXT PRIMARY KEY,
            content TEXT,
            isTask INTEGER,
            isCompleted INTEGER,
            categoryId TEXT,
            scheduledDate TEXT,
            addToCalendar INTEGER,
            setAlarm INTEGER,
            isArchived INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE categories(
            id TEXT PRIMARY KEY,
            name TEXT,
            iconCodePoint INTEGER,
            iconFontFamily TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE notes ADD COLUMN categoryId TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE notes ADD COLUMN scheduledDate TEXT');
        }
        // AQUI ESTÁ A CORREÇÃO: Adicionando a coluna `setAlarm`
        if (oldVersion < 4) {
          await db.execute(
            'ALTER TABLE notes ADD COLUMN setAlarm INTEGER DEFAULT 0',
          );
        }
        if (oldVersion < 5) {
          await db.execute(
            'ALTER TABLE categories ADD COLUMN iconCodePoint INTEGER',
          );
          await db.execute(
            'ALTER TABLE categories ADD COLUMN iconFontFamily TEXT',
          );
        }
        if (oldVersion < 6) {
          await db.execute(
            'ALTER TABLE notes ADD COLUMN isArchived INTEGER DEFAULT 0',
          );
        }
      },
    );
  }
}
