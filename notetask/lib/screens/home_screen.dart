import 'package:flutter/material.dart';
import 'package:notetask/models/note.dart';
import 'package:notetask/models/category.dart';
import 'package:notetask/screens/note_edit_screen.dart';
import 'package:notetask/services/local_storage_service.dart';
import 'package:notetask/widgets/note_list_item.dart';
import 'package:notetask/widgets/reusable_drawer.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const HomeScreen({super.key, required this.onThemeChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocalStorageService _localStorageService = LocalStorageService();
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  bool _isSearching = false;

  // Mapeamento de categorias para ícones
  final Map<String, IconData> _categoryIcons = {
    'Trabalho': Icons.work,
    'Pessoal': Icons.person,
    'Estudo': Icons.school,
    'Compras': Icons.shopping_cart,
    'Saúde': Icons.local_hospital,
    // Adicione mais mapeamentos de categorias para ícones aqui
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final notes = await _localStorageService.getNotes();
    final categories = await _localStorageService.getCategories();

    notes.sort((a, b) {
      if (a.isTask && !a.isCompleted && (!b.isTask || b.isCompleted)) {
        return -1;
      }
      if (b.isTask && !b.isCompleted && (!a.isTask || b.isCompleted)) {
        return 1;
      }
      if (a.isTask && a.isCompleted && !b.isCompleted) {
        return 1;
      }
      if (b.isTask && b.isCompleted && !a.isCompleted) {
        return -1;
      }
      return 0;
    });

    setState(() {
      _notes = notes;
      _filteredNotes = notes;
      _categories = categories;
      _isLoading = false;
    });
  }

  void _openNoteEditScreen([Note? note]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteEditScreen(note: note)),
    );

    if (result != null && result is Note) {
      await _localStorageService.saveNote(result);
      _loadData();
    } else if (result == 'delete' && note != null) {
      await _localStorageService.deleteNote(note.id);
      _loadData();
    }
  }

  void _toggleTaskCompletion(Note note, bool? isCompleted) async {
    if (note.isTask) {
      note.isCompleted = isCompleted ?? false;
      await _localStorageService.saveNote(note);
      _loadData();
    }
  }

  void _filterNotes(String query) {
    final filteredNotes = _notes.where((note) {
      final contentLower = note.content.toLowerCase();
      final queryLower = query.toLowerCase();
      return contentLower.contains(queryLower);
    }).toList();

    setState(() {
      _filteredNotes = filteredNotes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final appBarColor = isLightMode ? Colors.white : Colors.black;
    final iconColor = isLightMode ? Colors.black : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                decoration: InputDecoration(
                  hintText: 'Pesquisar...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: iconColor.withOpacity(0.5)),
                ),
                onChanged: _filterNotes,
                autofocus: true,
                style: TextStyle(color: iconColor),
              )
            : const Text('NoteTask'),
        backgroundColor: appBarColor,
        foregroundColor: iconColor,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: iconColor,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _filteredNotes = _notes;
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.add, color: iconColor),
            onPressed: () => _openNoteEditScreen(),
          ),
        ],
      ),
      drawer: ReusableDrawer(onThemeChanged: widget.onThemeChanged),
      backgroundColor: appBarColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredNotes.isEmpty
          ? Center(
              child: Text(
                _isSearching
                    ? 'Nenhum resultado.'
                    : 'Nenhuma nota ou tarefa cadastrada.\nAdicione a primeira!',
                textAlign: TextAlign.center,
                style: TextStyle(color: iconColor.withOpacity(0.6)),
              ),
            )
          : ListView.builder(
              itemCount: _filteredNotes.length,
              itemBuilder: (context, index) {
                final note = _filteredNotes[index];
                final category = _categories.firstWhere(
                  (cat) => cat.id == note.categoryId,
                  orElse: () => Category(id: '0', name: 'Outros'),
                );
                final icon = _categoryIcons[category.name] ?? Icons.category;

                return Dismissible(
                  key: Key(note.id),
                  direction: DismissDirection.horizontal,
                  background: Container(
                    color: Colors.green,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.check, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      await _localStorageService.deleteNote(note.id);
                    } else if (direction == DismissDirection.startToEnd) {
                      if (note.isTask) {
                        _toggleTaskCompletion(note, true);
                      }
                    }
                    _loadData();
                  },
                  child: NoteListItem(
                    note: note,
                    categoryIcon: icon,
                    categoryName: category.name,
                    onTap: () => _openNoteEditScreen(note),
                    onToggleTask: (value) => _toggleTaskCompletion(note, value),
                  ),
                );
              },
            ),
    );
  }
}
