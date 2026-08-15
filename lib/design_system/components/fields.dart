import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/housely_tokens.dart';
import 'component_state.dart';

enum HouselyFieldType { text, email, password, money, date, search }

class HouselyField extends StatefulWidget {
  const HouselyField({
    required this.label,
    this.hint,
    this.controller,
    this.type = HouselyFieldType.text,
    this.state = HouselyComponentState.idle,
    this.helperText,
    this.errorText,
    this.onChanged,
    this.onDateTap,
    super.key,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final HouselyFieldType type;
  final HouselyComponentState state;
  final String? helperText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onDateTap;

  @override
  State<HouselyField> createState() => _HouselyFieldState();
}

class _HouselyFieldState extends State<HouselyField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final isPassword = widget.type == HouselyFieldType.password;
    final isDisabled =
        widget.state == HouselyComponentState.disabled ||
        widget.state == HouselyComponentState.loading;
    final error = widget.state == HouselyComponentState.error
        ? widget.errorText ?? 'Check this value and try again.'
        : null;

    return TextField(
      controller: widget.controller,
      enabled: !isDisabled,
      readOnly: widget.type == HouselyFieldType.date,
      onTap: widget.type == HouselyFieldType.date ? widget.onDateTap : null,
      onChanged: widget.onChanged,
      obscureText: isPassword && _obscure,
      autocorrect: widget.type == HouselyFieldType.text,
      enableSuggestions: !isPassword,
      keyboardType: _keyboardType,
      textInputAction: widget.type == HouselyFieldType.search
          ? TextInputAction.search
          : TextInputAction.next,
      autofillHints: switch (widget.type) {
        HouselyFieldType.email => const [AutofillHints.email],
        HouselyFieldType.password => const [AutofillHints.password],
        _ => null,
      },
      inputFormatters: widget.type == HouselyFieldType.money
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
          : null,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        helperText: widget.state == HouselyComponentState.success
            ? widget.helperText ?? 'Looks good'
            : widget.helperText,
        helperStyle: widget.state == HouselyComponentState.success
            ? const TextStyle(color: HouselyPalette.mint)
            : null,
        errorText: error,
        prefixIcon: _prefix,
        suffixIcon: _suffix(isPassword),
      ),
    );
  }

  TextInputType get _keyboardType => switch (widget.type) {
    HouselyFieldType.email => TextInputType.emailAddress,
    HouselyFieldType.money => const TextInputType.numberWithOptions(
      decimal: true,
    ),
    HouselyFieldType.date => TextInputType.datetime,
    _ => TextInputType.text,
  };

  Widget? get _prefix => switch (widget.type) {
    HouselyFieldType.money => const Center(
      widthFactor: 1,
      child: Text('£', style: TextStyle(fontWeight: FontWeight.w500)),
    ),
    HouselyFieldType.search => const Icon(Icons.search_rounded),
    HouselyFieldType.date => const Icon(Icons.calendar_today_outlined),
    HouselyFieldType.email => const Icon(Icons.mail_outline_rounded),
    _ => null,
  };

  Widget? _suffix(bool isPassword) {
    if (widget.state == HouselyComponentState.loading) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (widget.state == HouselyComponentState.success) {
      return const Icon(Icons.check_circle_outline, color: HouselyPalette.mint);
    }
    if (!isPassword) return null;
    return IconButton(
      tooltip: _obscure ? 'Show password' : 'Hide password',
      onPressed: () => setState(() => _obscure = !_obscure),
      icon: Icon(
        _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      ),
    );
  }
}
