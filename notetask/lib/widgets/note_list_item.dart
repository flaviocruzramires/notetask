// Em lib/widgets/note_list_item.dart

import 'package:flutter/material.dart';
import 'package:notetask/models/note.dart';

class NoteListItem extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final Function(bool?)? onToggleTask;
  final IconData? categoryIcon; // Adicionado
  final String? categoryName; // Adicionado

  const NoteListItem({
    super.key,
    required this.note,
    required this.onTap,
    this.onToggleTask,
    this.categoryIcon,
    this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final iconColor = isLightMode ? Colors.black : Colors.white;
    final textColor = iconColor;
    final isCompletedStyle = TextStyle(
      color: textColor.withOpacity(0.6),
      decoration: TextDecoration.lineThrough,
      fontStyle: FontStyle.italic,
    );

    return ListTile(
      onTap: onTap,
      title: Text(
        note.content,
        style: note.isCompleted
            ? isCompletedStyle
            : TextStyle(color: textColor),
      ),
      // leading: Icon(categoryIcon, size: 20, color: textColor.withOpacity(0.6)),
      subtitle: categoryName != null
          ? Row(
              children: [
                if (categoryIcon != null)
                  Icon(
                    categoryIcon,
                    size: 16,
                    color: textColor.withOpacity(0.6),
                  ),
                const SizedBox(width: 4),
                Text(
                  categoryName!,
                  style: TextStyle(color: textColor.withOpacity(0.6)),
                ),
              ],
            )
          : null,
      trailing: note.isTask
          ? Checkbox(
              value: note.isCompleted,
              onChanged: onToggleTask,
              activeColor: iconColor,
              checkColor: Theme.of(context).scaffoldBackgroundColor,
            )
          : null,
    );
  }
}
