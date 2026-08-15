import 'package:flutter/material.dart';

import '../theme/housely_tokens.dart';

/// A restrained entrance transition for newly presented page content.
/// It becomes instantaneous when the operating system requests reduced motion.
class HouselyEntrance extends StatefulWidget {
  const HouselyEntrance({required this.child, super.key});

  final Widget child;

  @override
  State<HouselyEntrance> createState() => _HouselyEntranceState();
}

class _HouselyEntranceState extends State<HouselyEntrance> {
  bool visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: HouselyMotion.standard,
      curve: HouselyMotion.curve,
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, .018),
        duration: HouselyMotion.standard,
        curve: HouselyMotion.curve,
        child: widget.child,
      ),
    );
  }
}

class HouselyAnimatedStatus extends StatelessWidget {
  const HouselyAnimatedStatus({
    required this.child,
    required this.stateKey,
    super.key,
  });

  final Widget child;
  final Object stateKey;

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    return AnimatedSwitcher(
      duration: reduced ? Duration.zero : HouselyMotion.standard,
      switchInCurve: HouselyMotion.curve,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: .985, end: 1.0).animate(animation),
          child: child,
        ),
      ),
      child: KeyedSubtree(key: ValueKey(stateKey), child: child),
    );
  }
}
