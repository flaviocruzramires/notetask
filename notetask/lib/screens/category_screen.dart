import 'package:flutter/material.dart';
import 'package:notetask/models/category.dart';
import 'package:notetask/services/local_storage_service.dart';
import 'package:uuid/uuid.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final LocalStorageService _localStorageService = LocalStorageService();
  final TextEditingController _categoryController = TextEditingController();
  List<Category> _categories = [];
  String? _editingCategoryId;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _localStorageService.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  void _saveCategory() async {
    if (_categoryController.text.trim().isEmpty) return;

    if (_editingCategoryId != null) {
      // Atualiza a categoria existente
      final updatedCategory = Category(
        id: _editingCategoryId!,
        name: _categoryController.text.trim(),
      );
      await _localStorageService.saveCategory(updatedCategory);
    } else {
      // Adiciona uma nova categoria
      final newCategory = Category(
        id: const Uuid().v4(),
        name: _categoryController.text.trim(),
      );
      await _localStorageService.saveCategory(newCategory);
    }

    _categoryController.clear();
    _editingCategoryId = null;
    _loadCategories();
  }

  void _editCategory(Category category) {
    setState(() {
      _editingCategoryId = category.id;
      _categoryController.text = category.name;
    });
  }

  void _deleteCategory(String id) async {
    await _localStorageService.deleteCategory(id);
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final iconColor = isLightMode ? Colors.black : Colors.white;
    final textColor = iconColor;
    final bgColor = isLightMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Categorias'),
        backgroundColor: bgColor,
        foregroundColor: iconColor,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _categoryController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: _editingCategoryId != null
                    ? 'Editar categoria'
                    : 'Nova categoria',
                labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send, color: iconColor),
                  onPressed: _saveCategory,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return Card(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      title: Text(
                        category.name,
                        style: TextStyle(color: textColor),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: iconColor),
                            onPressed: () => _editCategory(category),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteCategory(category.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
