import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/components/components.dart';
import '../../design_system/theme/housely_tokens.dart';
import '../shared/feature_scaffold.dart';
import 'home_state.dart';

export 'home_dashboard.dart';

// Kept temporarily while the remaining Home subflows migrate to the new
// dashboard patterns.
// ignore: unused_element
class _LegacyHomeCommandScreen extends StatelessWidget {
  const _LegacyHomeCommandScreen({required this.state});
  final HomeFeatureState state;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: state,
    builder: (context, _) => SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: HouselySize.maxContentWidth,
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              HouselySize.phoneGutter,
              15,
              HouselySize.phoneGutter,
              35,
            ),
            children: [
              _HomeHeader(onMore: () => showHouselyMoreSheet(context)),
              const SizedBox(height: 24),
              Text(
                'Good evening, Shaheer',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 5),
              Text(
                'Monday, 17 August · Edinburgh',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              _HouseholdPulse(state: state),
              const SizedBox(height: 26),
              _SectionHeading(
                title: 'Needs your attention',
                action: 'See all',
                onTap: () => context.push('/attention'),
              ),
              const SizedBox(height: 12),
              _AttentionPanel(state: state),
              const SizedBox(height: 28),
              const _SectionHeading(title: 'Today', action: 'Open calendar'),
              const SizedBox(height: 12),
              const _TodayTimeline(),
              const SizedBox(height: 26),
              const _SectionHeading(title: 'Quick add'),
              const SizedBox(height: 10),
              _QuickActions(context: context),
              const SizedBox(height: 28),
              const _SectionHeading(title: 'Your home at a glance'),
              const SizedBox(height: 12),
              const _HomeMetrics(),
              const SizedBox(height: 28),
              const _SectionHeading(
                title: 'Recent activity',
                action: 'View history',
              ),
              const SizedBox(height: 12),
              const _RecentActivity(),
            ],
          ),
        ),
      ),
    ),
  );
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onMore});
  final VoidCallback onMore;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      const HomePulse(size: 42),
      const SizedBox(width: 11),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'George Street Flat',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 2),
            Text(
              '3 people · All at home',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
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
  );
}

class _HouseholdPulse extends StatelessWidget {
  const _HouseholdPulse({required this.state});
  final HomeFeatureState state;
  @override
  Widget build(BuildContext context) => HouselyPulsePanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            HouselyStatusPill(
              label: '${state.attentionCount} need attention',
              status: HouselyStatus.attention,
            ),
            const Spacer(),
            Text('72%', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'A busy week,\nmostly under control.',
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 10),
        Text(
          '${state.attentionCount} actions need you. Bills and shared records are otherwise up to date.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: HouselyPalette.textPrimary),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () => context.push('/change-impact'),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: HouselyPalette.textPrimary,
          ),
          icon: const Icon(Icons.arrow_outward_rounded, size: 18),
          label: const Text('Alex is leaving'),
        ),
        const SizedBox(height: 22),
        ClipRRect(
          borderRadius: BorderRadius.circular(HouselyRadius.pill),
          child: const LinearProgressIndicator(
            value: .72,
            minHeight: 7,
            backgroundColor: HouselyPalette.surfacePressed,
            valueColor: AlwaysStoppedAnimation(HouselyPalette.violet),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const Expanded(
              child: _PulseStat(value: '£126.40', label: 'owed to you'),
            ),
            Container(
              width: 1,
              height: 34,
              color: HouselyPalette.textPrimary.withValues(alpha: .12),
            ),
            const Expanded(
              child: _PulseStat(value: '4 of 6', label: 'tasks complete'),
            ),
          ],
        ),
      ],
    ),
  );
}

class _PulseStat extends StatelessWidget {
  const _PulseStat({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.action, this.onTap});
  final String title;
  final String? action;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      if (action != null)
        TextButton(onPressed: onTap ?? () {}, child: Text(action!)),
    ],
  );
}

