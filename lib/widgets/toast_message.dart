import 'package:flutter/material.dart';

class ToastMessage {
  static void show(BuildContext context, String message, {bool success = true}) {
    final color = success ? Colors.green : Colors.red;

    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}