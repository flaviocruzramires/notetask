import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:notetask/models/note.dart';
import 'package:notetask/models/category.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  static Database? _database;

  factory LocalStorageService() {
    return _instance;
  }

  LocalStorageService._internal();

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
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes(
            id TEXT PRIMARY KEY,
            content TEXT,
            isTask INTEGER,
            isCompleted INTEGER,
            categoryId TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE categories(
            id TEXT PRIMARY KEY,
            name TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE notes ADD COLUMN categoryId TEXT');
        }
      },
    );
  }

  // Métodos para Notas
  Future<void> saveNote(Note note) async {
    final db = await database;
    await db.insert(
      'notes',
      note.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Note>> getNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notes');
    return List.generate(maps.length, (i) {
      return Note.fromJson(maps[i]);
    });
  }

  Future<void> deleteNote(String id) async {
    final db = await database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // Métodos para Categorias
  Future<void> saveCategory(Category category) async {
    final db = await database;
    await db.insert(
      'categories',
      category.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) {
      return Category.fromJson(maps[i]);
    });
  }

  Future<void> deleteCategory(String id) async {
    final db = await database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // Métodos para Configurações (com shared_preferences)
  Future<bool> getPasswordProtection() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('password') != null;
  }

  Future<String?> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('password');
  }

  Future<void> savePassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('password', password);
  }

  Future<void> deletePassword() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('password');
  }

  Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLightMode') ?? true;
  }

  Future<void> saveThemeMode(bool isLightMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLightMode', isLightMode);
  }

  Future<void> setPasswordProtection(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    if (!isEnabled) {
      await prefs.remove('password');
    }
  }

  Future<void> setPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('password', password);
  }

  Future<void> setThemeMode(bool isLightMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLightMode', isLightMode);
  }
}
