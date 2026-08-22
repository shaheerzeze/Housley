import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/components/components.dart';
import '../../design_system/theme/housely_tokens.dart';
import '../../data/mvp_app_state.dart';
import '../shared/feature_scaffold.dart';
import 'mvp_catalog.dart';

class MvpAccessGate extends StatelessWidget {
  const MvpAccessGate({required this.appState, required this.path, required this.child, super.key});
  final MvpAppState appState;
  final String path;
  final Widget child;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: appState,
    builder: (context, _) {
      if (!appState.online && path != '/offline') {
        return FeatureScaffold(
          title: 'Offline',
          subtitle: 'Saved information remains available while Housely reconnects.',
          onBack: () => context.go('/home'),
          child: HouselyMessageState(
            title: 'You are offline',
            message: 'This action needs a connection. No entered household information has been lost.',
            kind: HouselyMessageKind.offline,
            actionLabel: 'Try again',
            onAction: () => appState.setOnline(true),
          ),
        );
      }
      if (appState.canAccess(path)) return child;
      return FeatureScaffold(
        title: 'Access restricted',
        subtitle: 'This action is not available for your current household role.',
        onBack: () => context.canPop() ? context.pop() : context.go('/home'),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const HouselyMessageState(
            title: 'You do not have access',
            message: 'A Home admin can complete this action. Your private records and permitted household areas are still available.',
            kind: HouselyMessageKind.error,
          ),
          const SizedBox(height: HouselySpace.md),
          HouselyButton(label: 'Return Home', onPressed: () => context.go('/home')),
        ]),
      );
    },
  );
}

class RestrictedAccessScreen extends StatelessWidget {
  const RestrictedAccessScreen({super.key});

  @override
  Widget build(BuildContext context) => FeatureScaffold(
    title: 'Access restricted',
    subtitle: 'Your current household role does not include this action.',
    onBack: () => context.go('/home'),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const HouselyMessageState(
        title: 'This belongs to a Home admin',
        message: 'You can continue using your personal and explicitly shared areas. Ask a Home admin if this household record needs changing.',
        kind: HouselyMessageKind.error,
      ),
      const SizedBox(height: HouselySpace.md),
      HouselyButton(label: 'Return Home', onPressed: () => context.go('/home')),
    ]),
  );
}

class MvpCatalogScreen extends StatelessWidget {
  const MvpCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final areas = <String>{for (final screen in mvpScreenCatalog) screen.area};
    return FeatureScaffold(
      title: 'MVP screen library',
      subtitle: '${mvpScreenCatalog.length} route-level screens across ${areas.length} product areas. Use this to review the complete prototype before Supabase.',
      onBack: () => context.pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final area in areas) ...[
            _SectionTitle(area),
            HouselyGroupedList(
              children: mvpScreenCatalog.where((screen) => screen.area == area).map((screen) => HouselyRecordRow(
                title: '${screen.id} · ${screen.title}',
                subtitle: screen.subtitle,
                icon: screen.icon,
                onTap: () => context.push(screen.path),
              )).toList(),
            ),
            const SizedBox(height: HouselySpace.xxl),
          ],
        ],
      ),
    );
  }
}

class MvpScreen extends StatefulWidget {
  const MvpScreen({required this.spec, required this.appState, super.key});
  final MvpScreenSpec spec;
  final MvpAppState appState;

  @override
  State<MvpScreen> createState() => _MvpScreenState();
}

