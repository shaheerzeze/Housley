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
    builder: (context, _) {
      final scenario = widget.state.scenario;
      final model = _HomeModel.forScenario(scenario);
      return SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: HouselySize.maxContentWidth),
            child: Column(
              children: [
                _HomeHeader(model: model),
                const Divider(height: 1),
                Expanded(
                  child: Stack(
                    children: [
                      ListView(
                        key: ValueKey(scenario),
                        padding: const EdgeInsets.fromLTRB(
                          HouselySize.phoneGutter,
                          HouselySpace.xl,
                          HouselySize.phoneGutter,
                          132,
                        ),
                        children: _content(context, model),
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
                      if (!model.readOnly)
                        Positioned(
                          right: HouselySize.phoneGutter,
                          bottom: HouselySpace.md,
                          child: _AddMenu(
                            open: addOpen,
                            admin: model.admin,
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
      );
    },
  );

  List<Widget> _content(BuildContext context, _HomeModel model) {
    if (model.scenario == HomeScenario.noHome) {
      return [
        const _Greeting(),
        const SizedBox(height: HouselySpace.xl),
        _NoHomeCard(),
        const SizedBox(height: HouselySpace.section),
        const _SectionTitle(title: 'Start personally'),
        const SizedBox(height: HouselySpace.sm),
        const _PersonalTools(),
      ];
    }

    return [
      if (model.showGreeting) ...[
        const _Greeting(),
        const SizedBox(height: HouselySpace.xl),
      ],
      if (model.priority != null) ...[
        _PriorityCard(priority: model.priority!),
        const SizedBox(height: HouselySpace.xxl),
      ],
      if (model.summary != null) ...[
        _MonthlySummary(summary: model.summary!),
        const SizedBox(height: HouselySpace.xxl),
      ],
      if (model.attention.isNotEmpty) ...[
        _SectionTitle(
          title: 'Home status',
          action: model.attention.length > 2 ? 'View all' : null,
          onAction: () => context.push('/attention'),
        ),
        const SizedBox(height: HouselySpace.sm),
        _AttentionList(items: model.attention.take(2).toList()),
        const SizedBox(height: HouselySpace.section),
      ],
      if (model.showHousehold) ...[
        _SectionTitle(
          title: 'Household',
          action: model.admin ? 'Manage' : 'View',
          onAction: () => context.push('/household'),
        ),
        const SizedBox(height: HouselySpace.sm),
        _HouseholdPreview(admin: model.admin),
        const SizedBox(height: HouselySpace.section),
      ],
      if (model.scenario == HomeScenario.movingOut) ...[
        const _MoveOutEvidence(),
        const SizedBox(height: HouselySpace.section),
      ],
      const _SectionTitle(title: 'Quick view'),
      const SizedBox(height: HouselySpace.sm),
      _QuickView(model: model),
      const SizedBox(height: HouselySpace.section),
      const _SectionTitle(title: 'Recent activity', action: 'View all'),
      const SizedBox(height: HouselySpace.sm),
      _ActivityList(scenario: model.scenario),
    ];
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.model});
  final _HomeModel model;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
    child: LayoutBuilder(
      builder: (context, constraints) => Row(
        children: [
          const HomePulse(size: 40),
          const SizedBox(width: HouselySpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.scenario == HomeScenario.noHome
                      ? 'Your Housely'
                      : 'George Street Flat',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 1),
                Text(
                  model.headerDetail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (model.scenario != HomeScenario.noHome && constraints.maxWidth >= 340)
            const HouselyAvatarGroup(
              names: ['Muhammad Shaheer', 'Alex Morgan', 'Meera Thomas'],
            ),
          const SizedBox(width: HouselySpace.xs),
          HouselyIconButton(
            icon: Icons.grid_view_rounded,
            label: 'More',
            onPressed: () => showHouselyMoreSheet(context),
          ),
        ],
      ),
    ),
  );
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Good evening, Shaheer 👋', style: Theme.of(context).textTheme.headlineLarge),
      const SizedBox(height: HouselySpace.xxs),
      Text('Monday, 17 August · Edinburgh', style: Theme.of(context).textTheme.bodyMedium),
    ],
  );
}

class _NoHomeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _TonalCard(
    color: HouselyPalette.violetSoft,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _IconTile(icon: Icons.home_outlined, color: HouselyPalette.violet),
        const SizedBox(height: HouselySpace.md),
        Text('Connect your Home', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: HouselySpace.xs),
        Text(
          'Create a household or join the people you already live with. Your personal records stay private.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: HouselySpace.xl),
        HouselyButton(label: 'Create a Home', onPressed: () => context.go('/create-home')),
        const SizedBox(height: HouselySpace.xs),
        HouselyButton(
          label: 'Join with an invitation',
          style: HouselyButtonStyle.secondary,
          onPressed: () => context.go('/start-choice'),
        ),
      ],
    ),
  );
}

