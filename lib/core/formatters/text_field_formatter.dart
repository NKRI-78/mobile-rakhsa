import 'package:flutter/services.dart';

class CapitalizeEachWordFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final original = newValue.text;
    final transformed = _capitalizeEachWord(original);

    if (transformed == original) return newValue;

    final baseOffset = newValue.selection.baseOffset.clamp(
      0,
      transformed.length,
    );
    final extentOffset = newValue.selection.extentOffset.clamp(
      0,
      transformed.length,
    );

    return TextEditingValue(
      text: transformed,
      selection: TextSelection(
        baseOffset: baseOffset,
        extentOffset: extentOffset,
      ),
      composing: TextRange.empty,
    );
  }

  String _capitalizeEachWord(String input) {
    if (input.isEmpty) return input;

    final buffer = StringBuffer();
    bool capitalizeNext = true;

    for (int i = 0; i < input.length; i++) {
      final ch = input[i];
      if (_isLetter(ch)) {
        if (capitalizeNext) {
          buffer.write(ch.toUpperCase());
        } else {
          buffer.write(ch.toLowerCase());
        }
        capitalizeNext = false;
      } else {
        if (ch == ' ' || ch == '-' || ch == '\'' || ch == '\u2019') {
          capitalizeNext = true;
        } else {
          capitalizeNext = false;
        }
        buffer.write(ch);
      }
    }

    return buffer.toString();
  }

  bool _isLetter(String ch) {
    if (ch.isEmpty) return false;
    final code = ch.codeUnitAt(0);
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: capitalize(newValue.text),
      selection: newValue.selection,
    );
  }
}

String capitalize(String value) {
  if (value.trim().isEmpty) return "";
  return value
      .split(' ')
      .map(
        (word) => word.isNotEmpty
            ? "${word[0].toUpperCase()}${word.substring(1).toLowerCase()}"
            : "",
      )
      .join(' ');
}

class PhoneNumberFormatter extends TextInputFormatter {
  static String unmask(String? text) {
    if (text == null) return '';
    return text.replaceAll(RegExp(r'[^0-9]'), '');
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digitsOnly = unmask(newValue.text);

    if (digitsOnly.length > 13) {
      digitsOnly = digitsOnly.substring(0, 13);
    }

    final buffer = StringBuffer();

    for (int i = 0; i < digitsOnly.length; i++) {
      buffer.write(digitsOnly[i]);

      final isFourth = (i + 1) % 4 == 0;
      final notLast = i + 1 != digitsOnly.length;
      if (isFourth && notLast) {
        buffer.write('-');
      }
    }

    final formatted = buffer.toString();

    int selectionIndex = formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
