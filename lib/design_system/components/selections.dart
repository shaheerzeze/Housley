import 'package:flutter/material.dart';

import '../theme/housely_tokens.dart';

class HouselyCheckbox extends StatelessWidget {
  const HouselyCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
    this.supportingText,
    super.key,
  });

  final String label;
  final String? supportingText;
  final bool value;
  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) => CheckboxListTile(
    value: value,
    onChanged: onChanged,
    controlAffinity: ListTileControlAffinity.leading,
    contentPadding: EdgeInsets.zero,
    visualDensity: VisualDensity.standard,
    title: Text(label, style: Theme.of(context).textTheme.titleMedium),
    subtitle: supportingText == null
        ? null
        : Text(supportingText!, style: Theme.of(context).textTheme.bodyMedium),
  );
}

class HouselyRadio<T> extends StatelessWidget {
  const HouselyRadio({required this.label, required this.value, super.key});

  final String label;
  final T value;

  @override
  Widget build(BuildContext context) => RadioListTile<T>(
    value: value,
    contentPadding: EdgeInsets.zero,
    title: Text(label, style: Theme.of(context).textTheme.titleMedium),
  );
}

class HouselySelectionTile extends StatelessWidget {
  const HouselySelectionTile({
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.icon,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: title,
    child: Material(
      color: selected ? HouselyPalette.violetSoft : HouselyPalette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HouselyRadius.group),
        side: BorderSide(
          color: selected ? HouselyPalette.violet : HouselyPalette.divider,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.all(HouselySpace.md),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: selected ? HouselyPalette.violet : null),
                  const SizedBox(width: HouselySpace.sm),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: HouselySpace.xxs),
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: selected
                      ? HouselyPalette.violet
                      : HouselyPalette.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class HouselySegmentedControl<T> extends StatelessWidget {
  const HouselySegmentedControl({
    required this.segments,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final Map<T, String> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<T>(
    segments: segments.entries
        .map(
          (entry) =>
              ButtonSegment<T>(value: entry.key, label: Text(entry.value)),
        )
        .toList(),
    selected: {selected},
    onSelectionChanged: (selection) => onChanged(selection.first),
    showSelectedIcon: false,
    style: ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(0, HouselySize.minTouch)),
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? HouselyPalette.surfaceRaised
            : HouselyPalette.surface,
      ),
      foregroundColor: const WidgetStatePropertyAll(HouselyPalette.textPrimary),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
      ),
      side: const WidgetStatePropertyAll(
        BorderSide(color: HouselyPalette.divider),
      ),
    ),
  );
}

class HouselyFilterChip extends StatelessWidget {
  const HouselyFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.count,
    super.key,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final int? count;

  @override
  Widget build(BuildContext context) => FilterChip(
    label: Text(count == null ? label : '$label  $count'),
    selected: selected,
    onSelected: onSelected,
    showCheckmark: false,
    visualDensity: VisualDensity.standard,
    side: BorderSide(
      color: selected ? HouselyPalette.violet : HouselyPalette.divider,
    ),
    backgroundColor: HouselyPalette.surface,
    selectedColor: HouselyPalette.violetSoft,
    labelStyle: TextStyle(
      color: selected
          ? HouselyPalette.textPrimary
          : HouselyPalette.textSecondary,
      fontWeight: FontWeight.w500,
    ),
  );
}
