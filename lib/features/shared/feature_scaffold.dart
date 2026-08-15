import 'package:flutter/material.dart';

import '../../design_system/components/components.dart';
import '../../design_system/theme/housely_tokens.dart';

class FeatureScaffold extends StatelessWidget {
  const FeatureScaffold({
    required this.title,
    required this.child,
    this.subtitle,
    this.onBack,
    this.action,
    this.bottom,
    super.key,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? action;
  final Widget child;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final gutter = width >= 720
        ? HouselySize.tabletGutter
        : HouselySize.phoneGutter;
    return Scaffold(
      appBar: HouselyTopBar(
        title: title,
        onBack: onBack,
        actions: action == null
            ? const []
            : [action!, const SizedBox(width: 8)],
      ),
      bottomNavigationBar: bottom,
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: HouselySize.maxContentWidth,
            ),
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                gutter,
                HouselySpace.xl,
                gutter,
                40 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              children: [
                if (subtitle != null) ...[
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: HouselyPalette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: HouselySpace.xxl),
                ],
                HouselyEntrance(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