class _PersonalTools extends StatelessWidget {
  const _PersonalTools();

  @override
  Widget build(BuildContext context) => const Row(
    children: [
      Expanded(child: _SmallFeature(icon: Icons.folder_outlined, title: 'Vault', detail: 'Personal documents', color: HouselyPalette.lilacSoft)),
      SizedBox(width: HouselySpace.sm),
      Expanded(child: _SmallFeature(icon: Icons.chair_outlined, title: 'Stuff', detail: 'Your belongings', color: HouselyPalette.apricot)),
    ],
  );
}

class _PriorityCard extends StatelessWidget {
  const _PriorityCard({required this.priority});
  final _Priority priority;

  @override
  Widget build(BuildContext context) => _TonalCard(
    color: priority.color,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _IconTile(icon: priority.icon, color: priority.foreground),
            const SizedBox(width: HouselySpace.sm),
            Expanded(
              child: Text(
                priority.eyebrow.toUpperCase(),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: priority.foreground, letterSpacing: .7),
              ),
            ),
            if (priority.progress != null)
              Text(priority.progress!, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
        const SizedBox(height: HouselySpace.md),
        Text(priority.title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: HouselySpace.xs),
        Text(priority.detail, style: Theme.of(context).textTheme.bodyLarge),
        if (priority.steps.isNotEmpty) ...[
          const SizedBox(height: HouselySpace.lg),
          for (final step in priority.steps)
            Padding(
              padding: const EdgeInsets.only(bottom: HouselySpace.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(step.$2 ? Icons.check_circle_rounded : Icons.circle_outlined, size: 20, color: step.$2 ? HouselyPalette.mint : HouselyPalette.textTertiary),
                  const SizedBox(width: HouselySpace.sm),
                  Expanded(child: Text(step.$1, style: Theme.of(context).textTheme.bodyLarge)),
                ],
              ),
            ),
        ],
        const SizedBox(height: HouselySpace.md),
        HouselyButton(
          label: priority.action,
          onPressed: priority.route == null
              ? null
              : () => context.push(priority.route!),
        ),
      ],
    ),
  );
}

class _MonthlySummary extends StatelessWidget {
  const _MonthlySummary({required this.summary});
  final _Summary summary;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(HouselyRadius.feature),
    onTap: () => context.go('/split'),
    child: Container(
      padding: const EdgeInsets.all(HouselySpace.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [HouselyPalette.skySoft, HouselyPalette.violetSoft],
        ),
        borderRadius: BorderRadius.circular(HouselyRadius.feature),
        boxShadow: [
          BoxShadow(
            color: HouselyPalette.sky.withValues(alpha: .08),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  summary.sectionTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: HouselyPalette.surface.withValues(alpha: .72),
                  borderRadius: BorderRadius.circular(HouselyRadius.pill),
                ),
                child: Text(
                  summary.value == 1 ? 'Up to date' : 'This month',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: summary.value == 1
                        ? HouselyPalette.mint
                        : HouselyPalette.sky,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: HouselySpace.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.amount,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 34,
                        letterSpacing: -1.1,
                      ),
                    ),
                    const SizedBox(height: HouselySpace.xxs),
                    Text(summary.label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: HouselyPalette.textSecondary)),
                  ],
                ),
              ),
              _ProgressRing(value: summary.value),
            ],
          ),
          const SizedBox(height: HouselySpace.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(HouselyRadius.pill),
            child: LinearProgressIndicator(
              value: summary.value,
              minHeight: 6,
              backgroundColor: HouselyPalette.surfacePressed,
              valueColor: const AlwaysStoppedAnimation(HouselyPalette.sky),
            ),
          ),
          const SizedBox(height: HouselySpace.sm),
          Row(
            children: [
              Expanded(child: Text(summary.left, style: Theme.of(context).textTheme.bodyMedium)),
              Text(summary.right, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: HouselySpace.lg),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: HouselySpace.sm,
              vertical: HouselySpace.sm,
            ),
            decoration: BoxDecoration(
              color: HouselyPalette.surface.withValues(alpha: .68),
              borderRadius: BorderRadius.circular(HouselyRadius.control),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_outlined, size: 18, color: HouselyPalette.sky),
                const SizedBox(width: HouselySpace.xs),
                Expanded(child: Text(summary.next, style: Theme.of(context).textTheme.bodyMedium)),
                const Icon(Icons.chevron_right_rounded, size: 20),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 58,
    child: CustomPaint(
      painter: _RingPainter(value),
      child: Center(child: Text('${(value * 100).round()}%', style: Theme.of(context).textTheme.titleMedium)),
    ),
  );
}

