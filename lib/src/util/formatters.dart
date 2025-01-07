// formatted_fields.dart
import 'package:flutter/services.dart';

class FormattedFields {
  // Phone Number Formatter
  static List<TextInputFormatter> phoneFormatters = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(10),
    _PhoneNumberFormatter(),
  ];

  // Name Formatter
  static List<TextInputFormatter> nameFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
    TextInputFormatter.withFunction((oldValue, newValue) {
      // Capitalize first letter of each word
      if (newValue.text.isEmpty) return newValue;
      return TextEditingValue(
        text: newValue.text.split(' ').map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        }).join(' '),
        selection: newValue.selection,
      );
    }),
  ];
}

// Custom Phone Number Formatter
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final formatted = StringBuffer();

    for (var i = 0; i < digitsOnly.length; i++) {
      if (i == 3 || i == 6) {
        formatted.write('-');
      }
      formatted.write(digitsOnly[i]);
    }

    return TextEditingValue(
      text: formatted.toString(),
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