class _MvpScreenState extends State<MvpScreen> {
  final _controller = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.spec.items.isNotEmpty) {
      final parts = widget.spec.items.first.split('|');
      if (parts.length > 1) _controller.text = parts.sublist(1).join(' · ');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _go(String? path) async {
    if (path == null) return;
    if (widget.spec.kind == MvpScreenKind.form && _controller.text.trim().isEmpty) {
      setState(() => _error = 'Complete the required field before continuing.');
      return;
    }
    if (widget.spec.path == '/move-out-checklist' && !widget.appState.moveOutReady) {
      setState(() => _error = 'Complete the required move-out checks before comparing evidence.');
      return;
    }
    if (widget.spec.kind == MvpScreenKind.warning && path == widget.spec.primaryPath) {
      final confirmed = await showHouselyConfirmation(
        context,
        title: widget.spec.title,
        message: widget.spec.subtitle,
        confirmLabel: widget.spec.primaryLabel ?? 'Confirm',
        destructive: widget.spec.path == '/delete-account' ||
            widget.spec.path == '/end-stay' ||
            widget.spec.path == '/transfer-review',
      );
      if (confirmed != true || !mounted) return;
    }
    _applyAction();
    setState(() => _busy = true);
    Future<void>.delayed(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      if (path.startsWith('/')) context.go(path);
    });
  }

  void _applyAction() {
    final state = widget.appState;
    switch (widget.spec.path) {
      case '/review-invitation':
        state.invite('Alex Morgan');
        break;
      case '/extend-stay':
        state.extendGuest();
        break;
      case '/end-stay':
        state.endGuest();
        break;
      case '/leave-home':
        state.selectLifecycle(HomeLifecycle.movingOut);
        break;
      case '/task-detail':
        state.completeTask();
        break;
      case '/approve-change':
        state.approveChange();
        break;
      case '/move-out-review':
        state.finishMoveOut();
        break;
      case '/recurring-payment-detail':
        state.recordCouncilTax();
        break;
      case '/create-split-group':
        state.createPrivateGroup(_controller.text);
        break;
      case '/transfer-review':
        state.setOutcome('Ownership transferred', 'The ownership history has been updated.');
        break;
      case '/edit-profile':
        state.setOutcome('Profile updated', 'Your contact information has been saved.');
        break;
      case '/member-permissions':
        state.setOutcome('Member access updated', 'The new access rules are now active.');
        break;
      case '/notification-settings':
        state.setOutcome('Notification preferences saved', 'You will only receive the updates you selected.');
        break;
      case '/accessibility-settings':
        state.setOutcome('Accessibility settings saved', 'Your display and motion preferences are active.');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final spec = widget.spec;
    return ListenableBuilder(
      listenable: widget.appState,
      builder: (context, _) => FeatureScaffold(
      title: spec.title,
      subtitle: spec.subtitle,
      onBack: () => context.canPop() ? context.pop() : context.go('/home-preview'),
      action: spec.kind == MvpScreenKind.detail
          ? HouselyIconButton(icon: Icons.more_horiz_rounded, label: 'More options', onPressed: () => _showMore(context))
          : null,
      bottom: spec.primaryLabel == null ? null : HouselyStickyAction(
        label: spec.primaryLabel!,
        onPressed: _busy ? null : () => _go(spec.primaryPath),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (spec.kind == MvpScreenKind.overview ||
              spec.kind == MvpScreenKind.success ||
              spec.kind == MvpScreenKind.warning ||
              spec.kind == MvpScreenKind.privacy)
            _Hero(spec: spec)
          else
            _CompactContext(spec: spec),
          if (_error != null) ...[
            const SizedBox(height: HouselySpace.md),
            HouselyValidationSummary(errors: [_error!]),
          ],
          if (spec.path == '/settings-saved') ...[
            const SizedBox(height: HouselySpace.xxl),
            HouselyMessageState(
              title: widget.appState.successTitle,
              message: widget.appState.successMessage,
              kind: HouselyMessageKind.success,
            ),
          ],
          if (spec.items.isNotEmpty) ...[
            const SizedBox(height: HouselySpace.xxl),
            if (spec.kind == MvpScreenKind.form)
              _FormContent(spec: spec, controller: _controller, onChanged: () => setState(() {}))
            else
              _RecordContent(spec: spec, appState: widget.appState),
          ],
          if (spec.note != null) ...[
            const SizedBox(height: HouselySpace.md),
            HouselyPrivacyNotice(title: 'Good to know', message: spec.note!),
          ],
          if (spec.kind == MvpScreenKind.privacy) ...[
            const SizedBox(height: HouselySpace.md),
            const HouselyPrivacyNotice(
              title: 'Private by default',
              message: 'Landlords cannot see private balances, private groups, personal documents, personal belongings or household-only activity.',
            ),
          ],
          if (spec.secondaryLabel != null) ...[
            const SizedBox(height: HouselySpace.md),
            HouselyButton(
              label: spec.secondaryLabel!,
              style: spec.kind == MvpScreenKind.warning ? HouselyButtonStyle.secondary : HouselyButtonStyle.text,
              onPressed: () => _go(spec.secondaryPath),
            ),
          ],
          if (_busy) ...[
            const SizedBox(height: HouselySpace.md),
            const LinearProgressIndicator(minHeight: 2),
          ],
        ],
      ),
    ),
    );
  }

  void _showMore(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          HouselyRecordRow(title: 'Share or export', subtitle: 'Only information you can access', icon: Icons.ios_share_outlined, onTap: () => Navigator.pop(context)),
          HouselyRecordRow(title: 'Report a problem', subtitle: 'Tell us if something looks wrong', icon: Icons.flag_outlined, onTap: () { Navigator.pop(context); this.context.push('/report-problem'); }),
        ]),
      ),
    ),
  );
}

