import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/components/components.dart';
import '../../design_system/theme/housely_tokens.dart';
import '../access/access_draft.dart';
import '../shared/feature_scaffold.dart';
import 'home_setup_state.dart';

String _money(int pence) => '£${(pence / 100).toStringAsFixed(2)}';

class HomeEntryScreen extends StatefulWidget {
  const HomeEntryScreen({
    required this.draft,
    required this.setupState,
    super.key,
  });

  final AccessDraft draft;
  final HomeSetupState setupState;

  @override
  State<HomeEntryScreen> createState() => _HomeEntryScreenState();
}

class _HomeEntryScreenState extends State<HomeEntryScreen> {
  bool _addOpen = false;

  String get _displayName {
    final name = widget.draft.name.trim();
    if (name.isEmpty) return 'there';
    return name.split(RegExp(r'\s+')).first;
  }

  List<String> get _unclaimedNames => widget.draft.detectedTenantNames
      .where((name) => name != widget.draft.matchedTenantName)
      .toList();

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.setupState,
    builder: (context, _) {
      final tenancyDone = widget.draft.tenancySetupComplete;
      final completed = widget.setupState.completedSteps(
        tenancyComplete: tenancyDone,
      );
      final progress = widget.setupState.progress(tenancyComplete: tenancyDone);

      return SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: HouselySize.maxContentWidth,
            ),
            child: Column(
              children: [
                _HomeHeader(
                  homeName: widget.draft.homeName.isEmpty
                      ? 'Your Home'
                      : widget.draft.homeName,
                  location: widget.draft.city.isEmpty
                      ? 'Home'
                      : widget.draft.city,
                  onMore: () => showHouselyMoreSheet(context),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Stack(
                    children: [
                      ListView(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 112),
                        children: [
                          Text(
                            'Welcome home, $_displayName 👋',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Your Home is ready. Add the essentials at your own pace.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: HouselyPalette.textSecondary),
                          ),
                          const SizedBox(height: HouselySpace.xl),
                          if (!widget.setupState.setupCardDismissed ||
                              completed == 5)
                            _SetupPanel(
                              completed: completed,
                              progress: progress,
                              tenancyDone: tenancyDone,
                              hasRent: widget.setupState.hasRent,
                              hasRecurring: widget.setupState.hasRecurringCosts,
                              householdOpened:
                                  widget.setupState.householdOpened,
                              moveInStarted:
                                  widget.setupState.moveInProtectionStarted,
                              onRent: () => context.push('/setup-rent'),
                              onRecurring: () =>
                                  context.push('/setup-recurring'),
                              onHousehold: () {
                                widget.setupState.markHouseholdOpened();
                                context.push('/household-management');
                              },
                              onMoveIn: () => context.push('/setup-move-in'),
                              onDismiss:
                                  widget.setupState.isComplete(
                                    tenancyComplete: tenancyDone,
                                  )
                                  ? null
                                  : widget.setupState.dismissSetupCard,
                            )
                          else
                            _ResumeSetupCard(
                              completed: completed,
                              onResume: widget.setupState.showSetupCard,
                            ),
                          const SizedBox(height: HouselySpace.xl),
                          _MoneySnapshot(
                            rentPence: widget.setupState.rentPence,
                            recurringPence:
                                widget.setupState.recurringMonthlyPence,
                            totalPence:
                                widget.setupState.monthlyCommitmentsPence,
                          ),
                          const SizedBox(height: HouselySpace.xl),
                          _SectionHeading(
                            title: 'Household',
                            action: 'Manage',
                            onTap: () {
                              widget.setupState.markHouseholdOpened();
                              context.push('/household-management');
                            },
                          ),
                          const SizedBox(height: HouselySpace.sm),
                          _HouseholdCard(
                            you:
                                widget.draft.matchedTenantName ??
                                widget.draft.name,
                            unclaimedNames: _unclaimedNames,
                            onInvite: () => context.push('/invite-home'),
                          ),
                          const SizedBox(height: HouselySpace.xl),
                          const _SectionHeading(title: 'Home records'),
                          const SizedBox(height: HouselySpace.sm),
                          HouselySurface(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (widget.draft.tenancyDocumentName != null)
                                  HouselyRecordRow(
                                    title: widget.draft.tenancyDocumentName!,
                                    subtitle: 'Tenancy agreement · Household',
                                    icon: Icons.description_outlined,
                                  )
                                else
                                  const HouselyMessageState(
                                    kind: HouselyMessageKind.empty,
                                    title: 'No tenancy document saved',
                                    message:
                                        'You can add documents whenever you are ready.',
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: HouselySpace.xl),
                          const _SectionHeading(title: 'Recent activity'),
                          const SizedBox(height: HouselySpace.sm),
                          const HouselyMessageState(
                            kind: HouselyMessageKind.empty,
                            title: 'Your Home is just getting started',
                            message:
                                'Payments, documents, expenses and household changes will appear here.',
                          ),
                        ],
                      ),
                      if (_addOpen)
                        Positioned.fill(
                          child: GestureDetector(
                            key: const ValueKey('home-add-scrim'),
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setState(() => _addOpen = false),
                            child: const ColoredBox(
                              color: HouselyPalette.scrim,
                            ),
                          ),
                        ),
                      Positioned(
                        right: 20,
                        bottom: 14,
                        child: _HomeAddMenu(
                          open: _addOpen,
                          onToggle: () => setState(() => _addOpen = !_addOpen),
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
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.homeName,
    required this.location,
    required this.onMore,
  });

  final String homeName;
  final String location;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
    child: Row(
      children: [
        const HomePulse(size: 40),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(homeName, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(location, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        HouselyIconButton(
          icon: Icons.grid_view_rounded,
          label: 'More',
          onPressed: onMore,
        ),
      ],
    ),
  );
}

class _SetupPanel extends StatelessWidget {
  const _SetupPanel({
    required this.completed,
    required this.progress,
    required this.tenancyDone,
    required this.hasRent,
    required this.hasRecurring,
    required this.householdOpened,
    required this.moveInStarted,
    required this.onRent,
    required this.onRecurring,
    required this.onHousehold,
    required this.onMoveIn,
    this.onDismiss,
  });

  final int completed;
  final double progress;
  final bool tenancyDone;
  final bool hasRent;
  final bool hasRecurring;
  final bool householdOpened;
  final bool moveInStarted;
  final VoidCallback onRent;
  final VoidCallback onRecurring;
  final VoidCallback onHousehold;
  final VoidCallback onMoveIn;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) => HouselySurface(
    color: HouselyPalette.violetSoft,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                completed == 5 ? 'Your Home is set up' : 'Set up your Home',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Text(
              '$completed of 5',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: HouselySpace.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(HouselyRadius.pill),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: HouselyPalette.surfacePressed,
          ),
        ),
        const SizedBox(height: HouselySpace.lg),
        _SetupRow(
          icon: Icons.verified_user_outlined,
          title: 'Tenancy identity',
          subtitle: tenancyDone ? 'Done' : 'Add later',
          done: tenancyDone,
          onTap: null,
        ),
        _SetupRow(
          icon: Icons.home_work_outlined,
          title: 'Add your rent',
          subtitle: hasRent
              ? 'Rent added'
              : 'Amount, due date and household commitment',
          done: hasRent,
          onTap: onRent,
        ),
        _SetupRow(
          icon: Icons.repeat_rounded,
          title: 'Add recurring payments',
          subtitle: hasRecurring
              ? 'Recurring costs added'
              : 'Energy, broadband, council tax',
          done: hasRecurring,
          onTap: onRecurring,
        ),
        _SetupRow(
          icon: Icons.people_outline_rounded,
          title: 'Connect your household',
          subtitle: householdOpened
              ? 'Household opened'
              : 'Invite people when you are ready',
          done: householdOpened,
          onTap: onHousehold,
        ),
        _SetupRow(
          icon: Icons.photo_camera_outlined,
          title: 'Protect your move-in',
          subtitle: moveInStarted
              ? 'Move-in protection started'
              : 'Timestamp photos and evidence',
          done: moveInStarted,
          onTap: onMoveIn,
        ),
        if (onDismiss != null) ...[
          const SizedBox(height: HouselySpace.sm),
          HouselyButton(
            label: 'I’ll finish this later',
            style: HouselyButtonStyle.text,
            onPressed: onDismiss,
          ),
        ],
      ],
    ),
  );
}

class _SetupRow extends StatelessWidget {
  const _SetupRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.done,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool done;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(HouselyRadius.control),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: done ? HouselyPalette.mintSoft : HouselyPalette.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              done ? Icons.check_rounded : icon,
              color: done ? HouselyPalette.mint : HouselyPalette.violet,
            ),
          ),
          const SizedBox(width: HouselySpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(
              Icons.chevron_right_rounded,
              color: HouselyPalette.textTertiary,
            ),
        ],
      ),
    ),
  );
}

