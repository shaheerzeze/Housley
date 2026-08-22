import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/components/components.dart';
import '../../design_system/theme/housely_tokens.dart';
import '../shared/feature_scaffold.dart';
import 'mvp_catalog.dart';

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
  const MvpScreen({required this.spec, super.key});
  final MvpScreenSpec spec;

  @override
  State<MvpScreen> createState() => _MvpScreenState();
}

class _MvpScreenState extends State<MvpScreen> {
  final _controller = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(String? path) {
    if (path == null) return;
    setState(() => _busy = true);
    Future<void>.delayed(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      if (path.startsWith('/')) context.go(path);
    });
  }

  @override
  Widget build(BuildContext context) {
    final spec = widget.spec;
    return FeatureScaffold(
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
          _Hero(spec: spec),
          if (spec.items.isNotEmpty) ...[
            const SizedBox(height: HouselySpace.xxl),
            if (spec.kind == MvpScreenKind.form)
              _FormContent(spec: spec, controller: _controller, onChanged: () => setState(() {}))
            else
              _RecordContent(spec: spec),
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

class _RecordContent extends StatelessWidget {
  const _RecordContent({required this.spec});
  final MvpScreenSpec spec;

  @override
  Widget build(BuildContext context) => HouselyGroupedList(
    children: spec.items.map((raw) {
      final parts = raw.split('|');
      return HouselyRecordRow(
        title: parts.first,
        subtitle: parts.length > 1 ? parts.sublist(1).join(' · ') : null,
        icon: _itemIcon(parts.first),
        onTap: spec.kind == MvpScreenKind.list
            ? () => _showRecord(context, parts.first, parts.length > 1 ? parts.sublist(1).join(' · ') : null)
            : null,
      );
    }).toList(),
  );

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
