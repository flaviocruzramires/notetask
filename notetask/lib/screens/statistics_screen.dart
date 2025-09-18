import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:notetask/services/category_service.dart';
import 'package:notetask/services/note_service.dart';
import '../models/note.dart';
import '../models/category.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final NoteService _notesService = NoteService();
  final CategoryService _categoryService = CategoryService();
  bool _isLoading = true;
  List<Note> _allNotes = [];
  List<Category> _categories = [];
  Map<String, int> _notesByCategory = {};

  int _totalTasks = 0;
  int _completedTasks = 0;
  int _openTasks = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final notes = await _notesService.getNotes();
    final categories = await _categoryService.getCategories();

    final Map<String, int> notesByCategoryCount = {};
    for (var category in categories) {
      notesByCategoryCount[category.id] = 0;
    }
    for (var note in notes) {
      final categoryId = note.categoryId;
      if (categoryId != null && notesByCategoryCount.containsKey(categoryId)) {
        notesByCategoryCount[categoryId] =
            notesByCategoryCount[categoryId]! + 1;
      }
    }

    final tasks = notes.where((note) => note.isTask).toList();
    final completed = tasks.where((task) => task.isCompleted).length;
    final open = tasks.where((task) => !task.isCompleted).length;

    setState(() {
      _allNotes = notes;
      _categories = categories;
      _notesByCategory = notesByCategoryCount;
      _totalTasks = tasks.length;
      _completedTasks = completed;
      _openTasks = open;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estatísticas'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Visão Geral',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),

                  // AQUI ESTÁ A CORREÇÃO: Usando Wrap em vez de Row
                  _buildSummaryCards(colorScheme),

                  const SizedBox(height: 32),

                  Text(
                    'Distribuição por Categoria',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: _buildCategoryPieChartSections(colorScheme),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryLegend(colorScheme),

                  const SizedBox(height: 32),

                  Text(
                    'Conclusão de Tarefas',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  if (_totalTasks > 0)
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: _buildTaskCompletionSections(colorScheme),
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    )
                  else
                    const Text('Nenhuma tarefa cadastrada para análise.'),

                  const SizedBox(height: 16),
                  _buildTaskCompletionLegend(colorScheme),

                  const SizedBox(height: 32),

                  Text(
                    'Tarefas Recentes',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ..._allNotes
                      .where((note) => note.isTask && note.isCompleted)
                      .take(5)
                      .map(
                        (note) => ListTile(
                          leading: Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          title: Text(
                            note.content,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCards(ColorScheme colorScheme) {
    // CORREÇÃO: Usando Wrap para quebrar a linha se a tela for pequena
    return Wrap(
      spacing: 8.0, // Espaço horizontal entre os cards
      runSpacing: 8.0, // Espaço vertical entre as linhas de cards
      alignment: WrapAlignment.spaceAround,
      children: [
        _buildSummaryCard(
          title: 'Notas Totais',
          value: _allNotes.length.toString(),
          icon: Icons.notes,
          color: colorScheme.primary,
        ),
        _buildSummaryCard(
          title: 'Abertas',
          value: _openTasks.toString(),
          icon: Icons.task_alt,
          color: Colors.orange,
        ),
        _buildSummaryCard(
          title: 'Concluídas',
          value: _completedTasks.toString(),
          icon: Icons.check_circle_outline,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildCategoryPieChartSections(
    ColorScheme colorScheme,
  ) {
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    int colorIndex = 0;

    return _categories.map((category) {
      final count = _notesByCategory[category.id] ?? 0;
      if (count == 0) return PieChartSectionData(showTitle: false, value: 0);

      final color = colors[colorIndex % colors.length];
      colorIndex++;

      return PieChartSectionData(
        color: color,
        value: count.toDouble(),
        title: count.toString(),
        radius: 60,
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimary,
        ),
      );
    }).toList();
  }

  Widget _buildCategoryLegend(ColorScheme colorScheme) {
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    int colorIndex = 0;

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: _categories
          .where((cat) => (_notesByCategory[cat.id] ?? 0) > 0)
          .map((category) {
            final count = _notesByCategory[category.id] ?? 0;
            final percentage = _allNotes.isEmpty
                ? 0
                : (count / _allNotes.length) * 100;
            final color = colors[colorIndex % colors.length];
            colorIndex++;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${category.name} ($count - ${percentage.toStringAsFixed(1)}%)',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ],
            );
          })
          .toList(),
    );
  }

  List<PieChartSectionData> _buildTaskCompletionSections(
    ColorScheme colorScheme,
  ) {
    final openPercentage = _totalTasks > 0
        ? (_openTasks / _totalTasks) * 100
        : 0.0;
    final completedPercentage = _totalTasks > 0
        ? (_completedTasks / _totalTasks) * 100
        : 0.0;

    return [
      PieChartSectionData(
        color: Colors.green,
        value: completedPercentage,
        title: '${completedPercentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimary,
        ),
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: openPercentage,
        title: '${openPercentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimary,
        ),
      ),
    ];
  }

  Widget _buildTaskCompletionLegend(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem(
          label: 'Concluídas',
          color: Colors.green,
          value: '$_completedTasks',
        ),
        _buildLegendItem(
          label: 'Em Aberto',
          color: Colors.orange,
          value: '$_openTasks',
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required String label,
    required Color color,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text('$label ($value)', style: TextStyle(color: colorScheme.onSurface)),
      ],
    );
  }
}