class _TodayTimeline extends StatelessWidget {
  const _TodayTimeline();
  @override
  Widget build(BuildContext context) => const HouselySurface(
    padding: EdgeInsets.symmetric(vertical: 4),
    child: Column(
      children: [
        _TimelineRow(
          time: '08:30',
          title: 'Electricity payment',
          detail: '£84.20 · due tomorrow',
          color: HouselyPalette.coral,
        ),
        Divider(indent: 72),
        _TimelineRow(
          time: '17:00',
          title: 'Deposit photos',
          detail: 'Living room and kitchen',
          color: HouselyPalette.violet,
        ),
        Divider(indent: 72),
        _TimelineRow(
          time: '19:30',
          title: 'Household check-in',
          detail: 'Alex, Sam and you',
          color: HouselyPalette.mint,
        ),
      ],
    ),
  );
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.time,
    required this.title,
    required this.detail,
    required this.color,
  });
  final String time;
  final String title;
  final String detail;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    child: Row(
      children: [
        SizedBox(
          width: 45,
          child: Text(time, style: Theme.of(context).textTheme.labelMedium),
        ),
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(detail, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        const Icon(
          Icons.chevron_right_rounded,
          color: HouselyPalette.textTertiary,
        ),
      ],
    ),
  );
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.context});
  final BuildContext context;
  @override
  Widget build(BuildContext _) => Row(
    children: [
      Expanded(
        child: HouselyQuickAction(
          label: 'Expense',
          icon: Icons.add_rounded,
          tint: HouselyPalette.coralSoft,
          iconColor: HouselyPalette.coral,
          onTap: () => context.push('/add-expense'),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: HouselyQuickAction(
          label: 'Document',
          icon: Icons.upload_file_outlined,
          onTap: () => context.push('/upload-document'),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: HouselyQuickAction(
          label: 'Belonging',
          icon: Icons.chair_outlined,
          tint: HouselyPalette.apricot,
          iconColor: HouselyPalette.textPrimary,
          onTap: () => context.push('/add-item'),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: HouselyQuickAction(
          label: 'Person',
          icon: Icons.person_add_alt_1_outlined,
          tint: HouselyPalette.lilacSoft,
          onTap: () => context.push('/household'),
        ),
      ),
    ],
  );
}

class _AttentionPanel extends StatelessWidget {
  const _AttentionPanel({required this.state});
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
    return HouselyPulsePanel(
      baseColor: HouselyPalette.coralSoft,
      glowColor: HouselyPalette.apricot,
      padding: const EdgeInsets.all(HouselySize.phoneGutter),
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            InkWell(
              borderRadius: BorderRadius.circular(HouselyRadius.control),
              onTap: () => context.push(items[index].route),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: HouselyPalette.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_outward_rounded,
                        size: 18,
                        color: HouselyPalette.coral,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            items[index].title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            items[index].detail,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    if (items[index].amount != null)
                      Text(
                        items[index].amount!,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    const Icon(Icons.chevron_right_rounded, size: 20),
                  ],
                ),
              ),
            ),
            if (index != items.length - 1)
              Divider(color: HouselyPalette.textPrimary.withValues(alpha: .1)),
          ],
        ],
      ),
    );
  }
}

class _HomeMetrics extends StatelessWidget {
  const _HomeMetrics();
  @override
  Widget build(BuildContext context) => const Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: HouselyMetricCard(
          label: 'Shared spending',
          value: '£428',
          detail: '£36 less than July',
          icon: Icons.pie_chart_outline_rounded,
          color: HouselyPalette.violetSoft,
        ),
      ),
      SizedBox(width: 10),
      Expanded(
        child: HouselyMetricCard(
          label: 'Home records',
          value: '25',
          detail: '6 documents · 19 items',
          icon: Icons.folder_copy_outlined,
          color: HouselyPalette.apricot,
          iconColor: HouselyPalette.coral,
        ),
      ),
    ],
  );
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity();
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

class AttentionScreen extends StatefulWidget {
  const AttentionScreen({required this.state, super.key});
  final HomeFeatureState state;

  @override
  State<AttentionScreen> createState() => _AttentionScreenState();
}