class _Hero extends StatelessWidget {
  const _Hero({required this.spec});
  final MvpScreenSpec spec;

  @override
  Widget build(BuildContext context) {
    final colors = switch (spec.kind) {
      MvpScreenKind.success => (HouselyPalette.mintSoft, HouselyPalette.mint),
      MvpScreenKind.warning => (HouselyPalette.apricot, HouselyPalette.amber),
      MvpScreenKind.privacy => (HouselyPalette.lilacSoft, HouselyPalette.lilac),
      MvpScreenKind.form => (HouselyPalette.skySoft, HouselyPalette.sky),
      _ => (HouselyPalette.violetSoft, HouselyPalette.violet),
    };
    return Container(
      padding: const EdgeInsets.all(HouselySpace.xl),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(HouselyRadius.feature),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: HouselyPalette.surface.withValues(alpha: .72), borderRadius: BorderRadius.circular(16)), child: Icon(spec.icon, color: colors.$2)),
        const SizedBox(width: HouselySpace.md),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(spec.area.toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.$2, letterSpacing: .6)),
          const SizedBox(height: 6),
          Text(_heroLine(spec), style: Theme.of(context).textTheme.headlineMedium),
        ])),
      ]),
    );
  }

  String _heroLine(MvpScreenSpec spec) => switch (spec.kind) {
    MvpScreenKind.success => 'Everything is safely recorded.',
    MvpScreenKind.warning => 'Review the impact before continuing.',
    MvpScreenKind.privacy => 'You stay in control of access.',
    MvpScreenKind.form => 'A few clear details are all we need.',
    MvpScreenKind.overview => 'See the whole picture at a glance.',
    MvpScreenKind.list => 'Important information, clearly organised.',
    MvpScreenKind.detail => 'The full record, with its context.',
  };
}

class _CompactContext extends StatelessWidget {
  const _CompactContext({required this.spec});
  final MvpScreenSpec spec;

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: HouselyIconColors.resolve(spec.icon).background,
        borderRadius: BorderRadius.circular(HouselyRadius.control),
      ),
      child: Icon(spec.icon, size: 20, color: HouselyIconColors.resolve(spec.icon).foreground),
    ),
    const SizedBox(width: HouselySpace.sm),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: HouselyPalette.surfaceRaised,
        borderRadius: BorderRadius.circular(HouselyRadius.pill),
      ),
      child: Text(spec.area, style: Theme.of(context).textTheme.labelMedium),
    ),
  ]);
}

class _RecordContent extends StatelessWidget {
  const _RecordContent({required this.spec, required this.appState});
  final MvpScreenSpec spec;
  final MvpAppState appState;

  @override
  Widget build(BuildContext context) {
    final records = _records();
    return HouselyGroupedList(
    children: records.asMap().entries.map((entry) {
      final raw = entry.value;
      final parts = raw.split('|');
      return HouselyRecordRow(
        title: parts.first,
        subtitle: parts.length > 1 ? parts.sublist(1).join(' · ') : null,
        icon: _itemIcon(parts.first),
        onTap: spec.kind == MvpScreenKind.list
            ? () => _openRecord(context, entry.key, parts.first, parts.length > 1 ? parts.sublist(1).join(' · ') : null)
            : null,
      );
    }).toList(),
  );
  }