class _RingPainter extends CustomPainter {
  const _RingPainter(this.value);
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final track = Paint()..color = HouselyPalette.surfacePressed..style = PaintingStyle.stroke..strokeWidth = 6;
    final progress = Paint()..color = HouselyPalette.sky..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeWidth = 6;
    canvas.drawArc(rect.deflate(5), 0, math.pi * 2, false, track);
    canvas.drawArc(rect.deflate(5), -math.pi / 2, math.pi * 2 * value, false, progress);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => value != oldDelegate.value;
}

class _AttentionList extends StatelessWidget {
  const _AttentionList({required this.items});
  final List<AttentionItem> items;

  @override
  Widget build(BuildContext context) => HouselyGroupedList(
    children: [
      for (final item in items)
        HouselyRecordRow(
          title: item.title,
          subtitle: item.detail,
          icon: item.id == 'bill' ? Icons.bolt_rounded : Icons.person_outline_rounded,
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push(item.route),
        ),
    ],
  );
}

class _HouseholdPreview extends StatelessWidget {
  const _HouseholdPreview({required this.admin});
  final bool admin;

  @override
  Widget build(BuildContext context) => const HouselyGroupedList(
    children: [
      HouselyMemberRow(name: 'Muhammad Shaheer', role: 'You · Home admin', status: 'Joined'),
      HouselyMemberRow(name: 'Alex Morgan', role: 'Named on tenancy', status: 'Not joined'),
      HouselyMemberRow(name: 'Meera Thomas', role: 'Household member', status: 'Joined'),
    ],
  );
}

class _MoveOutEvidence extends StatelessWidget {
  const _MoveOutEvidence();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SectionTitle(title: 'Move-in evidence'),
      const SizedBox(height: HouselySpace.sm),
      HouselyGroupedList(
        children: [
          HouselyRecordRow(
            title: 'Move-in record · 12 August 2025',
            subtitle: 'Locked ✓ · Ready to compare',
            icon: Icons.lock_outline_rounded,
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/deposit-guard'),
          ),
          const HouselyRecordRow(
            title: 'Deposit return',
            subtitle: 'Awaiting update',
            icon: Icons.payments_outlined,
          ),
        ],
      ),
    ],
  );
}

