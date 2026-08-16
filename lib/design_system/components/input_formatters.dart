import 'package:flutter/services.dart';

class HouselyHomeCodeFormatter extends TextInputFormatter {
  const HouselyHomeCodeFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var value = newValue.text
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]'), '');

    if (value.length > 10) {
      value = value.substring(0, 10);
    }

    String formatted;

    if (value.length <= 4) {
      formatted = value;
    } else {
      formatted =
          '${value.substring(0, 4)}-${value.substring(4)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length,
      ),
    );
  }
}

class HouselyUkPostcodeFormatter extends TextInputFormatter {
  const HouselyUkPostcodeFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var value = newValue.text
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]'), '');

    if (value.length > 7) {
      value = value.substring(0, 7);
    }

    if (value.length <= 3) {
      return TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(
          offset: value.length,
        ),
      );
    }

    final outward =
        value.substring(0, value.length - 3);

    final inward =
        value.substring(value.length - 3);

    final formatted = '$outward $inward';

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length,
      ),
    );
  }
}

class HouselyUkPhoneFormatter extends TextInputFormatter {
  const HouselyUkPhoneFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits =
        newValue.text.replaceAll(RegExp(r'\D'), '');

    // User may paste 07700...
    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }

    // User may paste +44 / 44.
    if (digits.startsWith('44')) {
      digits = digits.substring(2);
    }

    if (digits.length > 10) {
      digits = digits.substring(0, 10);
    }

    String formatted = digits;

    if (digits.length > 4) {
      formatted =
          '${digits.substring(0, 4)} ${digits.substring(4)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length,
      ),
    );
  }
}