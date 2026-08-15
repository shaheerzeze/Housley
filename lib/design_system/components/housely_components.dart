import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/housely_tokens.dart';

enum HouselyStatus { neutral, success, attention }

class HouselyStatusPill extends StatelessWidget {
  const HouselyStatusPill({
    required this.label,
    this.status = HouselyStatus.neutral,
    super.key,
  });

  final String label;
  final HouselyStatus status;

  @override
  Widget build(BuildContext context) {
    final (foreground, background) = switch (status) {
      HouselyStatus.success => (HouselyPalette.mint, HouselyPalette.mintSoft),
      HouselyStatus.attention => (
        HouselyPalette.coral,
        HouselyPalette.coralSoft,
      ),
      HouselyStatus.neutral => (
        HouselyPalette.textSecondary,
        HouselyPalette.surfacePressed,
      ),
    };

    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(HouselyRadius.pill),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class HouselySection extends StatelessWidget {
  const HouselySection({
    required this.title,
    required this.child,
    this.caption,
    super.key,
  });

  final String title;
  final String? caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: HouselySpace.xs),
          Text(caption!, style: Theme.of(context).textTheme.bodyMedium),
        ],
        const SizedBox(height: 14),
        child,
      ],
    );
  }
}

class HouselySurface extends StatelessWidget {
  const HouselySurface({
    required this.child,
    this.padding,
    this.color,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? HouselyPalette.surface,
        borderRadius: BorderRadius.circular(HouselyRadius.group),
        border: Border.all(color: HouselyPalette.divider),
        boxShadow: [
          BoxShadow(
            color: HouselyPalette.textPrimary.withValues(alpha: .035),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(HouselyRadius.group),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(HouselySpace.lg),
          child: child,
        ),
      ),
    );
  }
}

class HouselyAdaptiveSwitch extends StatelessWidget {
  const HouselyAdaptiveSwitch({
    required this.value,
    required this.onChanged,
    this.semanticLabel,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final control = Theme.of(context).platform == TargetPlatform.iOS
        ? CupertinoSwitch(
            value: value,
            activeTrackColor: HouselyPalette.violet,
            onChanged: onChanged,
          )
        : Switch(value: value, onChanged: onChanged);
    return Semantics(label: semanticLabel, toggled: value, child: control);
  }
}

class HomePulse extends StatelessWidget {
  const HomePulse({this.size = 44, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Housely home',
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _HomePulsePainter()),
      ),
    );
  }
}

class _HomePulsePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [HouselyPalette.sky, HouselyPalette.violet],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;
    final line = Paint()
      ..color = HouselyPalette.onAccent
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(size.shortestSide * .28),
      ),
      glow,
    );
    final path = Path()
      ..moveTo(size.width * .2, size.height * .55)
      ..cubicTo(
        size.width * .32,
        size.height * .55,
        size.width * .34,
        size.height * .34,
        size.width * .44,
        size.height * .34,
      )
      ..cubicTo(
        size.width * .56,
        size.height * .34,
        size.width * .55,
        size.height * .68,
        size.width * .68,
        size.height * .68,
      )
      ..cubicTo(
        size.width * .76,
        size.height * .68,
        size.width * .78,
        size.height * .52,
        size.width * .84,
        size.height * .52,
      );
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
