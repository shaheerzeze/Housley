import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/components/components.dart';
import '../../design_system/theme/housely_tokens.dart';
import 'home_state.dart';

class HomeCommandScreen extends StatefulWidget {
  const HomeCommandScreen({required this.state, super.key});

  final HomeFeatureState state;

  @override
  State<HomeCommandScreen> createState() => _HomeCommandScreenState();
}

class _HomeCommandScreenState extends State<HomeCommandScreen> {
  bool addOpen = false;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.state,
    builder: (context, _) => SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              _CompactHomeHeader(onMore: () => showHouselyMoreSheet(context)),
              const Divider(height: 1),
              Expanded(
                child: Stack(
                  children: [
                    ListView(
                      padding: const EdgeInsets.fromLTRB(20, 25, 20, 112),
                      children: [
                        Text(
                          'Good evening, Shaheer  👋',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Monday, 17 August · Edinburgh',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 22),
                        _OverviewCard(state: widget.state),
                        const SizedBox(height: 28),
                        _SectionTitle(
                          title: 'Needs your attention',
                          action: 'See all',
                          onAction: () => context.push('/attention'),
                        ),
                        const SizedBox(height: 10),
                        _AttentionCard(state: widget.state),
                        const SizedBox(height: 28),
                        const _SectionTitle(
                          title: 'Today',
                          action: 'Open calendar',
                        ),
                        const SizedBox(height: 4),
                        const _TodayList(),
                        const SizedBox(height: 24),
                        const _SectionTitle(title: 'Your home at a glance'),
                        const SizedBox(height: 10),
                        const _HomeSnapshotGrid(),
                        const SizedBox(height: 26),
                        const _SectionTitle(
                          title: 'Recent activity',
                          action: 'View history',
                        ),
                        const SizedBox(height: 10),
                        const _ActivityCard(),
                      ],
                    ),
                    if (addOpen)
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          key: const ValueKey('add-menu-scrim'),
                          onTap: () => setState(() => addOpen = false),
                          child: const ColoredBox(color: HouselyPalette.scrim),
                        ),
                      ),
                    Positioned(
                      right: 20,
                      bottom: 14,
                      child: _AddMenu(
                        open: addOpen,
                        onToggle: () => setState(() => addOpen = !addOpen),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _CompactHomeHeader extends StatelessWidget {
  const _CompactHomeHeader({required this.onMore});

  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
    child: LayoutBuilder(
      builder: (context, constraints) => Row(
        children: [
          const HomePulse(size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'George Street Flat',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 1),
                Text(
                  '3 people · All at home',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (constraints.maxWidth >= 340)
            const HouselyAvatarGroup(
              names: ['Muhammad Shaheer', 'Alex Morgan', 'Sam Lee'],
            ),
          const SizedBox(width: 8),
          HouselyIconButton(
            icon: Icons.grid_view_rounded,
            label: 'More',
            onPressed: onMore,
          ),
        ],
      ),
    ),
  );
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.state});

  final HomeFeatureState state;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
    decoration: BoxDecoration(
      color: HouselyPalette.violetSoft,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: HouselyPalette.divider),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.monitor_heart_outlined,
                        color: HouselyPalette.violet,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'HOME PULSE',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: HouselyPalette.violet,
                          letterSpacing: .2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${state.attentionCount} things need\nyour attention',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const _CompletionRing(value: .67),
          ],
        ),
        const SizedBox(height: 18),
        const Row(
          children: [
            Expanded(
              child: _OverviewMetric(
                value: '£126.40',
                label: 'owed to you',
                icon: Icons.pie_chart_outline_rounded,
                color: HouselyPalette.sky,
                iconColor: HouselyPalette.onAccent,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _OverviewMetric(
                value: '£84.20',
                label: 'due tomorrow',
                icon: Icons.bolt_rounded,
                color: HouselyPalette.amber,
                iconColor: HouselyPalette.onAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, size: 18),
            const SizedBox(width: 10),
            Text(
              '4 of 6 household tasks complete',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: HouselyPalette.surfacePressed,
            borderRadius: BorderRadius.circular(99),
          ),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: .67,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                gradient: const LinearGradient(
                  colors: [
                    HouselyPalette.mint,
                    HouselyPalette.sky,
                    HouselyPalette.violet,
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 9),
        TextButton.icon(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: HouselyPalette.violet,
          ),
          label: const Text('View summary'),
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          iconAlignment: IconAlignment.end,
        ),
      ],
    ),
  );
}

class _CompletionRing extends StatelessWidget {
  const _CompletionRing({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox.square(
        dimension: 66,
        child: CustomPaint(
          painter: _RingPainter(value),
          child: Center(
            child: Text(
              '${(value * 100).round()}%',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
      ),
      const SizedBox(height: 5),
      Text(
        '4 of 6\ncomplete',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelMedium,
      ),
    ],
  );
}

class _RingPainter extends CustomPainter {
  const _RingPainter(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final track = Paint()
      ..color = HouselyPalette.violetSoft
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    final progress = Paint()
      ..shader = const SweepGradient(
        colors: [
          HouselyPalette.violet,
          HouselyPalette.sky,
          HouselyPalette.mint,
          HouselyPalette.violet,
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6;
    canvas.drawArc(rect.deflate(5), 0, math.pi * 2, false, track);
    canvas.drawArc(
      rect.deflate(5),
      -math.pi / 2,
      math.pi * 2 * value,
      false,
      progress,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      value != oldDelegate.value;
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.iconColor,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(icon, size: 24, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: HouselyPalette.onAccent,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: HouselyPalette.onAccent,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
      if (action != null)
        TextButton(
          onPressed: onAction ?? () {},
          style: TextButton.styleFrom(
            minimumSize: const Size(44, 36),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          child: Text(action!),
        ),
    ],
  );
}

class _AttentionCard extends StatelessWidget {
  const _AttentionCard({required this.state});

  final HomeFeatureState state;

  @override
  Widget build(BuildContext context) {
    final items = state.attention.where((item) => !item.resolved).toList();
    if (items.isEmpty) {
      return const HouselyMessageState(
        kind: HouselyMessageKind.success,
        title: 'All caught up',
        message: 'Nothing needs your attention.',
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: HouselyPalette.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            _AttentionRow(item: items[index], index: index),
            if (index != items.length - 1) const Divider(height: 1, indent: 62),
          ],
        ],
      ),
    );
  }
}

class _AttentionRow extends StatelessWidget {
  const _AttentionRow({required this.item, required this.index});

  final AttentionItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final icons = [
      (Icons.bolt_rounded, HouselyPalette.onAccent, HouselyPalette.coral),
      (
        Icons.person_outline_rounded,
        HouselyPalette.onAccent,
        HouselyPalette.violet,
      ),
      (
        Icons.photo_camera_outlined,
        HouselyPalette.onAccent,
        HouselyPalette.amber,
      ),
    ];
    final visual = icons[index.clamp(0, icons.length - 1)];
    final title = switch (item.id) {
      'bill' => 'Electricity bill',
      'deposit' => 'Deposit evidence',
      _ => item.title,
    };
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push(item.route),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: visual.$3,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(visual.$1, color: visual.$2, size: 23),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 1),
                  Text(
                    item.id == 'bill' ? '£84.20 · Due tomorrow' : item.detail,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 22),
          ],
        ),
      ),
    );
  }
}

class _TodayList extends StatelessWidget {
  const _TodayList();

