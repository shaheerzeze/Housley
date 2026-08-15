import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/components/components.dart';
import '../../design_system/theme/housely_tokens.dart';
import '../shared/feature_scaffold.dart';
import 'split_state.dart';

String money(int pence) => '£${(pence / 100).toStringAsFixed(2)}';

class SplitOverviewScreen extends StatefulWidget {
  const SplitOverviewScreen({required this.state, super.key});
  final SplitFeatureState state;
  @override
  State<SplitOverviewScreen> createState() => _SplitOverviewScreenState();
}

class _SplitOverviewScreenState extends State<SplitOverviewScreen> {
  String scope = 'Household';

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.state,
    builder: (context, _) {
      final visible = widget.state.expenses
          .where((expense) => expense.scope == scope)
          .toList();
      return SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: HouselySize.maxContentWidth,
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                HouselySize.phoneGutter,
                HouselySpace.md,
                HouselySize.phoneGutter,
                HouselySpace.section,
              ),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Split',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                    HouselyIconButton(
                      icon: Icons.group_work_outlined,
                      label: 'Private groups',
                      onPressed: () => context.push('/private-groups'),
                    ),
                  ],
                ),
                const SizedBox(height: HouselySpace.lg),
                HouselySegmentedControl<String>(
                  segments: const {
                    'Household': 'Household',
                    'Private group': 'Private group',
                  },
                  selected: scope,
                  onChanged: (value) => setState(() => scope = value),
                ),
                const SizedBox(height: HouselySpace.lg),
                if (scope == 'Household')
                  HouselyBalanceSummary(
                    amount: money(widget.state.balancePence),
                    label: 'You are owed overall',
                  )
                else
                  const HouselyBalanceSummary(
                    amount: '£24.00',
                    label: 'You are owed across private groups',
                  ),
                const SizedBox(height: HouselySpace.lg),
                HouselySection(
                  title: 'Recent expenses',
                  child: visible.isEmpty
                      ? const HouselyMessageState(
                          kind: HouselyMessageKind.empty,
                          title: 'No expenses here',
                          message: 'Add the first expense in this scope.',
                        )
                      : HouselyGroupedList(
                          children: visible
                              .map(
                                (expense) => HouselyMoneyRow(
                                  title: expense.title,
                                  detail:
                                      'Paid by ${expense.payer} · ${expense.scope}',
                                  amount: money(expense.amountPence),
                                  paid: expense.payer == 'You',
                                ),
                              )
                              .toList(),
                        ),
                ),
                const SizedBox(height: HouselySpace.xl),
                HouselyButton(
                  label: 'Add expense',
                  leadingIcon: Icons.add_rounded,
                  onPressed: () => context.push('/add-expense'),
                ),
                const SizedBox(height: HouselySpace.sm),
                HouselyButton(
                  label: 'Record settlement',
                  style: HouselyButtonStyle.secondary,
                  onPressed: () => context.push('/record-settlement'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({required this.state, super.key});
  final SplitFeatureState state;
  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  late final title = TextEditingController(text: widget.state.draft.title);
  late final amount = TextEditingController(
    text: widget.state.draft.amountPence == 0
        ? ''
        : (widget.state.draft.amountPence / 100).toStringAsFixed(2),
  );
  bool receipt = false;
  bool showError = false;

  void next() {
    final parsed = double.tryParse(amount.text.replaceAll(',', '.'));
    if (title.text.trim().isEmpty || parsed == null || parsed <= 0) {
      setState(() => showError = true);
      return;
    }
    widget.state.draft
      ..title = title.text.trim()
      ..amountPence = (parsed * 100).round();
    context.push('/choose-people');
  }

  @override
  void dispose() {
    title.dispose();
    amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FeatureScaffold(
    title: 'Add expense',
    subtitle: 'Record the source facts first. You’ll choose participants next.',
    onBack: () => context.pop(),
    bottom: HouselyStickyAction(label: 'Continue', onPressed: next),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HouselyScopeBadge(
          scope: widget.state.draft.scope == 'Household'
              ? HouselyScope.household
              : HouselyScope.privateGroup,
        ),
        const SizedBox(height: HouselySpace.lg),
        if (showError) ...[
          const HouselyValidationSummary(
            errors: [
              'Enter an expense title.',
              'Enter an amount greater than zero.',
            ],
          ),
          const SizedBox(height: HouselySpace.md),
        ],
        HouselyField(
          label: 'Expense title',
          hint: 'Weekly shop',
          controller: title,
        ),
        const SizedBox(height: HouselySpace.md),
        HouselyField(
          label: 'Amount',
          hint: '0.00',
          type: HouselyFieldType.money,
          controller: amount,
        ),
        const SizedBox(height: HouselySpace.md),
        const HouselySelectionTile(
          title: 'Paid by you',
          subtitle: 'Today · GBP',
          icon: Icons.account_circle_outlined,
          selected: true,
          onTap: null,
        ),
        const SizedBox(height: HouselySpace.md),
        HouselyCheckbox(
          label: 'Attach a receipt',
          supportingText:
              'You can upload the file after the expense is created.',
          value: receipt,
          onChanged: (value) => setState(() => receipt = value ?? false),
        ),
      ],
    ),
  );
}

