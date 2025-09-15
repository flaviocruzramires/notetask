import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../models/category.dart';
import '../services/local_storage_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:http/http.dart' as http;
import 'dart:io';

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
  final LocalStorageService _localStorageService = LocalStorageService();
  bool _isTask = false;
  bool _isCompleted = false;
  String? _selectedCategoryId;
  List<Category> _categories = [];
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _addToCalendar = false;
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
    }
  }

  Future<void> _loadCategories() async {
    final categories = await _localStorageService.getCategories();
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
    );

    // Lógica para enviar o evento para o Google Calendar
    if (newNote.isTask &&
        newNote.addToCalendar &&
        newNote.scheduledDate != null) {
      await _addEventToCalendar(newNote.content, newNote.scheduledDate!);
    }

    // Devolve a nota para a tela anterior
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
          // AQUI ESTÁ A CORREÇÃO: O bloco de agendamento foi movido
          // para fora do Row e inserido diretamente no Column principal.
          if (_isTask)
            Column(
              children: [
                const SizedBox(height: 16),
                // Seletor de Data
                ListTile(
                  title: Text(
                    _selectedDate == null
                        ? 'Selecione a Data'
                        : 'Data: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => _selectedDate = date);
                    }
                  },
                ),
                // Seletor de Hora
                ListTile(
                  title: Text(
                    _selectedTime == null
                        ? 'Selecione a Hora'
                        : 'Hora: ${_selectedTime!.format(context)}',
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime ?? TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() => _selectedTime = time);
                    }
                  },
                ),
                // Checkbox para Calendar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _addToCalendar,
                        onChanged: (value) {
                          setState(() {
                            _addToCalendar = value ?? false;
                          });
                        },
                      ),
                      const Text('Adicionar ao Google Calendar'),
                    ],
                  ),
                ),
              ],
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
}