class _AttentionScreenState extends State<AttentionScreen> {
  String filter = 'All';

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.state,
    builder: (context, _) {
      final items = widget.state.attention.where((item) {
        if (item.resolved) return false;
        if (filter == 'Due soon') {
          return item.id == 'bill' || item.id == 'deposit';
        }
        if (filter == 'Changes') return item.id == 'leaving';
        return true;
      }).toList();
      return FeatureScaffold(
        title: 'Attention',
        subtitle: 'Only records that require an action appear here.',
        onBack: () => context.pop(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              children: ['All', 'Due soon', 'Changes']
                  .map(
                    (value) => HouselyFilterChip(
                      label: value,
                      selected: filter == value,
                      onSelected: (_) => setState(() => filter = value),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: HouselySpace.lg),
            if (items.isEmpty)
              const HouselyMessageState(
                kind: HouselyMessageKind.empty,
                title: 'Nothing in this view',
                message: 'Try another filter or return to Home.',
              )
            else
              HouselyGroupedList(
                children: items
                    .map(
                      (item) => HouselyAttentionRow(
                        title: item.title,
                        detail: item.detail,
                        amount: item.amount,
                        actionLabel: 'Review',
                        onTap: () => context.push(item.route),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      );
    },
  );
}

class HouseholdScreen extends StatelessWidget {
  const HouseholdScreen({required this.state, super.key});
  final HomeFeatureState state;

  @override
  Widget build(BuildContext context) => FeatureScaffold(
    title: 'Your household',
    subtitle: 'Membership and access to George Street Flat.',
    onBack: () => context.pop(),
    action: HouselyIconButton(
      icon: Icons.person_add_alt_1_outlined,
      label: 'Invite someone',
      onPressed: () {},
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HouselyPrivacyNotice(
          title: 'Household boundary',
          message:
              'Personal records and private-group activity never appear to Home members or admins.',
        ),
        const SizedBox(height: HouselySpace.lg),
        HouselyGroupedList(
          children: [
            const HouselyMemberRow(
              name: 'Muhammad Shaheer',
              role: 'Home admin',
              status: 'You',
            ),
            HouselyMemberRow(
              name: 'Alex Morgan',
              role: state.departureComplete ? 'Former member' : 'Member',
              status: state.departureComplete ? 'Removed' : 'Leaving',
              onTap: state.departureComplete
                  ? null
                  : () => context.push('/change-impact'),
            ),
            const HouselyMemberRow(
              name: 'Sam Lee',
              role: 'Member',
              status: 'Active',
            ),
            const HouselyMemberRow(
              name: 'Jamie Wilson',
              role: 'Invited',
              status: 'Pending',
            ),
          ],
        ),
      ],
    ),
  );
}

class ChangesScreen extends StatefulWidget {
  const ChangesScreen({required this.state, super.key});
  final HomeFeatureState state;
  @override
  State<ChangesScreen> createState() => _ChangesScreenState();
}

class _ChangesScreenState extends State<ChangesScreen> {
  String tab = 'Needs attention';
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.state,
    builder: (context, _) => FeatureScaffold(
      title: 'Changes',
      onBack: () => context.pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HouselySegmentedControl<String>(
            segments: const {
              'Needs attention': 'Needs attention',
              'Resolved': 'Resolved',
            },
            selected: tab,
            onChanged: (value) => setState(() => tab = value),
          ),
          const SizedBox(height: HouselySpace.lg),
          if (tab == 'Needs attention' && !widget.state.departureComplete)
            HouselyGroupedList(
              children: [
                HouselyAttentionRow(
                  title: 'Alex is leaving',
                  detail: 'End date · 31 August 2026',
                  actionLabel: 'Review impact',
                  onTap: () => context.push('/change-impact'),
                ),
              ],
            )
          else if (tab == 'Resolved' && widget.state.departureComplete)
            const HouselyGroupedList(
              children: [
                HouselyRecordRow(
                  title: 'Alex moved out',
                  subtitle: 'Access ended safely · 31 August 2026',
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: HouselyPalette.mint,
                ),
              ],
            )
          else
            const HouselyMessageState(
              kind: HouselyMessageKind.empty,
              title: 'No changes here',
              message: 'Household membership history will appear in this view.',
            ),
        ],
      ),
    ),
  );
}

class ChangeImpactScreen extends StatelessWidget {
  const ChangeImpactScreen({required this.state, super.key});
  final HomeFeatureState state;

