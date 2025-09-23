import 'package:flutter/material.dart';

class TextFieldCustom extends StatelessWidget {
  final String hintText;
  final InputBorder border;
  final Function(String)? onChanged;
  final Icon? prefixIcon;
  final Icon? suffixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextEditingController? controller;
  final Color? borderColor; // Adicionando a nova propriedade

  const TextFieldCustom({
    Key? key,
    required this.hintText,
    required this.border,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.controller,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final modifiedBorder = border is OutlineInputBorder && borderColor != null
        ? (border as OutlineInputBorder).copyWith(
            borderSide: BorderSide(
              color: borderColor!,
              width: (border as OutlineInputBorder).borderSide.width,
            ),
          )
        : border;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        border: modifiedBorder,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
