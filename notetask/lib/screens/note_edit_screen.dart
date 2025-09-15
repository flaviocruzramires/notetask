import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../models/category.dart';
import '../services/local_storage_service.dart';

class NoteEditScreen extends StatefulWidget {
  final Note? note;

  const NoteEditScreen({super.key, this.note});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final TextEditingController _contentController = TextEditingController();
  final LocalStorageService _localStorageService = LocalStorageService();
  bool _isTask = false;
  bool _isCompleted = false;
  String? _selectedCategoryId;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.note != null) {
      _contentController.text = widget.note!.content;
      _isTask = widget.note!.isTask;
      _isCompleted = widget.note!.isCompleted;
      _selectedCategoryId = widget.note!.categoryId;
    }
  }

  Future<void> _loadCategories() async {
    final categories = await _localStorageService.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  void _saveNote() {
    if (_contentController.text.trim().isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    final newNote = Note(
      id: widget.note?.id ?? const Uuid().v4(),
      content: _contentController.text.trim(),
      isTask: _isTask,
      isCompleted: _isCompleted,
      categoryId: _selectedCategoryId, // Salva o ID da categoria
    );

    Navigator.of(context).pop(newNote);
  }

  void _confirmDeletion() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir Nota/Tarefa?'),
          content: const Text('Tem certeza que deseja excluir este item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteNote();
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  void _deleteNote() {
    Navigator.of(context).pop('delete');
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final iconColor = isLightMode ? Colors.black : Colors.white;
    final textColor = iconColor;
    final bgColor = isLightMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Nova Nota/Tarefa' : 'Editar'),
        backgroundColor: bgColor,
        foregroundColor: iconColor,
        elevation: 1,
        actions: [
          if (widget.note != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDeletion,
            ),
          IconButton(icon: const Icon(Icons.check), onPressed: _saveNote),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _isTask,
                      onChanged: (value) {
                        setState(() {
                          _isTask = value ?? false;
                          if (!_isTask) {
                            _isCompleted = false;
                          }
                        });
                      },
                      activeColor: iconColor,
                      checkColor: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    Text('É uma tarefa', style: TextStyle(color: textColor)),
                  ],
                ),
                if (_isTask)
                  Row(
                    children: [
                      Checkbox(
                        value: _isCompleted,
                        onChanged: (value) {
                          setState(() {
                            _isCompleted = value ?? false;
                          });
                        },
                        activeColor: iconColor,
                        checkColor: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      Text('Concluída', style: TextStyle(color: textColor)),
                    ],
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Categoria',
                labelStyle: TextStyle(color: textColor),
                border: const OutlineInputBorder(),
              ),
              dropdownColor: bgColor,
              style: TextStyle(color: textColor),
              value: _selectedCategoryId,
              items: _categories.map((category) {
                return obterDropdownMenuItem(category);
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _contentController,
                style: TextStyle(color: textColor),
                decoration: const InputDecoration(
                  hintText: 'Digite aqui sua nota ou tarefa...',
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                expands: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  DropdownMenuItem<String> obterDropdownMenuItem(Category category) {
    return DropdownMenuItem<String>(
      value: category!.id,
      child: Text(category.name),
    );
  }
}
