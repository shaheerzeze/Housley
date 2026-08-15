import 'dart:async';

import 'package:flutter/material.dart';

import '../components/components.dart';
import '../theme/housely_tokens.dart';

enum _SplitMethod { equal, amounts, percent }

class DesignSystemShowcase extends StatefulWidget {
  const DesignSystemShowcase({super.key});

  @override
  State<DesignSystemShowcase> createState() => _DesignSystemShowcaseState();
}

class _DesignSystemShowcaseState extends State<DesignSystemShowcase> {
  HouselyComponentState _previewState = HouselyComponentState.idle;
  bool _privacyEnabled = true;
  bool _receiptRequired = false;
  String _visibility = 'Household';
  _SplitMethod _splitMethod = _SplitMethod.equal;
  bool _dueSoon = true;
  bool _selectedTile = true;
  double _uploadProgress = .64;

  void _runPrimaryAction() {
    setState(() => _previewState = HouselyComponentState.loading);
    Timer(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() => _previewState = HouselyComponentState.success);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final gutter = constraints.maxWidth >= 700
                ? HouselySize.tabletGutter
                : HouselySize.phoneGutter;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: HouselySize.maxContentWidth,
                ),
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(gutter, 24, gutter, 64),
                      sliver: SliverList.list(
                        children: [
                          const _CatalogueHeader(),
                          const SizedBox(height: HouselySpace.xxl),
                          _StatePicker(
                            selected: _previewState,
                            onChanged: (value) =>
                                setState(() => _previewState = value),
                          ),
                          const SizedBox(height: HouselySpace.section),
                          _buttons(context),
                          const SizedBox(height: HouselySpace.section),
                          _fields(),
                          const SizedBox(height: HouselySpace.section),
                          _selections(),
                          const SizedBox(height: HouselySpace.section),
                          _badgesAndIdentity(),
                          const SizedBox(height: HouselySpace.section),
                          _progress(),
                          const SizedBox(height: HouselySpace.section),
                          const _Skeletons(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buttons(BuildContext context) => HouselySection(
    title: 'Buttons',
    caption: 'Stable geometry, 48dp targets and explicit outcome states.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HouselyButton(
          label: _previewState == HouselyComponentState.success
              ? 'Expense added'
              : _previewState == HouselyComponentState.error
              ? 'Try again'
              : 'Add expense',
          state: _previewState,
          leadingIcon: Icons.add_rounded,
          onPressed: _runPrimaryAction,
        ),
        const SizedBox(height: HouselySpace.sm),
        HouselyButton(
          label: 'Save draft',
          style: HouselyButtonStyle.secondary,
          state: _previewState,
          onPressed: () {},
        ),
        const SizedBox(height: HouselySpace.sm),
        Wrap(
          spacing: HouselySpace.xs,
          runSpacing: HouselySpace.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            HouselyButton(
              label: 'Not now',
              style: HouselyButtonStyle.text,
              expand: false,
              onPressed: () {},
            ),
            HouselyButton(
              label: 'Remove member',
              style: HouselyButtonStyle.destructive,
              expand: false,
              onPressed: () {},
            ),
            HouselyIconButton(
              icon: Icons.notifications_none_rounded,
              label: 'Notifications',
              selected: true,
              onPressed: () {},
            ),
            const HouselyIconButton(
              icon: Icons.more_horiz_rounded,
              label: 'More options, disabled',
              onPressed: null,
            ),
          ],
        ),
      ],
    ),
  );

  Widget _fields() => HouselySection(
    title: 'Fields',
    caption: 'Visible labels, purpose-built keyboards and inline feedback.',
    child: Column(
      children: [
        HouselyField(
          label: 'Expense title',
          hint: 'Weekly shop',
          state: _previewState,
          errorText: 'Enter a clear expense title.',
        ),
        const SizedBox(height: HouselySpace.md),
        const HouselyField(
          label: 'Email address',
          hint: 'name@example.com',
          type: HouselyFieldType.email,
        ),
        const SizedBox(height: HouselySpace.md),
        const HouselyField(
          label: 'Password',
          type: HouselyFieldType.password,
          helperText: 'Use at least 12 characters.',
        ),
        const SizedBox(height: HouselySpace.md),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: HouselyField(
                label: 'Amount',
                hint: '0.00',
                type: HouselyFieldType.money,
              ),
            ),
            SizedBox(width: HouselySpace.sm),
            Expanded(
              child: HouselyField(
                label: 'Date',
                hint: '13 Aug 2026',
                type: HouselyFieldType.date,
              ),
            ),
          ],
        ),
        const SizedBox(height: HouselySpace.md),
        const HouselyField(
          label: 'Search documents',
          hint: 'Tenancy agreement',
          type: HouselyFieldType.search,
        ),
      ],
    ),
  );

  Widget _selections() => HouselySection(
    title: 'Selections',
    caption:
        'Native controls where familiarity matters; branded framing where scope matters.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HouselySurface(
          child: Column(
            children: [
              HouselyCheckbox(
                label: 'Attach a receipt',
                supportingText:
                    'Receipts remain private to this expense scope.',
                value: _receiptRequired,
                onChanged: (value) =>
                    setState(() => _receiptRequired = value ?? false),
              ),
              const Divider(),
              RadioGroup<String>(
                groupValue: _visibility,
                onChanged: (value) {
                  if (value != null) setState(() => _visibility = value);
                },
                child: const Column(
                  children: [
                    HouselyRadio<String>(
                      label: 'Household',
                      value: 'Household',
                    ),
                    HouselyRadio<String>(label: 'Personal', value: 'Personal'),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Private previews',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: HouselySpace.xxs),
                        Text(
                          'Hide titles on the lock screen.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  HouselyAdaptiveSwitch(
                    semanticLabel: 'Private previews',
                    value: _privacyEnabled,
                    onChanged: (value) =>
                        setState(() => _privacyEnabled = value),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: HouselySpace.md),
        HouselySegmentedControl<_SplitMethod>(
          segments: const {
            _SplitMethod.equal: 'Equal',
            _SplitMethod.amounts: 'Amounts',
            _SplitMethod.percent: 'Percent',
          },
          selected: _splitMethod,
          onChanged: (value) => setState(() => _splitMethod = value),
        ),
        const SizedBox(height: HouselySpace.md),
        Wrap(
          spacing: HouselySpace.xs,
          runSpacing: HouselySpace.xs,
          children: [
            HouselyFilterChip(
              label: 'Due soon',
              count: 3,
              selected: _dueSoon,
              onSelected: (value) => setState(() => _dueSoon = value),
            ),
            HouselyFilterChip(
              label: 'Changes',
              count: 1,
              selected: !_dueSoon,
              onSelected: (value) => setState(() => _dueSoon = !value),
            ),
          ],
        ),
        const SizedBox(height: HouselySpace.md),
        HouselySelectionTile(
          title: 'Household expense',
          subtitle: 'Visible to everyone in George Street Flat',
          icon: Icons.home_outlined,
          selected: _selectedTile,
          onTap: () => setState(() => _selectedTile = !_selectedTile),
        ),
      ],
    ),
  );

  Widget _badgesAndIdentity() => HouselySection(
    title: 'Identity and status',
    caption:
        'Privacy scope and record status are always written, never colour-only.',
    child: HouselySurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Wrap(
            spacing: HouselySpace.xs,
            runSpacing: HouselySpace.xs,
            children: [
              HouselyScopeBadge(scope: HouselyScope.personal),
              HouselyScopeBadge(scope: HouselyScope.household),
              HouselyScopeBadge(scope: HouselyScope.privateGroup),
              HouselyStatusPill(label: 'Pending'),
              HouselyStatusPill(label: 'Paid', status: HouselyStatus.success),
              HouselyStatusPill(label: 'Due', status: HouselyStatus.attention),
            ],
          ),
          const SizedBox(height: HouselySpace.xl),
          const Row(
            children: [
              HouselyAvatar(
                name: 'Muhammad Shaheer',
                size: 48,
                statusColor: HouselyPalette.mint,
              ),
              SizedBox(width: HouselySpace.md),
              Expanded(
                child: HouselyAvatarGroup(
                  names: [
                    'Alex Morgan',
                    'Sam Lee',
                    'Jamie Wilson',
                    'Taylor Khan',
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _progress() => HouselySection(
    title: 'Progress',
    caption:
        'Determinate progress for real work; explicit recovery when uploads fail.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HouselyProgress(value: _uploadProgress, label: 'Move-in record · 64%'),
        const SizedBox(height: HouselySpace.lg),
        HouselyUploadProgress(
          fileName: 'Tenancy agreement.pdf',
          progress: _uploadProgress,
          onCancel: () => setState(() => _uploadProgress = 0),
        ),
        const SizedBox(height: HouselySpace.sm),
        const HouselyUploadProgress(
          fileName: 'Kitchen window.jpg',
          progress: 1,
          complete: true,
        ),
        const SizedBox(height: HouselySpace.sm),
        const HouselyUploadProgress(
          fileName: 'Meter reading.jpg',
          progress: .32,
          error: 'Upload paused. Check your connection and retry.',
        ),
      ],
    ),
  );
}

class _CatalogueHeader extends StatelessWidget {
  const _CatalogueHeader();

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const HomePulse(size: 48),
      const SizedBox(width: HouselySpace.md),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Primitive catalogue',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: HouselySpace.xs),
            Text(
              'Phase 2 · Interactive system',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      const HouselyStatusPill(label: 'Live', status: HouselyStatus.success),
    ],
  );
}

class _StatePicker extends StatelessWidget {
  const _StatePicker({required this.selected, required this.onChanged});
  final HouselyComponentState selected;
  final ValueChanged<HouselyComponentState> onChanged;

  @override
  Widget build(BuildContext context) => HouselySection(
    title: 'Preview states',
    caption: 'Change the shared state to inspect component behaviour.',
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: HouselyComponentState.values
            .map(
              (state) => Padding(
                padding: const EdgeInsets.only(right: HouselySpace.xs),
                child: HouselyFilterChip(
                  label: state.name[0].toUpperCase() + state.name.substring(1),
                  selected: state == selected,
                  onSelected: (_) => onChanged(state),
                ),
              ),
            )
            .toList(),
      ),
    ),
  );
}

class _Skeletons extends StatelessWidget {
  const _Skeletons();

  @override
  Widget build(BuildContext context) => const HouselySection(
    title: 'Skeletons',
    caption: 'Reserved space prevents layout jumps while lists load.',
    child: HouselySurface(
      child: Row(
        children: [
          HouselySkeleton(width: 48, height: 48, radius: HouselyRadius.pill),
          SizedBox(width: HouselySpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HouselySkeleton(width: 180, height: 16),
                SizedBox(height: HouselySpace.xs),
                HouselySkeleton(height: 13),
                SizedBox(height: HouselySpace.xs),
                HouselySkeleton(width: 120, height: 13),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