class _ResumeSetupCard extends StatelessWidget {
  const _ResumeSetupCard({required this.completed, required this.onResume});

  final int completed;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) => HouselySurface(
    child: Row(
      children: [
        const Icon(Icons.auto_awesome_outlined, color: HouselyPalette.violet),
        const SizedBox(width: HouselySpace.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Finish setting up your Home',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '$completed of 5 essentials complete',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        TextButton(onPressed: onResume, child: const Text('Resume')),
      ],
    ),
  );
}

class _MoneySnapshot extends StatelessWidget {
  const _MoneySnapshot({
    required this.rentPence,
    required this.recurringPence,
    required this.totalPence,
  });

  final int rentPence;
  final int recurringPence;
  final int totalPence;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const _SectionHeading(title: 'This month'),
      const SizedBox(height: HouselySpace.sm),
      HouselySurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              totalPence == 0
                  ? 'No commitments added yet'
                  : '${_money(totalPence)} planned',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: HouselySpace.md),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: 'Rent',
                    value: rentPence == 0 ? 'Not added' : _money(rentPence),
                  ),
                ),
                const SizedBox(width: HouselySpace.sm),
                Expanded(
                  child: _Metric(
                    label: 'Recurring',
                    value: recurringPence == 0
                        ? 'Not added'
                        : _money(recurringPence),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(HouselySpace.md),
    decoration: BoxDecoration(
      color: HouselyPalette.surfaceRaised,
      borderRadius: BorderRadius.circular(HouselyRadius.control),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    ),
  );
}

