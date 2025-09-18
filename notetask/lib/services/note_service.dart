import 'package:sqflite/sqflite.dart';
import 'package:notetask/models/note.dart';
import 'package:notetask/services/database_service.dart';

class NoteService {
  final DatabaseService _databaseService = DatabaseService();

  Future<void> saveNote(Note note) async {
    final db = await _databaseService.database;
    await db.insert(
      'notes',
      note.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Note>> getNotes() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('notes');
    return List.generate(maps.length, (i) {
      return Note.fromJson(maps[i]);
    });
  }

  Future<void> deleteNote(String id) async {
    final db = await _databaseService.database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
