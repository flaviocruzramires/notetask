import 'package:flutter/material.dart';

class TaskSchedulerFields extends StatefulWidget {
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final bool initialAddToCalendar;
  final bool initialSetAlarm;
  final ValueChanged<DateTime?> onDateSelected;
  final ValueChanged<TimeOfDay?> onTimeSelected;
  final ValueChanged<bool> onAddToCalendarChanged;
  final ValueChanged<bool> onSetAlarmChanged;

  const TaskSchedulerFields({
    super.key,
    this.initialDate,
    this.initialTime,
    this.initialAddToCalendar = false,
    this.initialSetAlarm = false,
    required this.onDateSelected,
    required this.onTimeSelected,
    required this.onAddToCalendarChanged,
    required this.onSetAlarmChanged,
  });

  @override
  State<TaskSchedulerFields> createState() => _TaskSchedulerFieldsState();
}

class _TaskSchedulerFieldsState extends State<TaskSchedulerFields> {
  late DateTime? _selectedDate;
  late TimeOfDay? _selectedTime;
  late bool _addToCalendar;
  late bool _addToAlarm;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedTime = widget.initialTime;
    _addToCalendar = widget.initialAddToCalendar;
    _addToAlarm = widget.initialSetAlarm;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        const SizedBox(height: 16),
        ListTile(
          title: Text(
            _selectedDate == null
                ? 'Selecione a Data'
                : 'Data: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          trailing: Icon(Icons.calendar_today, color: colorScheme.onSurface),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              setState(() => _selectedDate = date);
              widget.onDateSelected(date);
            }
          },
        ),
        ListTile(
          title: Text(
            _selectedTime == null
                ? 'Selecione a Hora'
                : 'Hora: ${_selectedTime!.format(context)}',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          trailing: Icon(Icons.access_time, color: colorScheme.onSurface),
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: _selectedTime ?? TimeOfDay.now(),
            );
            if (time != null) {
              setState(() => _selectedTime = time);
              widget.onTimeSelected(time);
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Checkbox(
                value: _addToCalendar,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _addToCalendar = value;
                    });
                    widget.onAddToCalendarChanged(value);
                  }
                },
                activeColor: colorScheme.onSurface,
                checkColor: Theme.of(context).scaffoldBackgroundColor,
              ),
              Text(
                'Adicionar ao Google Calendar',
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
