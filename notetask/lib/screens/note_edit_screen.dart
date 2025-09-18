import 'package:flutter/material.dart';
import 'package:notetask/services/category_service.dart';
import 'package:uuid/uuid.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:http/http.dart' as http;
import '../models/note.dart';
import '../models/category.dart';
import '../widgets/task_scheduler_fields.dart';

/// Classe para gerenciar a autenticação e o uso da API
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class NoteEditScreen extends StatefulWidget {
  final Note? note;

  const NoteEditScreen({super.key, this.note});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final TextEditingController _contentController = TextEditingController();
  final CategoryService _categoryService = CategoryService();
  bool _isTask = false;
  bool _isCompleted = false;
  String? _selectedCategoryId;
  List<Category> _categories = [];

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _addToCalendar = false;
  bool _setAlarm = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[calendar.CalendarApi.calendarScope],
  );

  @override
  void initState() {
    super.initState();
    _loadCategories();

    if (widget.note != null) {
      _contentController.text = widget.note!.content;
      _isTask = widget.note!.isTask;
      _isCompleted = widget.note!.isCompleted;
      _selectedCategoryId = widget.note!.categoryId;
      if (widget.note!.scheduledDate != null) {
        _selectedDate = widget.note!.scheduledDate;
        _selectedTime = TimeOfDay.fromDateTime(widget.note!.scheduledDate!);
      }
      _addToCalendar = widget.note!.addToCalendar;
      _setAlarm = widget.note!.setAlarm;
    }
  }

  Future<void> _loadCategories() async {
    final categories = await _categoryService.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  void _saveNote() async {
    if (_contentController.text.trim().isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    final newNote = Note(
      id: widget.note?.id ?? const Uuid().v4(),
      content: _contentController.text.trim(),
      isTask: _isTask,
      isCompleted: _isCompleted,
      categoryId: _selectedCategoryId,
      scheduledDate: _isTask && _selectedDate != null && _selectedTime != null
          ? DateTime(
              _selectedDate!.year,
              _selectedDate!.month,
              _selectedDate!.day,
              _selectedTime!.hour,
              _selectedTime!.minute,
            )
          : null,
      addToCalendar: _addToCalendar,
      setAlarm: _setAlarm,
    );

    if (newNote.isTask &&
        newNote.addToCalendar &&
        newNote.scheduledDate != null) {
      await _addEventToCalendar(newNote.content, newNote.scheduledDate!);
    }

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

  Future<void> _addEventToCalendar(String title, DateTime scheduledDate) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha na autenticação do Google.')),
        );
        return;
      }

      final authHeaders = await googleUser.authHeaders;
      final client = GoogleAuthClient(authHeaders);
      final calendarApi = calendar.CalendarApi(client);

      final event = calendar.Event(
        summary: title,
        start: calendar.EventDateTime(dateTime: scheduledDate),
        end: calendar.EventDateTime(
          dateTime: scheduledDate.add(const Duration(hours: 1)),
        ),
      );

      await calendarApi.events.insert(event, "primary");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento adicionado ao Google Calendar!')),
      );
    } catch (e) {
      print('Erro ao adicionar evento: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Erro: Não foi possível adicionar o evento ao calendário.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Nova Nota/Tarefa' : 'Editar'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
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
                            // Resetar os campos de agendamento ao desmarcar 'É uma tarefa'
                            _selectedDate = null;
                            _selectedTime = null;
                            _addToCalendar = false;
                            _setAlarm = false;
                          }
                        });
                      },
                      activeColor: colorScheme.onSurface,
                      checkColor: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    Text(
                      'É uma tarefa',
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
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
                        activeColor: colorScheme.onSurface,
                        checkColor: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      Text(
                        'Concluída',
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // O novo widget TaskSchedulerFields é inserido aqui
          if (_isTask)
            TaskSchedulerFields(
              initialDate: _selectedDate,
              initialTime: _selectedTime,
              initialAddToCalendar: _addToCalendar,
              initialSetAlarm: _setAlarm,
              onDateSelected: (date) {
                setState(() => _selectedDate = date);
              },
              onTimeSelected: (time) {
                setState(() => _selectedTime = time);
              },
              onAddToCalendarChanged: (bool value) {},
              onSetAlarmChanged: (bool value) {},
            ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Categoria',
                labelStyle: TextStyle(color: colorScheme.onSurface),
                border: const OutlineInputBorder(),
              ),
              dropdownColor: colorScheme.surface,
              style: TextStyle(color: colorScheme.onSurface),
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

                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Digite aqui sua nota ou tarefa...',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                  enabledBorder: const UnderlineInputBorder(),
                  focusedBorder: const UnderlineInputBorder(),
                  border: const UnderlineInputBorder(),
                  filled: true,
                  fillColor: colorScheme.surface,
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
    final colorScheme = Theme.of(context).colorScheme;
    return DropdownMenuItem<String>(
      value: category.id,
      child: Text(
        category.name,
        style: TextStyle(color: colorScheme.onSurface),
      ),
    );
  }
}