  @override
  Widget build(BuildContext context) => const Column(
    children: [
      _TodayRow(
        time: '08:30',
        title: 'Electricity payment',
        detail: '£84.20 due tomorrow',
        dotColor: HouselyPalette.coral,
      ),
      Divider(height: 1, indent: 72),
      _TodayRow(
        time: '17:00',
        title: 'Deposit photos',
        detail: 'Living room and kitchen',
        dotColor: HouselyPalette.violet,
      ),
      Divider(height: 1, indent: 72),
      _TodayRow(
        time: '19:30',
        title: 'Household check-in',
        detail: 'Alex, Sam and you',
        dotColor: HouselyPalette.mint,
      ),
    ],
  );
}

class _TodayRow extends StatelessWidget {
  const _TodayRow({
    required this.time,
    required this.title,
    required this.detail,
    required this.dotColor,
  });

  final String time;
  final String title;
  final String detail;
  final Color dotColor;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 11),
    child: Row(
      children: [
        SizedBox(
          width: 46,
          child: Text(time, style: Theme.of(context).textTheme.labelMedium),
        ),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 1),
              Text(detail, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded, size: 22),
      ],
    ),
  );
}

class _HomeSnapshotGrid extends StatelessWidget {
  const _HomeSnapshotGrid();

  @override
  Widget build(BuildContext context) => GridView.count(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    crossAxisCount: 2,
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
    childAspectRatio: 1.45,
    children: const [
      _SnapshotTile(
        value: '£428',
        label: 'Shared spending',
        detail: '£36 less than July',
        icon: Icons.pie_chart_outline_rounded,
        background: HouselyPalette.violetSoft,
        foreground: HouselyPalette.violet,
      ),
      _SnapshotTile(
        value: '25',
        label: 'Home records',
        detail: '6 documents · 19 items',
        icon: Icons.folder_copy_outlined,
        background: HouselyPalette.apricot,
        foreground: HouselyPalette.coral,
      ),
      _SnapshotTile(
        value: '3',
        label: 'Members',
        detail: 'All active',
        icon: Icons.people_outline_rounded,
        background: HouselyPalette.mintSoft,
        foreground: HouselyPalette.mint,
      ),
      _SnapshotTile(
        value: '2',
        label: 'Upcoming',
        detail: 'This week',
        icon: Icons.event_note_outlined,
        background: HouselyPalette.lilacSoft,
        foreground: HouselyPalette.lilac,
      ),
    ],
  );
}