class _HouseholdCard extends StatelessWidget {
  const _HouseholdCard({
    required this.you,
    required this.unclaimedNames,
    required this.onInvite,
  });

  final String you;
  final List<String> unclaimedNames;
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) => HouselySurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PersonRow(
          name: you.trim().isEmpty ? 'You' : you,
          status: 'You · Connected',
          connected: true,
        ),
        for (final name in unclaimedNames)
          _PersonRow(
            name: name,
            status: 'Named on tenancy · Unclaimed',
            connected: false,
          ),
        if (unclaimedNames.isNotEmpty) ...[
          const SizedBox(height: HouselySpace.md),
          HouselyButton(
            label: 'Invite to this Home',
            style: HouselyButtonStyle.secondary,
            leadingIcon: Icons.qr_code_rounded,
            onPressed: onInvite,
          ),
        ],
      ],
    ),
  );
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({
    required this.name,
    required this.status,
    required this.connected,
  });

  final String name;
  final String status;
  final bool connected;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: connected
              ? HouselyPalette.mintSoft
              : HouselyPalette.surfaceRaised,
          child: Icon(
            connected ? Icons.check_rounded : Icons.person_outline_rounded,
            color: connected
                ? HouselyPalette.mint
                : HouselyPalette.textSecondary,
          ),
        ),
        const SizedBox(width: HouselySpace.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: Theme.of(context).textTheme.titleMedium),
              Text(status, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
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
      if (action != null) TextButton(onPressed: onTap, child: Text(action!)),
    ],
  );
}

class _HomeAddMenu extends StatelessWidget {
  const _HomeAddMenu({required this.open, required this.onToggle});

  final bool open;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      if (open) ...[
        _AddAction(
          label: 'Expense',
          icon: Icons.receipt_long_outlined,
          onTap: () => context.push('/add-expense'),
        ),
        _AddAction(
          label: 'Recurring payment',
          icon: Icons.repeat_rounded,
          onTap: () => context.push('/setup-recurring'),
        ),
        _AddAction(
          label: 'Document',
          icon: Icons.upload_file_outlined,
          onTap: () => context.push('/upload-document'),
        ),
        _AddAction(
          label: 'Belonging',
          icon: Icons.chair_outlined,
          onTap: () => context.push('/add-item'),
        ),
        const SizedBox(height: 8),
      ],
      FloatingActionButton(
        onPressed: onToggle,
        child: Icon(open ? Icons.close_rounded : Icons.add_rounded),
      ),
    ],
  );
}

class _AddAction extends StatelessWidget {
  const _AddAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Material(
      color: HouselyPalette.surface,
      borderRadius: BorderRadius.circular(HouselyRadius.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(HouselyRadius.pill),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
        ),
      ),
    ),
  );
}

class AddRentSetupScreen extends StatefulWidget {
  const AddRentSetupScreen({required this.state, super.key});

  final HomeSetupState state;

  @override
  State<AddRentSetupScreen> createState() => _AddRentSetupScreenState();
}

class _AddRentSetupScreenState extends State<AddRentSetupScreen> {
  late final TextEditingController _amount = TextEditingController(
    text: widget.state.rentPence == 0
        ? ''
        : (widget.state.rentPence / 100).toStringAsFixed(2),
  );
  late final TextEditingController _dueDay = TextEditingController(
    text: widget.state.rentDueDay.toString(),
  );

  bool _showError = false;

