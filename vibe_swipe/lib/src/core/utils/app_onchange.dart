import 'dart:async';
import 'package:flutter/material.dart';

class AppOnchange {
  Timer? _timer;

  void removeSpaces(TextEditingController controller) {
    String text = controller.text;
    if (text.contains(' ')) {
      // Cancel any previous timer to avoid multiple triggers
      _timer?.cancel();

      // Start a new timer with a brief delay
      _timer = Timer(const Duration(milliseconds: 500), () {
        // Remove spaces and update text
        String newText = text.replaceAll(' ', '');
        controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.fromPosition(
            TextPosition(offset: newText.length),
          ),
        );
      });
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}
