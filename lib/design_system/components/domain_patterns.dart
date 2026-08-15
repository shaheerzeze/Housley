import 'package:flutter/material.dart';

import '../theme/housely_tokens.dart';
import 'housely_components.dart';

class HouselyFilePreview extends StatelessWidget {
  const HouselyFilePreview({
    required this.title,
    required this.metadata,
    this.onOpen,
    super.key,
  });
  final String title;
  final String metadata;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) => Material(
    color: HouselyPalette.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(HouselyRadius.feature),
      side: const BorderSide(color: HouselyPalette.divider),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 132,
            color: HouselyPalette.surfaceRaised,
            child: const Icon(
              Icons.description_outlined,
              size: 48,
              color: HouselyPalette.textTertiary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(HouselySpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(metadata, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class HouselyChecklistCard extends StatelessWidget {
  const HouselyChecklistCard({
    required this.title,
    required this.completed,
    required this.total,
    required this.onTap,
    super.key,
  });
  final String title;
  final int completed;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final done = completed == total;
    return HouselyRecordCard(
      onTap: onTap,
      child: Row(
        children: [
          SizedBox.square(
            dimension: 48,
            child: CircularProgressIndicator(
              value: total == 0 ? 0 : completed / total,
              strokeWidth: 5,
              backgroundColor: HouselyPalette.surfacePressed,
              color: done ? HouselyPalette.mint : HouselyPalette.violet,
            ),
          ),
          const SizedBox(width: HouselySpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  done ? 'Complete' : '$completed of $total files',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

class HouselyRecordCard extends StatelessWidget {
  const HouselyRecordCard({
    required this.child,
    this.onTap,
    this.color,
    super.key,
  });
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) => Material(
    color: color ?? HouselyPalette.surface,
    elevation: 0,
    shadowColor: HouselyPalette.shadow,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(HouselyRadius.group),
      side: const BorderSide(color: HouselyPalette.divider),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(HouselySpace.md),
        child: child,
      ),
    ),
  );
}

class HouselyOwnershipEditor extends StatelessWidget {
  const HouselyOwnershipEditor({
    required this.owner,
    required this.value,
    required this.onChanged,
    super.key,
  });
  final String owner;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => HouselySurface(
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                owner,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              '${value.round()}%',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: 100,
          divisions: 20,
          label: '${value.round()}%',
          onChanged: onChanged,
        ),
      ],
    ),
  );
}