class _QuickView extends StatelessWidget {
  const _QuickView({required this.model});
  final _HomeModel model;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final fourAcross = constraints.maxWidth >= 520;
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: fourAcross ? 4 : 2,
        crossAxisSpacing: HouselySpace.sm,
        mainAxisSpacing: HouselySpace.sm,
        childAspectRatio: fourAcross ? .96 : 1.72,
        children: [
          _QuickTile(title: 'Money', detail: model.moneyDetail, icon: Icons.payments_outlined, color: HouselyPalette.skySoft, route: '/split'),
          const _QuickTile(title: 'Household', detail: '3 people · 1 pending', icon: Icons.people_outline_rounded, color: HouselyPalette.mintSoft, route: '/household'),
          const _QuickTile(title: 'Documents', detail: '6 shared records', icon: Icons.folder_outlined, color: HouselyPalette.lilacSoft, route: '/vault'),
          const _QuickTile(title: 'Stuff', detail: '19 recorded items', icon: Icons.chair_outlined, color: HouselyPalette.apricot, route: '/stuff'),
        ],
      );
    },
  );
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({required this.title, required this.detail, required this.icon, required this.color, required this.route});
  final String title;
  final String detail;
  final IconData icon;
  final Color color;
  final String route;

  @override
  Widget build(BuildContext context) => Material(
    color: color,
    borderRadius: BorderRadius.circular(HouselyRadius.group),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => context.go(route),
      child: Padding(
        padding: const EdgeInsets.all(HouselySpace.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: HouselyPalette.surface.withValues(alpha: .7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: HouselySpace.xxs),
                Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _ActivityList extends StatelessWidget {
  const _ActivityList({required this.scenario});
  final HomeScenario scenario;

  @override
  Widget build(BuildContext context) {
    if (scenario == HomeScenario.newAdmin || scenario == HomeScenario.newMember) {
      return const HouselyMessageState(
        kind: HouselyMessageKind.empty,
        title: 'Activity will appear here',
        message: 'Shared changes will be recorded as your Home gets set up.',
      );
    }
    return const HouselyGroupedList(
      children: [
        HouselyRecordRow(title: 'Rent marked as paid', subtitle: 'Today · Household', icon: Icons.check_circle_outline_rounded),
        HouselyRecordRow(title: 'Council tax added', subtitle: 'Yesterday · Household', icon: Icons.receipt_long_outlined),
        HouselyRecordRow(title: 'Move-in evidence saved', subtitle: '15 August · Private', icon: Icons.lock_outline_rounded),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
      if (action != null)
        TextButton(onPressed: onAction ?? () {}, child: Text(action!)),
    ],
  );
}

class _TonalCard extends StatelessWidget {
  const _TonalCard({required this.color, required this.child});
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(HouselySpace.xl),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(HouselyRadius.feature),
      boxShadow: [
        BoxShadow(
          color: HouselyPalette.textPrimary.withValues(alpha: .045),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: child,
  );
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(color: HouselyPalette.surface.withValues(alpha: .72), borderRadius: BorderRadius.circular(HouselyRadius.control)),
    child: Icon(icon, color: color, size: HouselySize.icon),
  );
}

class _SmallFeature extends StatelessWidget {
  const _SmallFeature({required this.icon, required this.title, required this.detail, required this.color});
  final IconData icon;
  final String title;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) => _TonalCard(
    color: color,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon),
        const SizedBox(height: HouselySpace.md),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: HouselySpace.xxs),
        Text(detail, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );
}

class _AddMenu extends StatelessWidget {
  const _AddMenu({required this.open, required this.admin, required this.onToggle});
  final bool open;
  final bool admin;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final actions = <(String, IconData, String)>[
      ('Expense', Icons.receipt_long_outlined, '/add-expense'),
      ('Document', Icons.upload_file_outlined, '/upload-document'),
      ('Belonging', Icons.chair_outlined, '/add-item'),
      if (admin) ('Person', Icons.person_outline_rounded, '/household'),
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
                    for (final action in actions)
                      Padding(
                        padding: const EdgeInsets.only(bottom: HouselySpace.xs),
                        child: Semantics(
                          button: true,
                          label: 'Add ${action.$1}',
                          child: Material(
                            color: HouselyPalette.surface,
                            borderRadius: BorderRadius.circular(HouselyRadius.pill),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(HouselyRadius.pill),
                              onTap: () => context.push(action.$3),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: HouselySpace.md, vertical: HouselySpace.sm),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [Text(action.$1), const SizedBox(width: HouselySpace.xs), Icon(action.$2, size: 20)]),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                )
              : const SizedBox.shrink(key: ValueKey('closed')),
        ),
        FloatingActionButton(
          tooltip: open ? 'Close add menu' : 'Add',
          onPressed: onToggle,
          child: AnimatedRotation(duration: HouselyMotion.standard, turns: open ? .125 : 0, child: Icon(open ? Icons.close_rounded : Icons.add_rounded)),
        ),
      ],
    );
  }
}