  List<String> _records() => switch (spec.path) {
    '/notifications' => appState.notifications.map((item) => '${item.title}|${item.read ? 'Read' : 'Unread'}').toList(),
    '/household-overview' => appState.members.map((item) => '${item.name}|${item.relationship} · ${item.status}').toList(),
    '/tasks' => appState.tasks.map((item) => '${item.title}|${item.assignee} · ${item.complete ? 'Complete' : 'Open'}').toList(),
    '/changes-overview' => appState.changes.map((item) => '${item.title}|${item.current} → ${item.proposed} · ${item.status}').toList(),
    '/move-out-checklist' => appState.moveOutSteps.entries.map((item) => '${item.key}|${item.value ? 'Complete' : 'Action needed'}').toList(),
    '/split-groups' => ['George Street Flat|3 members · Household', ...appState.privateGroups.map((item) => '$item|Private group · Members only')],
    '/recurring-payments' => [
      'Rent|£850.00 · Monthly · 1st',
      'Council tax|£165.00 · ${appState.councilTaxPaid ? 'Paid' : 'Due 20 September'}',
      'Broadband|£32.00 · Monthly · 24th',
    ],
    _ => spec.items,
  };

  void _openRecord(BuildContext context, int index, String title, String? detail) {
    final route = switch (spec.path) {
      '/notifications' => appState.notifications[index].destination,
      '/household-overview' => index == 3 ? '/temporary-stay' : '/person-detail',
      '/tasks' => '/task-detail',
      '/changes-overview' => '/change-detail',
      '/your-homes' => index == 1 ? '/archived-home' : '/home',
      '/vault-folders' => index == 3 ? '/locked-evidence' : '/document-viewer',
      '/app-settings' => index == 0 ? '/notification-settings' : index == 1 ? '/accessibility-settings' : '/privacy-centre',
      '/invite-person-type' => '/invite-person',
      '/split-groups' => index == 0 ? '/split' : '/expense-history',
      '/recurring-payments' => '/recurring-payment-detail',
      _ => null,
    };
    if (spec.path == '/notifications') appState.markNotificationRead(index);
    if (spec.path == '/move-out-checklist') {
      appState.setMoveOutStep(title, !(appState.moveOutSteps[title] ?? false));
      return;
    }
    if (route != null) {
      context.push(route);
    } else {
      _showRecord(context, title, detail);
    }
  }

  void _showRecord(BuildContext context, String title, String? detail) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          if (detail != null) ...[
            const SizedBox(height: 8),
            Text(detail, style: Theme.of(context).textTheme.bodyLarge),
          ],
          const SizedBox(height: 20),
          HouselyButton(label: 'Done', onPressed: () => Navigator.pop(context)),
        ]),
      ),
    ),
  );
}

class _FormContent extends StatelessWidget {
  const _FormContent({required this.spec, required this.controller, required this.onChanged});
  final MvpScreenSpec spec;
  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var index = 0; index < spec.items.length; index++) ...[
        if (index == 0)
          HouselyField(
            label: spec.items[index].split('|').first,
            hint: spec.items[index].split('|').length > 1 ? spec.items[index].split('|')[1] : '',
            controller: controller,
            onChanged: (_) => onChanged(),
          )
        else
          HouselySelectionTile(
            title: spec.items[index].split('|').first,
            subtitle: spec.items[index].split('|').length > 1 ? spec.items[index].split('|').sublist(1).join(' · ') : null,
            icon: _itemIcon(spec.items[index]),
            selected: index == 1,
            onTap: () => _showPicker(context, spec.items[index].split('|').first),
          ),
        if (index != spec.items.length - 1) const SizedBox(height: HouselySpace.sm),
      ],
    ],
  );

  void _showPicker(BuildContext context, String title) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        HouselySelectionTile(title: 'Recommended', subtitle: 'Best fit for this Home', icon: Icons.auto_awesome_outlined, selected: true, onTap: () => Navigator.pop(context)),
        const SizedBox(height: 8),
        HouselySelectionTile(title: 'Choose another option', icon: Icons.tune_rounded, onTap: () => Navigator.pop(context)),
      ]),
    )),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: HouselySpace.sm),
    child: Text(label, style: Theme.of(context).textTheme.titleMedium),
  );
}

IconData _itemIcon(String value) {
  final text = value.toLowerCase();
  if (text.contains('privacy') || text.contains('access')) return Icons.lock_outline_rounded;
  if (text.contains('amount') || text.contains('balance') || text.contains('rent')) return Icons.payments_outlined;
  if (text.contains('date') || text.contains('due') || text.contains('start')) return Icons.calendar_month_outlined;
  if (text.contains('person') || text.contains('member') || text.contains('owner')) return Icons.person_outline_rounded;
  if (text.contains('document') || text.contains('file') || text.contains('evidence')) return Icons.description_outlined;
  return Icons.check_circle_outline_rounded;
}
