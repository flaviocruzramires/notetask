// lib/screens/category_screen.dart

import 'package:flutter/material.dart';
import 'package:notetask/models/category.dart';
import 'package:notetask/services/category_service.dart';
import 'package:uuid/uuid.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final CategoryService _categoryService = CategoryService();
  final TextEditingController _categoryController = TextEditingController();
  List<Category> _categories = [];
  String? _editingCategoryId;
  // Novo estado para o ícone selecionado
  IconData _selectedIcon = Icons.folder; // Ícone padrão

  // Lista de ícones disponíveis para escolha
  final List<IconData> _availableIcons = [
    Icons.folder,
    Icons.work,
    Icons.person,
    Icons.school,
    Icons.shopping_cart,
    Icons.local_hospital,
    Icons.fitness_center,
    Icons.lightbulb,
    Icons.emoji_objects,
    Icons.pets,
    Icons.restaurant,
    Icons.travel_explore,
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _categoryService.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  void _saveCategory() async {
    if (_categoryController.text.trim().isEmpty) return;

    if (_editingCategoryId != null) {
      final updatedCategory = Category(
        id: _editingCategoryId!,
        name: _categoryController.text.trim(),
        iconCodePoint: _selectedIcon.codePoint,
        iconFontFamily: _selectedIcon.fontFamily!,
      );
      await _categoryService.saveCategory(updatedCategory);
    } else {
      final newCategory = Category(
        id: const Uuid().v4(),
        name: _categoryController.text.trim(),
        iconCodePoint: _selectedIcon.codePoint,
        iconFontFamily: _selectedIcon.fontFamily!,
      );
      await _categoryService.saveCategory(newCategory);
    }

    _categoryController.clear();
    _editingCategoryId = null;
    _selectedIcon = Icons.folder; // Reseta para o ícone padrão
    _loadCategories();
  }

  void _editCategory(Category category) {
    setState(() {
      _editingCategoryId = category.id;
      _categoryController.text = category.name;
      _selectedIcon = category.icon;
    });
  }

  void _deleteCategory(String id) async {
    await _categoryService.deleteCategory(id);
    _loadCategories();
  }

  void _showIconPickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecione um Ícone'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 1,
            ),
            itemCount: _availableIcons.length,
            itemBuilder: (context, index) {
              final icon = _availableIcons[index];
              return IconButton(
                icon: Icon(icon, color: _selectedIcon == icon ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface),
                onPressed: () {
                  setState(() {
                    _selectedIcon = icon;
                  });
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Categorias'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                // Pré-visualização do ícone
                GestureDetector(
                  onTap: _showIconPickerDialog,
                  child: CircleAvatar(
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    child: Icon(_selectedIcon, color: colorScheme.primary),
                  ),
                ),
                const SizedBox(width: 16),
                // Campo de texto e botão de salvar
                Expanded(
                  child: TextField(
                    controller: _categoryController,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: _editingCategoryId != null
                          ? 'Editar categoria'
                          : 'Nova categoria',
                      labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send, color: colorScheme.onSurface),
                        onPressed: _saveCategory,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return Card(
                    color: colorScheme.background,
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      leading: Icon(category.icon, color: colorScheme.onBackground),
                      title: Text(
                        category.name,
                        style: TextStyle(color: colorScheme.onBackground),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: colorScheme.onBackground),
                            onPressed: () => _editCategory(category),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: colorScheme.error),
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