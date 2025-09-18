// lib/models/category.dart

import 'package:flutter/material.dart';
import 'package:notetask/utils/app_icons.dart';

class Category {
  final String id;
  String name;
  final int iconCodePoint;
  final String iconFontFamily;

  Category({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.iconFontFamily,
  });

  // Construtor para criar um objeto Category a partir de um JSON (mapa do banco de dados)
  factory Category.fromJson(Map<String, dynamic> json) {
    // Definindo um ícone padrão para categorias antigas
    const defaultIcon = Icons.folder;

    return Category(
      id: json['id'],
      name: json['name'],
      // Corrigindo o erro de 'Null is not a subtype of int'
      iconCodePoint: (json['iconCodePoint'] ?? defaultIcon.codePoint) as int,
      iconFontFamily:
          (json['iconFontFamily'] ?? defaultIcon.fontFamily) as String,
    );
  }

  // Método para converter o objeto Category para um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': iconCodePoint,
      'iconFontFamily': iconFontFamily,
    };
  }

  IconData get icon {
    return appIcons[iconCodePoint] ?? Icons.category;
  }
}