  @override
  Widget build(BuildContext context) => FeatureScaffold(
    title: 'Alex is leaving',
    subtitle: 'Review every connected Household record before access changes.',
    onBack: () => context.pop(),
    bottom: HouselyStickyAction(
      label: 'Resolve changes',
      onPressed: () => context.push('/finish-move-out'),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HouselyPrivacyNotice(
          title: 'Private data stays private',
          message:
              'This impact review includes only Household records you are allowed to see.',
        ),
        const SizedBox(height: HouselySpace.lg),
        const HouselyBalanceSummary(
          amount: '£42.10',
          label: 'Alex owes the household',
          positive: false,
        ),
        const SizedBox(height: HouselySpace.lg),
        const HouselyGroupedList(
          children: [
            HouselyRecordRow(
              title: 'Outstanding balance',
              subtitle: '2 unsettled expenses',
              icon: Icons.account_balance_wallet_outlined,
              iconColor: HouselyPalette.coral,
            ),
            HouselyRecordRow(
              title: 'Recurring costs',
              subtitle: 'Internet and electricity',
              icon: Icons.repeat_rounded,
              iconColor: HouselyPalette.coral,
            ),
            HouselyRecordRow(
              title: 'Shared belongings',
              subtitle: 'Sofa and coffee table',
              icon: Icons.chair_outlined,
              iconColor: HouselyPalette.coral,
            ),
          ],
        ),
      ],
    ),
  );
}

class FinishMoveOutScreen extends StatelessWidget {
  const FinishMoveOutScreen({required this.state, super.key});
  final HomeFeatureState state;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: state,
    builder: (context, _) => FeatureScaffold(
      title: 'Finish move-out',
      subtitle:
          'Alex keeps coherent financial history, but loses future Household access when this completes.',
      onBack: () => context.pop(),
      bottom: HouselyStickyAction(
        label: 'Confirm departure',
        onPressed: state.canFinishMoveOut
            ? () async {
                final confirmed = await showHouselyConfirmation(
                  context,
                  title: 'End Alex’s access?',
                  message:
                      'This happens atomically and cannot be undone from this screen.',
                  confirmLabel: 'Confirm departure',
                  destructive: true,
                );
                if (confirmed == true && context.mounted) {
                  state.finishDeparture();
                  context.go('/household');
                }
              }
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HouselySurface(
            child: Column(
              children: [
                HouselyCheckbox(
                  label: 'Outstanding balance resolved',
                  supportingText:
                      'The settlement or agreed outcome is recorded.',
                  value: state.balanceResolved,
                  onChanged: (value) => state.setBalance(value ?? false),
                ),
                const Divider(),
                HouselyCheckbox(
                  label: 'Recurring costs reassigned',
                  supportingText: 'Future bills no longer include Alex.',
                  value: state.recurringResolved,
                  onChanged: (value) => state.setRecurring(value ?? false),
                ),
                const Divider(),
                HouselyCheckbox(
                  label: 'Shared belongings resolved',
                  supportingText:
                      'Ownership and collection plans are recorded.',
                  value: state.itemsResolved,
                  onChanged: (value) => state.setItems(value ?? false),
                ),
              ],
            ),
          ),
          const SizedBox(height: HouselySpace.md),
          HouselyStatusPill(
            label: state.canFinishMoveOut
                ? 'Ready to confirm'
                : 'Complete all 3 steps',
            status: state.canFinishMoveOut
                ? HouselyStatus.success
                : HouselyStatus.attention,
          ),
        ],
      ),
    ),
  );
}

class ExpenseDetailPlaceholder extends StatelessWidget {
  const ExpenseDetailPlaceholder({required this.state, super.key});
  final HomeFeatureState state;
  @override
  Widget build(BuildContext context) => FeatureScaffold(
    title: 'Electricity',
    onBack: () => context.pop(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HouselyBalanceSummary(
          amount: '£84.20',
          label: 'Due tomorrow',
          positive: false,
        ),
        const SizedBox(height: HouselySpace.lg),
        HouselyButton(
          label: 'Mark as reviewed',
          onPressed: () {
            state.resolve('bill');
            context.pop();
          },
        ),
      ],
    ),
  );
}