class _HomeModel {
  const _HomeModel({
    required this.scenario,
    required this.headerDetail,
    required this.admin,
    required this.readOnly,
    required this.showGreeting,
    required this.showHousehold,
    required this.moneyDetail,
    this.priority,
    this.summary,
    this.attention = const [],
  });

  final HomeScenario scenario;
  final String headerDetail;
  final bool admin;
  final bool readOnly;
  final bool showGreeting;
  final bool showHousehold;
  final String moneyDetail;
  final _Priority? priority;
  final _Summary? summary;
  final List<AttentionItem> attention;

  factory _HomeModel.forScenario(HomeScenario scenario) {
    const householdSummary = _Summary('August at Home', '£1,485.00', 'household commitments', '£1,024.65 recorded', '£460.35 remaining', 'Next · Council tax £165 · 20 Aug', .69);
    const memberSummary = _Summary('Your August', '£425.00', 'your rent share of £850', '£212.50 recorded', '£212.50 left', 'Next · Rent share · 20 Aug', .5);
    final memberPending = AttentionItem('member', 'Alex has not joined yet', 'Named on tenancy · Not joined', '/household');
    final billReview = AttentionItem('bill', 'Energy bill needs review', 'Household · Action required', '/expense-detail');

    return switch (scenario) {
      HomeScenario.noHome => const _HomeModel(scenario: HomeScenario.noHome, headerDetail: 'No active Home', admin: false, readOnly: true, showGreeting: true, showHousehold: false, moneyDetail: 'No shared records'),
      HomeScenario.newAdmin => _HomeModel(scenario: scenario, headerDetail: '1 person · Setting up', admin: true, readOnly: false, showGreeting: true, showHousehold: true, moneyDetail: 'Add commitments', priority: const _Priority.setupAdmin()),
      HomeScenario.newMember => _HomeModel(scenario: scenario, headerDetail: '3 people · Just joined', admin: false, readOnly: false, showGreeting: true, showHousehold: true, moneyDetail: 'Confirm your share', priority: const _Priority.newMember()),
      HomeScenario.partialAdmin => _HomeModel(scenario: scenario, headerDetail: '3 people · At home', admin: true, readOnly: false, showGreeting: false, showHousehold: true, moneyDetail: '£460.35 remaining', priority: const _Priority.partialSetup(), summary: householdSummary, attention: [memberPending]),
      HomeScenario.activeAdmin => _HomeModel(scenario: scenario, headerDetail: '3 people · At home', admin: true, readOnly: false, showGreeting: false, showHousehold: false, moneyDetail: '£460.35 remaining', summary: householdSummary),
      HomeScenario.activeMember => _HomeModel(scenario: scenario, headerDetail: '3 people · At home', admin: false, readOnly: false, showGreeting: false, showHousehold: false, moneyDetail: '£212.50 left', summary: memberSummary),
      HomeScenario.allGoodMember => _HomeModel(scenario: scenario, headerDetail: '3 people · At home', admin: false, readOnly: false, showGreeting: true, showHousehold: false, moneyDetail: 'Up to date', priority: const _Priority.allGood(), summary: const _Summary('Your August', '£425.00', 'your rent share', '£425 recorded', 'Nothing left', 'Next · Council tax · 1 September', 1)),
      HomeScenario.rentDue => _HomeModel(scenario: scenario, headerDetail: '3 people · At home', admin: false, readOnly: false, showGreeting: false, showHousehold: false, moneyDetail: '£425 due soon', priority: const _Priority.rentDue(), summary: memberSummary),
      HomeScenario.overdue => _HomeModel(scenario: scenario, headerDetail: '3 people · At home', admin: false, readOnly: false, showGreeting: false, showHousehold: false, moneyDetail: '£212.50 overdue', priority: const _Priority.overdue(), summary: memberSummary),
      HomeScenario.householdAttention => _HomeModel(scenario: scenario, headerDetail: '3 people · At home', admin: true, readOnly: false, showGreeting: false, showHousehold: true, moneyDetail: '£460.35 remaining', summary: householdSummary, attention: [memberPending, billReview]),
      HomeScenario.guestStay => _HomeModel(scenario: scenario, headerDetail: 'Guest stay · Until 10 Sep', admin: false, readOnly: false, showGreeting: true, showHousehold: false, moneyDetail: '£60 contribution', priority: const _Priority.guest(), summary: const _Summary('Your contributions', '£120.00', 'agreed for this stay', '£60 recorded', '£60 remaining', 'Stay ends · 10 September', .5)),
      HomeScenario.movingOut => _HomeModel(scenario: scenario, headerDetail: 'Moving out · 30 Sep', admin: false, readOnly: false, showGreeting: false, showHousehold: true, moneyDetail: 'Review final balance', priority: const _Priority.movingOut(), summary: memberSummary),
      HomeScenario.archived => _HomeModel(scenario: scenario, headerDetail: 'Left 30 September 2026', admin: false, readOnly: true, showGreeting: false, showHousehold: false, moneyDetail: 'Historical records', priority: const _Priority.archived(), summary: null),
    };
  }
}

