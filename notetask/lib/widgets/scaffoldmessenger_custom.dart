import 'package:flutter/material.dart';

class ScaffoldMessengerCustom {
  static void showSnackBar(
    String message,
    GlobalKey<ScaffoldMessengerState> navigatorKey,
  ) {
    ScaffoldMessenger.of(
      navigatorKey.currentContext!,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
  