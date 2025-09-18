// lib/services/category_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:notetask/models/category.dart';
import 'package:notetask/services/database_service.dart';

class CategoryService {
  final DatabaseService _databaseService = DatabaseService();

  Future<void> saveCategory(Category category) async {
    final db = await _databaseService.database;
    await db.insert(
      'categories',
      category.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Category>> getCategories() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) {
      return Category.fromJson(maps[i]);
    });
  }

  Future<void> deleteCategory(String id) async {
    final db = await _databaseService.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
