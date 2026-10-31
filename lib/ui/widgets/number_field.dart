import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final ValueChanged<String>? onChanged;
  final IconData? icon;
  final String? suffix;
  final bool filled;

  const NumberField({super.key, required this.controller, required this.label, this.onChanged, this.icon, this.suffix, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩.,٫ ]')),
          _ThousandsFormatter(),
        ],
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon == null ? null : Icon(icon, size: 20),
          suffixText: suffix,
          filled: filled ? true : null,
          isDense: filled ? true : null,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _ThousandsFormatter extends TextInputFormatter {
  final _fmt = NumberFormat('#,###', 'en');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');
    if (digits.isEmpty) return newValue;
    final parts = digits.split('.');
    final whole = int.tryParse(parts[0]) ?? 0;
    final formatted = _fmt.format(whole) + (parts.length > 1 ? '.${parts[1]}' : '');
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
