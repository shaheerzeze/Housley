import 'package:flutter/material.dart';

import '../../design_system/components/components.dart';
import '../../design_system/theme/housely_tokens.dart';

class AccessScaffold extends StatelessWidget {
  const AccessScaffold({
    required this.eyebrow,
    required this.title,
    required this.message,
    required this.child,
    this.onBack,
    this.footer,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String message;
  final Widget child;
  final VoidCallback? onBack;
  final Widget? footer;

  @override
  Widget build(BuildContext context) => 
  PopScope(
  canPop: onBack == null,
  onPopInvokedWithResult: (
    didPop,
    result,
  ) {
    if (didPop) return;

    onBack?.call();
  },
  child: Scaffold(
    appBar: onBack == null ? null : HouselyTopBar(title: '', onBack: onBack),
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                HouselySize.phoneGutter,
                onBack == null ? 56 : HouselySpace.lg,
                HouselySize.phoneGutter,
                32 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    eyebrow.toUpperCase(),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: HouselyPalette.violet,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: HouselySpace.sm),
                  Text(title, style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: HouselySpace.sm),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: HouselyPalette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: HouselySpace.xxl),
                  child,
                  if (footer != null) ...[
                    const SizedBox(height: HouselySpace.xl),
                    footer!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  )

);
}
