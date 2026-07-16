import 'package:flutter/services.dart';

class NoSpaceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Check if the new value contains any spaces
    if (newValue.text.contains(' ')) {
      // If it does, return the old value
      return oldValue;
    }
    // Otherwise, return the new value
    return newValue;
  }
}

class NumberValidator extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String extractedText = extractNumbers(newValue.text);
    return TextEditingValue(
      text: extractedText,
      selection: TextSelection.collapsed(offset: extractedText.length),
    );
  }
}

String extractNumbers(String str) {
  String result = '';
  for (int i = 0; i < str.length; i++) {
    if (str[i].contains(RegExp(r'[0-9]'))) {
      result += str[i];
    }
  }
  return result;
}

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: smallerAllWordsInFullSentence(newValue.text),
      // text: capitalizeAllWordsInFullSentence(newValue.text),
      selection: newValue.selection,
    );
  }
}

String smallerAllWordsInFullSentence(String str) {
  int i;
  String constructedString = "";
  for (i = 0; i < str.length; i++) {
    if (i == 0) {
      constructedString += str[0].toLowerCase();
    } else if (str[i - 1] == ' ') {
      // mandatory to have index>1 !
      constructedString += str[i].toLowerCase();
    } else {
      constructedString += str[i];
    }
  }
  // print('constructed: $constructedString');
  return constructedString;
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: capitalizeAllWordsInFullSentence(newValue.text),
      // text: capitalizeAllWordsInFullSentence(newValue.text),
      selection: newValue.selection,
    );
  }
}

String capitalizeAllWordsInFullSentence(String str) {
  int i;
  String constructedString = "";
  for (i = 0; i < str.length; i++) {
    if (i == 0) {
      constructedString += str[0].toUpperCase();
    } else if (str[i - 1] == ' ') {
      // mandatory to have index>1 !
      constructedString += str[i].toUpperCase();
    } else {
      constructedString += str[i];
    }
  }
  // print('constructed: $constructedString');
  return constructedString;
}

class CNICInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    // Remove all non-digit characters
    newText = newText.replaceAll(RegExp(r'\D'), '');

    // Insert hyphens at the correct positions
    if (newText.length > 5) {
      newText = '${newText.substring(0, 5)}-${newText.substring(5)}';
    }
    if (newText.length > 13) {
      newText = '${newText.substring(0, 13)}-${newText.substring(13)}';
    }

    // Truncate to maximum length of 15 characters (13 digits + 2 hyphens)
    if (newText.length > 15) {
      newText = newText.substring(0, 15);
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class DynamicLengthFormatter extends TextInputFormatter {
  final int maxLengthFor0;
  final int maxLengthFor9;

  DynamicLengthFormatter(
      {required this.maxLengthFor0, required this.maxLengthFor9});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.startsWith('0') && newValue.text.length > maxLengthFor0) {
      return oldValue;
    } else if (newValue.text.startsWith('9') &&
        newValue.text.length > maxLengthFor9) {
      return oldValue;
    }
    return newValue;
  }
}
