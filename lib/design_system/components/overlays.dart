import 'package:flutter/material.dart';

import '../theme/housely_tokens.dart';
import 'buttons.dart';
import 'record_rows.dart';

class HouselyStickyAction extends StatelessWidget {
  const HouselyStickyAction({
    required this.label,
    required this.onPressed,
    this.secondaryLabel,
    this.onSecondary,
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.fromLTRB(
        HouselySpace.lg,
        HouselySpace.sm,
        HouselySpace.lg,
        HouselySpace.sm,
      ),
      decoration: const BoxDecoration(
        color: HouselyPalette.surfaceRaised,
        border: Border(top: BorderSide(color: HouselyPalette.divider)),
      ),
      child: Row(
        children: [
          if (secondaryLabel != null) ...[
            Expanded(
              child: HouselyButton(
                label: secondaryLabel!,
                style: HouselyButtonStyle.secondary,
                onPressed: onSecondary,
              ),
            ),
            const SizedBox(width: HouselySpace.sm),
          ],
          Expanded(
            child: HouselyButton(label: label, onPressed: onPressed),
          ),
        ],
      ),
    ),
  );
}

Future<bool?> showHouselyConfirmation(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) => showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    backgroundColor: HouselyPalette.surfaceRaised,
    title: Text(title),
    content: Text(message),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, true),
        style: TextButton.styleFrom(
          foregroundColor: destructive
              ? HouselyPalette.coral
              : HouselyPalette.violet,
        ),
        child: Text(confirmLabel),
      ),
    ],
  ),
);

Future<void> showHouselyDraftSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: HouselyPalette.surfaceRaised,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(HouselySpace.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Keep your changes?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: HouselySpace.xs),
            Text(
              'Your entered details can be saved for later.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: HouselySpace.xl),
            HouselyButton(
              label: 'Save draft',
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: HouselySpace.sm),
            HouselyButton(
              label: 'Continue editing',
              style: HouselyButtonStyle.secondary,
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: HouselySpace.sm),
            HouselyButton(
              label: 'Discard changes',
              style: HouselyButtonStyle.destructive,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );

Future<void> showHouselyMoreSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: HouselyPalette.surfaceRaised,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(
          HouselySpace.lg,
          0,
          HouselySpace.lg,
          HouselySpace.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'George Street Flat',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: HouselySpace.lg),
            HouselyGroupedList(
              children: [
                HouselyRecordRow(
                  title: 'Your household',
                  icon: Icons.people_outline_rounded,
                  onTap: () {},
                ),
                HouselyRecordRow(
                  title: 'Changes',
                  icon: Icons.compare_arrows_rounded,
                  onTap: () {},
                ),
                HouselyRecordRow(
                  title: 'Private groups',
                  icon: Icons.lock_outline_rounded,
                  onTap: () {},
                ),
                HouselyRecordRow(
                  title: 'Settings',
                  icon: Icons.settings_outlined,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
