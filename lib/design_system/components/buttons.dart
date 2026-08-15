import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/housely_tokens.dart';
import 'component_state.dart';

enum HouselyButtonStyle { primary, secondary, text, destructive }

class HouselyButton extends StatelessWidget {
  const HouselyButton({
    required this.label,
    required this.onPressed,
    this.style = HouselyButtonStyle.primary,
    this.state = HouselyComponentState.idle,
    this.leadingIcon,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final HouselyButtonStyle style;
  final HouselyComponentState state;
  final IconData? leadingIcon;
  final bool expand;

  bool get _disabled =>
      state == HouselyComponentState.disabled ||
      state == HouselyComponentState.loading ||
      onPressed == null;

  void _handlePress() {
    if (style == HouselyButtonStyle.destructive) HapticFeedback.mediumImpact();
    onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final foreground = switch (style) {
      HouselyButtonStyle.primary => HouselyPalette.onAccent,
      HouselyButtonStyle.secondary => HouselyPalette.textPrimary,
      HouselyButtonStyle.text => HouselyPalette.violet,
      HouselyButtonStyle.destructive => HouselyPalette.coral,
    };
    final background = switch (style) {
      HouselyButtonStyle.primary => HouselyPalette.violet,
      HouselyButtonStyle.secondary => HouselyPalette.surfaceRaised,
      HouselyButtonStyle.text => Colors.transparent,
      HouselyButtonStyle.destructive => HouselyPalette.coralSoft,
    };
    final border = Colors.transparent;

    final effectiveForeground = switch (state) {
      HouselyComponentState.success => HouselyPalette.mint,
      HouselyComponentState.error => HouselyPalette.coral,
      _ => foreground,
    };

    final child = AnimatedSwitcher(
      duration: HouselyMotion.quick,
      child: switch (state) {
        HouselyComponentState.loading => SizedBox.square(
          key: const ValueKey('loading'),
          dimension: 19,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: effectiveForeground,
          ),
        ),
        HouselyComponentState.success => _ButtonLabel(
          key: const ValueKey('success'),
          icon: Icons.check_rounded,
          label: label,
        ),
        HouselyComponentState.error => _ButtonLabel(
          key: const ValueKey('error'),
          icon: Icons.error_outline_rounded,
          label: label,
        ),
        _ => _ButtonLabel(
          key: const ValueKey('label'),
          icon: leadingIcon,
          label: label,
        ),
      },
    );

    final button = Semantics(
      button: true,
      enabled: !_disabled,
      label: state == HouselyComponentState.loading ? '$label, loading' : label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: TextButton(
          onPressed: _disabled ? null : _handlePress,
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(effectiveForeground),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return background.withValues(alpha: .42);
              }
              if (states.contains(WidgetState.pressed)) {
                return Color.alphaBlend(
                  HouselyPalette.onAccent.withValues(alpha: .08),
                  background,
                );
              }
              return background;
            }),
            overlayColor: const WidgetStatePropertyAll(
              HouselyPalette.onAccentOverlay,
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(HouselyRadius.control),
                side: BorderSide(color: border),
              ),
            ),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: HouselySpace.md),
            ),
            textStyle: const WidgetStatePropertyAll(
              TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500),
            ),
          ),
          child: child,
        ),
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel({required this.label, this.icon, super.key});
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      if (icon != null) ...[
        Icon(icon, size: HouselySize.iconSmall),
        const SizedBox(width: HouselySpace.xs),
      ],
      Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
    ],
  );
}

class HouselyIconButton extends StatelessWidget {
  const HouselyIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.selected = false,
    this.destructive = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool selected;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final tone = HouselyIconColors.resolve(icon);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: IconButton(
        tooltip: label,
        onPressed: onPressed,
        constraints: const BoxConstraints.tightFor(
          width: HouselySize.minTouch,
          height: HouselySize.minTouch,
        ),
        style: IconButton.styleFrom(
          foregroundColor: destructive
              ? HouselyPalette.coral
              : selected
              ? HouselyPalette.violet
              : tone.foreground,
          backgroundColor: selected
              ? HouselyPalette.violetSoft
              : tone.background,
          disabledForegroundColor: HouselyPalette.textTertiary.withValues(
            alpha: .5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(HouselyRadius.control),
            side: const BorderSide(color: HouselyPalette.divider),
          ),
        ),
        icon: Icon(icon, size: HouselySize.icon),
      ),
    );
  }
}
