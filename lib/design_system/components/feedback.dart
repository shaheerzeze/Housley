import 'package:flutter/material.dart';

import '../theme/housely_tokens.dart';

class HouselyProgress extends StatelessWidget {
  const HouselyProgress({
    this.value,
    this.label,
    this.semanticLabel,
    super.key,
  });

  final double? value;
  final String? label;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel ?? label ?? 'Progress',
    value: value == null ? 'Loading' : '${(value! * 100).round()} percent',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) ...[
          Text(label!, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: HouselySpace.xs),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(HouselyRadius.pill),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: HouselyPalette.surfacePressed,
            color: HouselyPalette.violet,
          ),
        ),
      ],
    ),
  );
}

class HouselyUploadProgress extends StatelessWidget {
  const HouselyUploadProgress({
    required this.fileName,
    required this.progress,
    this.onCancel,
    this.error,
    this.complete = false,
    super.key,
  });

  final String fileName;
  final double progress;
  final VoidCallback? onCancel;
  final String? error;
  final bool complete;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(HouselySpace.md),
    decoration: BoxDecoration(
      color: HouselyPalette.surface,
      borderRadius: BorderRadius.circular(HouselyRadius.group),
      border: Border.all(
        color: error != null ? HouselyPalette.coral : HouselyPalette.divider,
      ),
    ),
    child: Row(
      children: [
        Icon(
          complete
              ? Icons.check_circle_outline_rounded
              : Icons.description_outlined,
          color: complete
              ? HouselyPalette.mint
              : error != null
              ? HouselyPalette.coral
              : HouselyPalette.textSecondary,
        ),
        const SizedBox(width: HouselySpace.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fileName, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: HouselySpace.xs),
              if (error != null)
                Text(
                  error!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: HouselyPalette.coral),
                )
              else
                HouselyProgress(
                  value: complete ? 1 : progress,
                  semanticLabel: 'Upload progress for $fileName',
                ),
            ],
          ),
        ),
        if (!complete && onCancel != null)
          IconButton(
            tooltip: 'Cancel upload',
            onPressed: onCancel,
            icon: const Icon(Icons.close_rounded),
          ),
      ],
    ),
  );
}

class HouselySkeleton extends StatefulWidget {
  const HouselySkeleton({
    this.width = double.infinity,
    this.height = 16,
    this.radius = HouselyRadius.control,
    super.key,
  });

  final double width;
  final double height;
  final double radius;

  @override
  State<HouselySkeleton> createState() => _HouselySkeletonState();
}

class _HouselySkeletonState extends State<HouselySkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(
              HouselyPalette.surface,
              HouselyPalette.surfacePressed,
              reduceMotion ? .5 : _controller.value,
            ),
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        ),
      ),
    );
  }
}
