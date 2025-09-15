import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/local_storage_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final LocalStorageService _localStorageService = LocalStorageService();
  List<Note> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotesAndCalculateStats();
  }

  Future<void> _loadNotesAndCalculateStats() async {
    final notes = await _localStorageService.getNotes();
    setState(() {
      _notes = notes;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Definindo as cores com base no tema atual
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final textColor = isLightMode ? Colors.black : Colors.white;

    // Calcular estatísticas
    final totalItems = _notes.length;
    final totalTasks = _notes.where((n) => n.isTask).length;
    final completedTasks = _notes.where((n) => n.isTask && n.isCompleted).length;
    final pendingTasks = totalTasks - completedTasks;
    final completionPercentage = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estatísticas'),
        backgroundColor: isLightMode ? Colors.white : Colors.black,
        foregroundColor: textColor,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatItem('Total de Itens:', '$totalItems'),
                  _buildStatItem('Total de Tarefas:', '$totalTasks'),
                  _buildStatItem('Tarefas Concluídas:', '$completedTasks'),
                  _buildStatItem('Tarefas Pendentes:', '$pendingTasks'),
                  const Divider(height: 30),
                  _buildStatItem(
                    'Taxa de Conclusão:',
                    '${completionPercentage.toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(String label, String value, {TextStyle? style}) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final textColor = isLightMode ? Colors.black : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 18, color: textColor),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ).merge(style),
          ),
        ],
      ),
    );
  }
}