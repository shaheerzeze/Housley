import 'package:flutter/material.dart';

import '../theme/housely_tokens.dart';
import 'buttons.dart';
import 'housely_components.dart';

class HouselyPulsePanel extends StatelessWidget {
  const HouselyPulsePanel({
    required this.child,
    this.baseColor = HouselyPalette.violetSoft,
    this.glowColor = HouselyPalette.apricot,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    super.key,
  });

  final Widget child;
  final Color baseColor;
  final Color glowColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: onTap != null,
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(HouselyRadius.feature),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(HouselyRadius.feature),
          gradient: RadialGradient(
            center: const Alignment(1.05, 1.15),
            radius: 1.15,
            colors: [glowColor, baseColor],
            stops: const [.02, .82],
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    ),
  );
}

class HouselyMetricCard extends StatelessWidget {
  const HouselyMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.iconColor,
    this.detail,
    super.key,
  });

  final String label;
  final String value;
  final String? detail;
  final IconData icon;
  final Color? color;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final tone = HouselyIconColors.resolve(icon);
    return Container(
      padding: const EdgeInsets.all(HouselySpace.md),
      decoration: BoxDecoration(
        color: color ?? tone.background,
        borderRadius: BorderRadius.circular(HouselyRadius.group),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor ?? tone.foreground),
          const SizedBox(height: HouselySpace.lg),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 3),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          if (detail != null) ...[
            const SizedBox(height: 2),
            Text(detail!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class HouselyBalanceSummary extends StatelessWidget {
  const HouselyBalanceSummary({
    required this.amount,
    required this.label,
    this.positive = true,
    super.key,
  });
  final String amount;
  final String label;
  final bool positive;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(HouselySpace.lg),
    decoration: BoxDecoration(
      color: positive ? HouselyPalette.mintSoft : HouselyPalette.coralSoft,
      borderRadius: BorderRadius.circular(HouselyRadius.feature),
      border: Border.all(color: Colors.transparent),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: HouselySpace.xs),
        Text(
          amount,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: positive ? HouselyPalette.mint : HouselyPalette.coral,
          ),
        ),
      ],
    ),
  );
}

class HouselyQuickAction extends StatelessWidget {
  const HouselyQuickAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.tint,
    this.iconColor,
    super.key,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? tint;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final tone = HouselyIconColors.resolve(icon);
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HouselyRadius.control),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 80),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: HouselySpace.sm),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: tint ?? tone.background,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: iconColor ?? tone.foreground,
                    ),
                  ),
                  const SizedBox(height: HouselySpace.xs),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: HouselyPalette.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum HouselyMessageKind { empty, error, offline, success }

class HouselyMessageState extends StatelessWidget {
  const HouselyMessageState({
    required this.title,
    required this.message,
    required this.kind,
    this.actionLabel,
    this.onAction,
    super.key,
  });
  final String title;
  final String message;
  final HouselyMessageKind kind;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (kind) {
      HouselyMessageKind.empty => (
        Icons.inbox_outlined,
        HouselyPalette.textSecondary,
      ),
      HouselyMessageKind.error => (
        Icons.error_outline_rounded,
        HouselyPalette.coral,
      ),
      HouselyMessageKind.offline => (
        Icons.cloud_off_outlined,
        HouselyPalette.textSecondary,
      ),
      HouselyMessageKind.success => (
        Icons.check_circle_outline_rounded,
        HouselyPalette.mint,
      ),
    };
    return Semantics(
      liveRegion:
          kind == HouselyMessageKind.error ||
          kind == HouselyMessageKind.success,
      child: HouselySurface(
        child: Column(
          children: [
            Icon(icon, size: 34, color: color),
            const SizedBox(height: HouselySpace.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: HouselySpace.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: HouselySpace.lg),
              HouselyButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}

class HouselyPrivacyNotice extends StatelessWidget {
  const HouselyPrivacyNotice({
    required this.title,
    required this.message,
    super.key,
  });
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(HouselySpace.md),
    decoration: BoxDecoration(
      color: HouselyPalette.violetSoft,
      borderRadius: BorderRadius.circular(HouselyRadius.group),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.lock_outline_rounded, color: HouselyPalette.violet),
        const SizedBox(width: HouselySpace.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(message, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    ),
  );
}

class HouselyValidationSummary extends StatelessWidget {
  const HouselyValidationSummary({required this.errors, super.key});
  final List<String> errors;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: '${errors.length} form errors',
    child: Container(
      padding: const EdgeInsets.all(HouselySpace.md),
      decoration: BoxDecoration(
        color: HouselyPalette.coralSoft,
        borderRadius: BorderRadius.circular(HouselyRadius.group),
        border: Border.all(color: HouselyPalette.coral),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Check these details',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: HouselyPalette.coral),
          ),
          const SizedBox(height: HouselySpace.xs),
          for (final error in errors)
            Text('• $error', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    ),
  );
}