class ChoosePeopleScreen extends StatefulWidget {
  const ChoosePeopleScreen({required this.state, super.key});
  final SplitFeatureState state;
  @override
  State<ChoosePeopleScreen> createState() => _ChoosePeopleScreenState();
}

class _ChoosePeopleScreenState extends State<ChoosePeopleScreen> {
  final people = const ['You', 'Alex', 'Sam'];

  @override
  Widget build(BuildContext context) {
    final draft = widget.state.draft;
    final each = draft.people.isEmpty
        ? 0
        : draft.amountPence ~/ draft.people.length;
    return FeatureScaffold(
      title: 'Choose people',
      subtitle: 'Only members of this expense scope can participate.',
      onBack: () => context.pop(),
      bottom: HouselyStickyAction(
        label: 'Review expense',
        onPressed: draft.people.isEmpty
            ? null
            : () => context.push('/review-expense'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HouselySegmentedControl<String>(
            segments: const {
              'Equal': 'Equal',
              'Amounts': 'Amounts',
              'Percent': 'Percent',
            },
            selected: draft.method,
            onChanged: (value) => setState(() => draft.method = value),
          ),
          const SizedBox(height: HouselySpace.lg),
          HouselyGroupedList(
            children: people
                .map(
                  (person) => HouselyCheckbox(
                    label: person,
                    supportingText: draft.people.contains(person)
                        ? '${money(each)} share'
                        : 'Not included',
                    value: draft.people.contains(person),
                    onChanged: (value) => setState(() {
                      if (value == true) {
                        draft.people.add(person);
                      } else {
                        draft.people.remove(person);
                      }
                    }),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: HouselySpace.md),
          HouselyPrivacyNotice(
            title: 'Rounding stays explicit',
            message:
                'Any remainder is assigned by the server when saved. This preview shows the nearest penny.',
          ),
        ],
      ),
    );
  }
}

class ReviewExpenseScreen extends StatefulWidget {
  const ReviewExpenseScreen({required this.state, super.key});
  final SplitFeatureState state;
  @override
  State<ReviewExpenseScreen> createState() => _ReviewExpenseScreenState();
}

class _ReviewExpenseScreenState extends State<ReviewExpenseScreen> {
  bool saving = false;
  Future<void> save() async {
    setState(() => saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    widget.state.addExpense();
    if (mounted) context.go('/split');
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.state.draft;
    return FeatureScaffold(
      title: 'Review expense',
      subtitle: 'Check the scope, amount and participants before saving.',
      onBack: () => context.pop(),
      bottom: HouselyStickyAction(
        label: 'Add expense',
        onPressed: saving ? null : save,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HouselyBalanceSummary(
            amount: money(draft.amountPence),
            label: draft.title,
          ),
          const SizedBox(height: HouselySpace.lg),
          HouselyGroupedList(
            children: [
              HouselyRecordRow(
                title: draft.scope,
                subtitle: 'Expense scope',
                icon: Icons.home_outlined,
              ),
              HouselyRecordRow(
                title: draft.people.join(', '),
                subtitle: '${draft.method} split',
                icon: Icons.people_outline_rounded,
              ),
              HouselyRecordRow(
                title: 'Paid by ${draft.payer}',
                subtitle: 'Today · GBP',
                icon: Icons.account_balance_wallet_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PrivateGroupsScreen extends StatelessWidget {
  const PrivateGroupsScreen({required this.state, super.key});
  final SplitFeatureState state;
  @override
  Widget build(BuildContext context) => FeatureScaffold(
    title: 'Private groups',
    subtitle:
        'Friends and costs outside your Home stay separate from Household access.',
    onBack: () => context.pop(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HouselyPrivacyNotice(
          title: 'Private means membership-only',
          message:
              'Being part of George Street Flat does not reveal any group, balance or participant here.',
        ),
        const SizedBox(height: HouselySpace.lg),
        HouselyGroupedList(
          children: [
            HouselyRecordRow(
              title: 'Festival weekend',
              subtitle: '4 people · You are owed £24.00',
              icon: Icons.lock_outline_rounded,
              iconColor: HouselyPalette.violet,
              onTap: () {},
            ),
            HouselyRecordRow(
              title: 'Sunday football',
              subtitle: '7 people · Settled',
              icon: Icons.lock_outline_rounded,
              iconColor: HouselyPalette.mint,
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: HouselySpace.xl),
        HouselyButton(
          label: 'Create private group',
          leadingIcon: Icons.add_rounded,
          onPressed: () {},
        ),
      ],
    ),
  );
}

class RecordSettlementScreen extends StatefulWidget {
  const RecordSettlementScreen({required this.state, super.key});
  final SplitFeatureState state;
  @override
  State<RecordSettlementScreen> createState() => _RecordSettlementScreenState();
}

class _RecordSettlementScreenState extends State<RecordSettlementScreen> {
  final amount = TextEditingController();
  bool error = false;
  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  void save() {
    final value = double.tryParse(amount.text.replaceAll(',', '.'));
    if (value == null || value <= 0) {
      setState(() => error = true);
      return;
    }
    widget.state.settle((value * 100).round());
    context.go('/split');
  }

  @override
  Widget build(BuildContext context) => FeatureScaffold(
    title: 'Record settlement',
    subtitle:
        'Record a payment that happened elsewhere. Housely does not move money.',
    onBack: () => context.pop(),
    bottom: HouselyStickyAction(label: 'Mark as settled', onPressed: save),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HouselyPrivacyNotice(
          title: 'No bank transfer occurs',
          message:
              'This changes balances and history only. Confirm the real payment with the other person.',
        ),
        const SizedBox(height: HouselySpace.lg),
        const HouselySelectionTile(
          title: 'Alex paid you',
          subtitle: 'Household · Manual settlement',
          icon: Icons.compare_arrows_rounded,
          selected: true,
          onTap: null,
        ),
        const SizedBox(height: HouselySpace.md),
        HouselyField(
          label: 'Amount',
          hint: '0.00',
          type: HouselyFieldType.money,
          controller: amount,
          state: error
              ? HouselyComponentState.error
              : HouselyComponentState.idle,
          errorText: 'Enter an amount greater than zero.',
        ),
        const SizedBox(height: HouselySpace.md),
        const HouselyField(
          label: 'Settlement date',
          hint: 'Today',
          type: HouselyFieldType.date,
        ),
      ],
    ),
  );
}
