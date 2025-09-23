import 'package:flutter/material.dart';
import 'package:notetask/models/note.dart';
import 'package:notetask/models/category.dart';
import 'package:notetask/screens/note_edit_screen.dart';
import 'package:notetask/screens/ai_chat_screen.dart';
import 'package:notetask/services/note_service.dart';
import 'package:notetask/services/category_service.dart';
import 'package:notetask/utils/app_const.dart';
import 'package:notetask/widgets/note_list_item.dart';
import 'package:notetask/widgets/reusable_drawer.dart';
import 'package:notetask/widgets/text_field_custom.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const HomeScreen({super.key, required this.onThemeChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NoteService _noteService = NoteService();
  final CategoryService _categoryService = CategoryService();

  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  bool _isSearching = false;

  @override
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final notes = await _noteService.getNotes();
    final categories = await _categoryService.getCategories();

    final activeNotes = notes.where((note) => !note.isArchived).toList();

    activeNotes.sort((a, b) {
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
      _notes = activeNotes;
      _filteredNotes = activeNotes;
      _categories = categories;
      _isLoading = false;
    });
  }

  void _openNoteEditScreen([Note? note]) async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NoteEditScreen(note: note)),
      );

      if (result != null && result is Note) {
        await _noteService.saveNote(result);
      } else if (result == 'delete' && note != null) {
        await _noteService.deleteNote(note.id);
      }
    } finally {
      _loadData();
    }
  }

  void _toggleTaskCompletion(Note note, bool? isCompleted) async {
    if (note.isTask) {
      note.isCompleted = isCompleted ?? false;
      await _noteService.saveNote(note);
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
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: obterAppBar(context, colorScheme),
      drawer: ReusableDrawer(onThemeChanged: widget.onThemeChanged),
      backgroundColor: colorScheme.surface,
      body: obterBody(context, colorScheme),
    );
  }

  obterAppBar(BuildContext context, dynamic colorScheme) {
    return AppBar(
      title: _isSearching
          ? TextFieldCustom(
              hintText: AppConst.searchHint,
              border: UnderlineInputBorder(borderSide: BorderSide.none),
              onChanged: _filterNotes,
              borderColor: colorScheme.onSurface.withOpacity(0.5),
            )
          : const Text(AppConst.appName),
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 1,
      actions: [
        IconButton(
          icon: Icon(
            _isSearching ? Icons.close : Icons.search,
            color: colorScheme.onSurface,
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
          icon: Icon(Icons.add, color: colorScheme.onSurface),
          onPressed: () => _openNoteEditScreen(),
        ),
      ],
    );
  }

  obterBody(BuildContext context, dynamic colorScheme) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _filteredNotes.isEmpty
        ? viewMessageWithOutNoteAndTask(colorScheme)
        : obterListView();
  }

  Center viewMessageWithOutNoteAndTask(dynamic colorScheme) {
    return Center(
      child: Text(
        _isSearching
            ? AppConst.noResults
            : 'Nenhuma nota ou tarefa cadastrada.\nAdicione a primeira!',
        textAlign: TextAlign.center,
        style: TextStyle(color: colorScheme.onBackground.withOpacity(0.6)),
      ),
    );
  }

  obterListView() {
    return ListView.builder(
      itemCount: _filteredNotes.length,
      itemBuilder: (context, index) {
        final note = _filteredNotes[index];
        final category = _categories.firstWhere(
          (cat) => cat.id == note.categoryId,
          orElse: () => Category(
            id: '0',
            name: 'Outros',
            iconCodePoint: Icons.category.codePoint,
            iconFontFamily: Icons.category.fontFamily!,
          ),
        );

        final icon = category.icon;

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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.forum, color: Colors.white),
                const SizedBox(width: 8),
                Icon(Icons.delete, color: Colors.white),
              ],
            ),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              final action = await showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  return montaAlertDialog();
                },
              );
              if (action == 'chat') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AiChatScreen(initialQuery: note.content),
                  ),
                );
                return false;
              } else if (action == 'delete') {
                return true;
              }
              return false;
            }
            return false;
          },
          onDismissed: (direction) async {
            if (direction == DismissDirection.endToStart) {
              await _noteService.deleteNote(note.id);
              _loadData();
            } else if (direction == DismissDirection.startToEnd) {
              if (note.isTask) {
                _toggleTaskCompletion(note, true);
              }
            }
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
    );
  }
}

class montaAlertDialog extends StatelessWidget {
  const montaAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecione uma ação'),
      content: const Text('O que você deseja fazer com esta tarefa?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop('chat'),
          child: const Text('Pesquisar com IA'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop('delete'),
          child: const Text('Excluir'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop('cancel'),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