class _Priority {
  const _Priority(this.eyebrow, this.title, this.detail, this.action, this.icon, this.color, this.foreground, {this.route, this.progress, this.steps = const []});
  const _Priority.setupAdmin() : this('Home setup', 'Make George Street Flat ready', 'Complete the essentials once. You can refine everything else later.', 'Continue setup', Icons.home_outlined, HouselyPalette.violetSoft, HouselyPalette.violet, route: '/create-home', progress: '1/4 complete', steps: const [('Home created', true), ('Add your rent', false), ('Add recurring payments', false), ('Protect your move-in', false)]);
  const _Priority.newMember() : this('Welcome home', 'Set up your part', 'Confirm only what belongs to you. Household setup stays with the Home admin.', 'Confirm your rent share', Icons.waving_hand_outlined, HouselyPalette.mintSoft, HouselyPalette.mint, route: '/split', steps: const [('Home membership confirmed', true), ('Confirm your rent share', false), ('Review shared commitments', false)]);
  const _Priority.partialSetup() : this('Home setup', 'One important step remains', 'Protect your move-in with a dated, locked evidence record.', 'Protect your move-in', Icons.photo_camera_outlined, HouselyPalette.violetSoft, HouselyPalette.violet, route: '/deposit-guard', progress: '3/4 complete');
  const _Priority.allGood() : this('All up to date', 'You’re sorted for August', 'Your recorded rent share and contributions are complete.', 'View your activity', Icons.check_circle_outline_rounded, HouselyPalette.mintSoft, HouselyPalette.mint, route: '/split');
  const _Priority.rentDue() : this('Due soon', 'Your rent share is due in 3 days', '£425.00 is due on 20 August. This is recorded information, not bank verification.', 'Review rent', Icons.calendar_month_outlined, HouselyPalette.apricot, HouselyPalette.amber, route: '/split');
  const _Priority.overdue() : this('Needs attention', '£212.50 of your rent share is overdue', 'It was due on 20 August. Review the record before marking anything as paid.', 'Review payment', Icons.error_outline_rounded, HouselyPalette.coralSoft, HouselyPalette.coral, route: '/split');
  const _Priority.guest() : this('Guest stay active', 'Your stay ends on 10 September', 'See your agreed contributions and the Home information shared with you.', 'View stay details', Icons.event_note_outlined, HouselyPalette.lilacSoft, HouselyPalette.lilac, route: '/household');
  const _Priority.movingOut() : this('Moving out', 'Complete your move-out by 30 September', 'Review balances, belongings and locked move-in evidence before you leave.', 'Continue move-out', Icons.move_up_rounded, HouselyPalette.apricot, HouselyPalette.amber, route: '/change-impact', progress: '4/7 complete');
  const _Priority.archived() : this('Former Home', 'You left George Street Flat', 'Your permitted records remain available as a read-only history.', 'View personal records', Icons.inventory_2_outlined, HouselyPalette.surfaceRaised, HouselyPalette.textSecondary, route: '/vault');

  final String eyebrow;
  final String title;
  final String detail;
  final String action;
  final IconData icon;
  final Color color;
  final Color foreground;
  final String? route;
  final String? progress;
  final List<(String, bool)> steps;
}

class _Summary {
  const _Summary(this.sectionTitle, this.amount, this.label, this.left, this.right, this.next, this.value);
  final String sectionTitle;
  final String amount;
  final String label;
  final String left;
  final String right;
  final String next;
  final double value;
}