  bool get _valid {
    final amount = double.tryParse(_amount.text.replaceAll(',', '.'));
    final dueDay = int.tryParse(_dueDay.text);
    return amount != null &&
        amount > 0 &&
        dueDay != null &&
        dueDay >= 1 &&
        dueDay <= 31;
  }

  void _save() {
    setState(() => _showError = !_valid);
    if (!_valid) return;

    final amount = double.parse(_amount.text.replaceAll(',', '.'));
    final dueDay = int.parse(_dueDay.text);

    widget.state.saveRent(amountPence: (amount * 100).round(), dueDay: dueDay);
    context.pop();
  }

  @override
  void dispose() {
    _amount.dispose();
    _dueDay.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FeatureScaffold(
    title: 'Add your rent',
    subtitle:
        'Add the recurring rent commitment. Payment automation can come later.',
    onBack: () => context.pop(),
    bottom: HouselyStickyAction(label: 'Save rent', onPressed: _save),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_showError) ...[
          const HouselyValidationSummary(
            errors: [
              'Enter a rent amount greater than zero.',
              'Use a due day from 1 to 31.',
            ],
          ),
          const SizedBox(height: HouselySpace.md),
        ],
        HouselyField(
          label: 'Monthly rent',
          hint: '850.00',
          type: HouselyFieldType.money,
          controller: _amount,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: HouselySpace.md),
        HouselyField(
          label: 'Due day of month',
          hint: '1',
          controller: _dueDay,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: HouselySpace.lg),
        const HouselyPrivacyNotice(
          title: 'No money moves yet',
          message:
              'For this prototype Housely records the rent commitment only. It does not initiate a payment.',
        ),
      ],
    ),
  );
}

class AddRecurringSetupScreen extends StatefulWidget {
  const AddRecurringSetupScreen({required this.state, super.key});

  final HomeSetupState state;

  @override
  State<AddRecurringSetupScreen> createState() =>
      _AddRecurringSetupScreenState();
}

class _AddRecurringSetupScreenState extends State<AddRecurringSetupScreen> {
  final _name = TextEditingController();
  final _amount = TextEditingController();
  String _frequency = 'Monthly';
  bool _showError = false;

  bool get _valid {
    final amount = double.tryParse(_amount.text.replaceAll(',', '.'));
    return _name.text.trim().isNotEmpty && amount != null && amount > 0;
  }

  void _save() {
    setState(() => _showError = !_valid);
    if (!_valid) return;

    final amount = double.parse(_amount.text.replaceAll(',', '.'));

    widget.state.addRecurringCost(
      name: _name.text.trim(),
      amountPence: (amount * 100).round(),
      frequency: _frequency,
    );

    context.pop();
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FeatureScaffold(
    title: 'Add recurring payment',
    subtitle: 'Keep regular household commitments visible in one place.',
    onBack: () => context.pop(),
    bottom: HouselyStickyAction(
      label: 'Save recurring payment',
      onPressed: _save,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_showError) ...[
          const HouselyValidationSummary(
            errors: [
              'Enter a payment name.',
              'Enter an amount greater than zero.',
            ],
          ),
          const SizedBox(height: HouselySpace.md),
        ],
        HouselyField(
          label: 'Payment name',
          hint: 'Council tax',
          controller: _name,
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: HouselySpace.md),
        HouselyField(
          label: 'Amount',
          hint: '165.00',
          type: HouselyFieldType.money,
          controller: _amount,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: HouselySpace.md),
        HouselySegmentedControl<String>(
          segments: const {
            'Monthly': 'Monthly',
            'Weekly': 'Weekly',
            'Yearly': 'Yearly',
          },
          selected: _frequency,
          onChanged: (value) => setState(() => _frequency = value),
        ),
      ],
    ),
  );
}

class MoveInSetupScreen extends StatelessWidget {
  const MoveInSetupScreen({required this.state, super.key});

  final HomeSetupState state;

  @override
  Widget build(BuildContext context) => FeatureScaffold(
    title: 'Protect your move-in',
    subtitle:
        'Start a timestamped evidence record for the condition of your Home.',
    onBack: () => context.pop(),
    bottom: HouselyStickyAction(
      label: 'Start move-in protection',
      onPressed: () {
        state.markMoveInProtectionStarted();
        context.pop();
      },
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HouselyPrivacyNotice(
          title: 'Capture once, keep the history',
          message:
              'Photos and videos can later be stored with timestamps and an audit trail. This prototype marks the setup step as started.',
        ),
        SizedBox(height: HouselySpace.lg),
        HouselyMessageState(
          kind: HouselyMessageKind.empty,
          title: 'No evidence captured yet',
          message:
              'A future step will guide the user room-by-room and preserve the original capture metadata.',
        ),
      ],
    ),
  );
}