class _SnapshotTile extends StatelessWidget {
  const _SnapshotTile({
    required this.value,
    required this.label,
    required this.detail,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String value;
  final String label;
  final String detail;
  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(icon, color: foreground, size: 22),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            Text(detail, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ],
    ),
  );
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard();

  @override
  Widget build(BuildContext context) => const HouselyGroupedList(
    children: [
      HouselyRecordRow(
        title: 'Sam uploaded a receipt',
        subtitle: 'Weekly shop · 24 minutes ago',
        icon: Icons.receipt_long_outlined,
      ),
      HouselyRecordRow(
        title: 'Alex updated the sofa',
        subtitle: 'Ownership changed to 50% yours',
        icon: Icons.chair_outlined,
      ),
      HouselyRecordRow(
        title: 'Deposit evidence saved',
        subtitle: 'Bedroom · Yesterday',
        icon: Icons.verified_outlined,
      ),
    ],
  );
}

class _AddMenu extends StatelessWidget {
  const _AddMenu({required this.open, required this.onToggle});

  final bool open;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        'Expense',
        Icons.add_rounded,
        HouselyPalette.coralSoft,
        HouselyPalette.coral,
        '/add-expense',
      ),
      (
        'Document',
        Icons.upload_file_outlined,
        HouselyPalette.violetSoft,
        HouselyPalette.violet,
        '/upload-document',
      ),
      (
        'Belonging',
        Icons.chair_outlined,
        HouselyPalette.apricot,
        HouselyPalette.textPrimary,
        '/add-item',
      ),
      (
        'Person',
        Icons.person_outline_rounded,
        HouselyPalette.lilacSoft,
        HouselyPalette.lilac,
        '/household',
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: HouselyMotion.standard,
          child: open
              ? Column(
                  key: const ValueKey('open'),
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final action in actions) ...[
                      _AddAction(
                        label: action.$1,
                        icon: action.$2,
                        background: action.$3,
                        foreground: action.$4,
                        onTap: () => context.push(action.$5),
                      ),
                      const SizedBox(height: 9),
                    ],
                  ],
                )
              : const SizedBox.shrink(key: ValueKey('closed')),
        ),
        FloatingActionButton(
          onPressed: onToggle,
          backgroundColor: HouselyPalette.violet,
          foregroundColor: HouselyPalette.onAccent,
          elevation: 2,
          shape: const CircleBorder(),
          child: AnimatedSwitcher(
            duration: HouselyMotion.standard,
            child: open
                ? const Icon(
                    Icons.close_rounded,
                    key: ValueKey('close-add-menu'),
                    size: 30,
                  )
                : const Icon(
                    Icons.add_rounded,
                    key: ValueKey('open-add-menu'),
                    size: 30,
                  ),
          ),
        ),
      ],
    );
  }
}

class _AddAction extends StatelessWidget {
  const _AddAction({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: background,
    elevation: 2,
    shadowColor: HouselyPalette.scrim,
    borderRadius: BorderRadius.circular(14),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 184,
        height: 48,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(icon, color: foreground, size: 23),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: HouselyPalette.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
