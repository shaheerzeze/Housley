import 'package:flutter/material.dart';

import '../components/components.dart';
import '../theme/housely_tokens.dart';

class PatternCatalogue extends StatefulWidget {
  const PatternCatalogue({super.key});

  @override
  State<PatternCatalogue> createState() => _PatternCatalogueState();
}

class _PatternCatalogueState extends State<PatternCatalogue> {
  HouselyDestination _destination = HouselyDestination.home;
  double _ownership = 50;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: HouselyTopBar(
      title: 'Pattern catalogue',
      actions: [
        HouselyIconButton(
          icon: Icons.grid_view_rounded,
          label: 'More',
          onPressed: () => showHouselyMoreSheet(context),
        ),
        const SizedBox(width: HouselySpace.xs),
      ],
    ),
    bottomNavigationBar: HouselyBottomDock(
      selected: _destination,
      onSelected: (value) => setState(() => _destination = value),
    ),
    body: SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: HouselySize.maxContentWidth,
            ),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                constraints.maxWidth >= 700
                    ? HouselySize.tabletGutter
                    : HouselySize.phoneGutter,
                HouselySpace.lg,
                constraints.maxWidth >= 700
                    ? HouselySize.tabletGutter
                    : HouselySize.phoneGutter,
                HouselySpace.section,
              ),
              children: [
                const HouselyHomeIdentity(
                  name: 'George Street Flat',
                  address: 'Edinburgh · Household',
                  members: ['Muhammad Shaheer', 'Alex Morgan', 'Sam Lee'],
                ),
                const SizedBox(height: HouselySpace.section),
                HouselySection(
                  title: 'Command centre',
                  caption: 'Information-rich, calm and always actionable.',
                  child: Column(
                    children: [
                      const HouselyBalanceSummary(
                        amount: '+£126.40',
                        label: 'You are owed overall',
                      ),
                      const SizedBox(height: HouselySpace.md),
                      Row(
                        children: [
                          Expanded(
                            child: HouselyQuickAction(
                              label: 'Add expense',
                              icon: Icons.add_rounded,
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: HouselySpace.sm),
                          Expanded(
                            child: HouselyQuickAction(
                              label: 'Upload file',
                              icon: Icons.upload_file_outlined,
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: HouselySpace.sm),
                          Expanded(
                            child: HouselyQuickAction(
                              label: 'Add item',
                              icon: Icons.add_box_outlined,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: HouselySpace.section),
                HouselySection(
                  title: 'Connected records',
                  caption:
                      'A single row grammar carries context, state and destination.',
                  child: HouselyGroupedList(
                    children: [
                      HouselyAttentionRow(
                        title: 'Electricity is due',
                        detail: 'Due tomorrow · Household',
                        amount: '£84.20',
                        actionLabel: 'Review',
                        onTap: () {},
                      ),
                      HouselyMoneyRow(
                        title: 'Weekly shop',
                        detail: 'Paid by Alex · 12 Aug',
                        amount: '£42.60',
                        onTap: () {},
                      ),
                      const HouselyFileRow(
                        title: 'Tenancy agreement',
                        metadata: 'PDF · Uploaded 4 Aug',
                      ),
                      const HouselyMemberRow(
                        name: 'Alex Morgan',
                        role: 'Member',
                        status: 'Pending',
                      ),
                      const HouselyOwnershipRow(
                        owner: 'Muhammad Shaheer',
                        share: '50%',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: HouselySpace.section),
                const HouselySection(
                  title: 'Privacy and validation',
                  caption:
                      'Sensitive boundaries are explained at the point of action.',
                  child: Column(
                    children: [
                      HouselyPrivacyNotice(
                        title: 'Private group',
                        message:
                            'Only selected members can see these expenses. Home admins do not gain access.',
                      ),
                      SizedBox(height: HouselySpace.md),
                      HouselyValidationSummary(
                        errors: [
                          'Ownership shares must total 100%.',
                          'Choose a visibility scope.',
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: HouselySpace.section),
                HouselySection(
                  title: 'Files and evidence',
                  caption:
                      'Preview, provenance and room progress stay visually connected.',
                  child: Column(
                    children: [
                      const HouselyFilePreview(
                        title: 'Tenancy agreement.pdf',
                        metadata: 'Household · Uploaded by you · 4 Aug 2026',
                      ),
                      const SizedBox(height: HouselySpace.md),
                      HouselyChecklistCard(
                        title: 'Kitchen',
                        completed: 6,
                        total: 8,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: HouselySpace.section),
                HouselySection(
                  title: 'Ownership',
                  caption:
                      'Large controls make exact shares understandable and adjustable.',
                  child: HouselyOwnershipEditor(
                    owner: 'Muhammad Shaheer',
                    value: _ownership,
                    onChanged: (value) => setState(() => _ownership = value),
                  ),
                ),
                const SizedBox(height: HouselySpace.section),
                HouselySection(
                  title: 'Feedback states',
                  caption:
                      'Every state explains what happened and what to do next.',
                  child: Column(
                    children: [
                      HouselyMessageState(
                        kind: HouselyMessageKind.empty,
                        title: 'No documents yet',
                        message:
                            'Upload the first household file so everyone can find it.',
                        actionLabel: 'Upload document',
                        onAction: () {},
                      ),
                      const SizedBox(height: HouselySpace.md),
                      const HouselyMessageState(
                        kind: HouselyMessageKind.offline,
                        title: 'You’re offline',
                        message:
                            'Showing saved details from 10 minutes ago. Final actions will wait for a connection.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: HouselySpace.section),
                HouselySection(
                  title: 'Sheets and confirmations',
                  caption:
                      'Unsaved and destructive actions never happen silently.',
                  child: Column(
                    children: [
                      HouselyButton(
                        label: 'Preview draft sheet',
                        style: HouselyButtonStyle.secondary,
                        onPressed: () => showHouselyDraftSheet(context),
                      ),
                      const SizedBox(height: HouselySpace.sm),
                      HouselyButton(
                        label: 'Preview destructive confirmation',
                        style: HouselyButtonStyle.destructive,
                        onPressed: () => showHouselyConfirmation(
                          context,
                          title: 'Remove Alex from this Home?',
                          message:
                              'Alex will lose Household access after unresolved records are completed.',
                          confirmLabel: 'Review impact',
                          destructive: true,
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
    ),
  );
}
