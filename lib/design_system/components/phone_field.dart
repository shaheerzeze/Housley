import 'package:flutter/material.dart';

import '../theme/housely_tokens.dart';
import 'input_formatters.dart';

class HouselyPhoneField extends StatelessWidget {
  const HouselyPhoneField({
    required this.controller,
    this.label = 'Phone number',
    this.errorText,
    this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),

        const SizedBox(height: HouselySpace.xs),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: HouselySpace.md),
              decoration: BoxDecoration(
                border: Border.all(color: HouselyPalette.divider),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Row(
                  children: [
                    Text('🇬🇧'),
                    SizedBox(width: 8),
                    Text('+44', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),

            const SizedBox(width: HouselySpace.sm),

            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                autofillHints: const [AutofillHints.telephoneNumberNational],
                inputFormatters: const [HouselyUkPhoneFormatter()],
                decoration: InputDecoration(
                  hintText: '7700 900123',
                  errorText: errorText,
                ),
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
