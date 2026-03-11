import 'package:flutter/material.dart';

class SnackBarWidget {
  static void primary(BuildContext context, String text) {
    _show(context, text, color: Colors.blue.shade600);
  }

  static void success(BuildContext context, String text) {
    _show(context, text, color: Colors.green.shade500);
  }

  static void warning(BuildContext context, String text) {
    _show(context, text, color: Colors.orange.shade600);
  }

  static void error(BuildContext context, String text) {
    _show(context, text, color: Colors.red.shade500);
  }

  static void _show(BuildContext context, String text, {required Color color}) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        content: Row(
          children: [
            const SizedBox(width: 10),
            Expanded(
              child: Text(text, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
