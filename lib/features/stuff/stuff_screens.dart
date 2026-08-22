import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/components/components.dart';
import '../../design_system/theme/housely_tokens.dart';
import '../shared/feature_scaffold.dart';
import 'stuff_state.dart';

String itemMoney(int pence) => '£${(pence / 100).toStringAsFixed(2)}';

class StuffOverviewScreen extends StatefulWidget {
  const StuffOverviewScreen({required this.state, super.key});
  final StuffFeatureState state;
  @override
  State<StuffOverviewScreen> createState() => _StuffOverviewScreenState();
}

class _StuffOverviewScreenState extends State<StuffOverviewScreen> {
  String filter = 'All';
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.state,
    builder: (context, _) => SafeArea(
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
                      'Stuff',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  HouselyIconButton(
                    icon: Icons.add_rounded,
                    label: 'Add item',
                    onPressed: () => context.push('/add-item'),
                  ),
                ],
              ),
              const SizedBox(height: HouselySpace.md),
              Wrap(
                spacing: 8,
                children: ['All', 'Shared', 'Personal']
                    .map(
                      (value) => HouselyFilterChip(
                        label: value,
                        selected: filter == value,
                        onSelected: (_) => setState(() => filter = value),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: HouselySpace.md),
              HouselyRecordCard(
                color: HouselyPalette.apricot,
                onTap: () => context.push('/item-detail'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const HouselyScopeBadge(scope: HouselyScope.household),
                        const Spacer(),
                        Text(
                          '50% yours',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: HouselySpace.lg),
                    Text(
                      'Living room sofa',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Shared with Alex · Warranty ends soon',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: HouselySpace.xl),
              HouselySection(
                title: 'Your belongings',
                child: HouselyGroupedList(
                  children: widget.state.items
                      .map(
                        (item) => HouselyRecordRow(
                          title: item.name,
                          subtitle:
                              '${item.location} · ${itemMoney(item.valuePence)}',
                          icon: Icons.chair_outlined,
                          onTap: () => context.push('/item-detail'),
                        ),
                      )
                      .toList(),
                  ),
              ),
              const SizedBox(height: HouselySpace.xl),
              HouselySection(
                title: 'Inventory tools',
                child: HouselyGroupedList(
                  children: [
                    HouselyRecordRow(
                      title: 'Search inventory',
                      subtitle: 'Find by owner, room or warranty',
                      icon: Icons.search_rounded,
                      onTap: () => context.push('/inventory-search'),
                    ),
                    HouselyRecordRow(
                      title: 'Scan a barcode',
                      subtitle: 'Add supported items more quickly',
                      icon: Icons.qr_code_scanner_rounded,
                      onTap: () => context.push('/scan-item'),
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

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({required this.state, super.key});
  final StuffFeatureState state;
  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final name = TextEditingController();
  final value = TextEditingController();
  bool photo = false;
  @override
  void dispose() {
    name.dispose();
    value.dispose();
    super.dispose();
  }

  void next() {
    final amount = double.tryParse(value.text) ?? 0;
    if (name.text.trim().isEmpty) return;
    widget.state
      ..draftName = name.text.trim()
      ..draftValuePence = (amount * 100).round();
    context.push('/set-ownership');
  }

  @override
  Widget build(BuildContext context) => FeatureScaffold(
    title: 'Add item',
    subtitle:
        'Start with useful details. Receipts and warranties can be linked later.',
    onBack: () => context.pop(),
    bottom: HouselyStickyAction(
      label: 'Continue',
      onPressed: name.text.trim().isEmpty ? null : next,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HouselySelectionTile(
          title: photo ? 'Item photo ready' : 'Add photo or scan barcode',
          subtitle: photo
              ? 'Living-room-sofa.jpg'
              : 'Optional · Helps identify this item later',
          icon: Icons.photo_camera_outlined,
          selected: photo,
          onTap: () => setState(() => photo = true),
        ),
        const SizedBox(height: 16),
        HouselyField(
          label: 'Item name',
          hint: 'Living room sofa',
          controller: name,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        const HouselyField(label: 'Location', hint: 'Living room'),
        const SizedBox(height: 16),
        HouselyField(
          label: 'Purchase price',
          hint: '0.00',
          type: HouselyFieldType.money,
          controller: value,
        ),
        const SizedBox(height: 16),
        const HouselyPrivacyNotice(
          title: 'Tenant-recorded information',
          message:
              'Property-provided items are records created by tenants, not certification from a landlord.',
        ),
      ],
    ),
  );
}

class SetOwnershipScreen extends StatelessWidget {
  const SetOwnershipScreen({required this.state, super.key});
  final StuffFeatureState state;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: state,
    builder: (context, _) => FeatureScaffold(
      title: 'Set ownership',
      subtitle: 'Make the ownership split explicit. The total must equal 100%.',
      onBack: () => context.pop(),
      bottom: HouselyStickyAction(
        label: 'Save item',
        onPressed: () {
          state.addDraft();
          context.go('/stuff');
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HouselyOwnershipEditor(
            owner: 'Your share',
            value: state.yourShare.toDouble(),
            onChanged: (value) => state.setYourShare(value.round()),
          ),
          const SizedBox(height: 12),
          HouselyOwnershipRow(
            owner: 'Alex Morgan',
            share: '${100 - state.yourShare}%',
          ),
          const SizedBox(height: 16),
          const HouselyStatusPill(
            label: 'Total · 100%',
            status: HouselyStatus.success,
          ),
          const SizedBox(height: 16),
          const HouselyPrivacyNotice(
            title: 'Ownership history is retained',
            message:
                'Future transfers create a new history entry instead of silently replacing this split.',
          ),
        ],
      ),
    ),
  );
}

class ItemDetailScreen extends StatelessWidget {
  const ItemDetailScreen({required this.state, super.key});
  final StuffFeatureState state;
  @override
  Widget build(BuildContext context) {
    final item = state.items.first;
    return FeatureScaffold(
      title: 'Item',
      onBack: () => context.pop(),
      action: HouselyIconButton(
        icon: Icons.edit_outlined,
        label: 'Edit item',
        onPressed: () {},
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 190,
            decoration: BoxDecoration(
              color: HouselyPalette.surfaceRaised,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: HouselyPalette.divider),
            ),
            child: const Icon(
              Icons.chair_outlined,
              size: 72,
              color: HouselyPalette.textTertiary,
            ),
          ),
          const SizedBox(height: 20),
          Text(item.name, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              const HouselyScopeBadge(scope: HouselyScope.household),
              const SizedBox(width: 8),
              HouselyStatusPill(label: item.location),
            ],
          ),
          const SizedBox(height: 20),
          HouselyGroupedList(
            children: [
              ...item.owners.entries.map(
                (owner) => HouselyOwnershipRow(
                  owner: owner.key,
                  share: '${owner.value}%',
                ),
              ),
              HouselyRecordRow(
                title: itemMoney(item.valuePence),
                subtitle: 'Linked purchase expense',
                icon: Icons.receipt_long_outlined,
                onTap: () {},
              ),
              const HouselyFileRow(
                title: 'Furniture receipt.pdf',
                metadata: 'Receipt · Household',
              ),
              HouselyRecordRow(
                title: item.warranty ?? 'No warranty',
                subtitle: 'Warranty',
                icon: Icons.verified_outlined,
                iconColor: HouselyPalette.coral,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MoreMenuScreen extends StatelessWidget {
  const MoreMenuScreen({super.key});
  @override
  Widget build(BuildContext context) => FeatureScaffold(
    title: 'More',
    onBack: () => context.pop(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HouselyHomeIdentity(
          name: 'George Street Flat',
          address: '18 George Street, Edinburgh',
          members: ['Muhammad Shaheer', 'Alex Morgan', 'Sam Lee'],
        ),
        const SizedBox(height: 24),
        HouselySection(
          title: 'Home',
          child: HouselyGroupedList(
            children: [
              HouselyRecordRow(
                title: 'Your household',
                icon: Icons.people_outline_rounded,
                onTap: () => context.push('/household-overview'),
              ),
              HouselyRecordRow(
                title: 'Home details',
                icon: Icons.home_work_outlined,
                onTap: () => context.push('/your-homes'),
              ),
              HouselyRecordRow(
                title: 'Changes',
                icon: Icons.compare_arrows_rounded,
                onTap: () => context.push('/changes-overview'),
              ),
              HouselyRecordRow(
                title: 'Tasks',
                icon: Icons.checklist_rounded,
                onTap: () => context.push('/tasks'),
              ),
              HouselyRecordRow(
                title: 'Home timeline',
                icon: Icons.history_rounded,
                onTap: () => context.push('/timeline'),
              ),
              HouselyRecordRow(
                title: 'Notifications',
                icon: Icons.notifications_outlined,
                onTap: () => context.push('/notifications'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        HouselySection(
          title: 'Money and manage',
          child: HouselyGroupedList(
            children: [
              HouselyRecordRow(
                title: 'Recurring costs',
                icon: Icons.repeat_rounded,
                onTap: () => context.push('/recurring-payments'),
              ),
              HouselyRecordRow(
                title: 'Private groups',
                icon: Icons.lock_outline_rounded,
                onTap: () => context.push('/private-groups'),
              ),
              HouselyRecordRow(
                title: 'Settings',
                icon: Icons.settings_outlined,
                onTap: () => context.push('/app-settings'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        HouselySection(
          title: 'Prototype',
          child: HouselyGroupedList(
            children: [
              HouselyRecordRow(
                title: 'Complete MVP screen library',
                subtitle: 'Review every route-level interface by product area',
                icon: Icons.view_quilt_outlined,
                onTap: () => context.push('/mvp-screens'),
              ),
              HouselyRecordRow(
                title: 'State lab',
                subtitle: 'Mock data, loading, empty and error previews',
                icon: Icons.science_outlined,
                onTap: () => context.push('/state-lab'),
              ),
              HouselyRecordRow(
                title: 'Motion and accessibility review',
                subtitle:
                    'Feedback, 200% text, touch targets and platform checks',
                icon: Icons.accessibility_new_rounded,
                onTap: () => context.push('/accessibility-review'),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool notifications = true;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: HouselySize.maxContentWidth,
        ),
        child: ListView(
          padding: const EdgeInsets.all(HouselySize.phoneGutter),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'You',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                HouselyIconButton(
                  icon: Icons.grid_view_rounded,
                  label: 'More',
                  onPressed: () => context.push('/more'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const HouselySurface(
              color: HouselyPalette.skySoft,
              child: Row(
                children: [
                  HouselyAvatar(
                    name: 'Muhammad Shaheer',
                    size: 56,
                    statusColor: HouselyPalette.mint,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Muhammad Shaheer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: HouselyPalette.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'shaheer@example.com',
                          style: TextStyle(color: HouselyPalette.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            HouselyGroupedList(
              children: [
                HouselyRecordRow(
                  title: 'Your Homes',
                  subtitle: 'Current, pending and archived',
                  icon: Icons.home_work_outlined,
                  onTap: () => context.push('/your-homes'),
                ),
                HouselyRecordRow(
                  title: 'Profile',
                  subtitle: 'Name and contact details',
                  icon: Icons.person_outline_rounded,
                  onTap: () => context.push('/profile'),
                ),
                HouselyRecordRow(
                  title: 'Security',
                  subtitle: 'Password and signed-in devices',
                  icon: Icons.shield_outlined,
                  onTap: () => context.push('/security'),
                ),
                HouselyRecordRow(
                  title: 'Privacy',
                  subtitle: 'Visibility and analytics consent',
                  icon: Icons.lock_outline_rounded,
                  onTap: () => context.push('/privacy-centre'),
                ),
                ListTile(
                  minTileHeight: 64,
                  leading: const Icon(Icons.notifications_none_rounded),
                  title: const Text('Notifications'),
                  subtitle: const Text('Sensitive previews remain hidden'),
                  trailing: HouselyAdaptiveSwitch(
                    value: notifications,
                    onChanged: (value) => setState(() => notifications = value),
                  ),
                ),
                HouselyRecordRow(
                  title: 'Notification settings',
                  subtitle: 'Choose which reminders reach you',
                  icon: Icons.tune_rounded,
                  onTap: () => context.push('/notification-settings'),
                ),
                HouselyRecordRow(
                  title: 'Accessibility',
                  subtitle: 'Text, motion, contrast and labels',
                  icon: Icons.accessibility_new_rounded,
                  onTap: () => context.push('/accessibility-settings'),
                ),
                HouselyRecordRow(
                  title: 'Export your data',
                  subtitle: 'Prepare a private download',
                  icon: Icons.download_outlined,
                  onTap: () => context.push('/data-controls'),
                ),
                HouselyRecordRow(
                  title: 'Help and support',
                  icon: Icons.help_outline_rounded,
                  onTap: () => context.push('/help'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            HouselyButton(
              label: 'Sign out',
              style: HouselyButtonStyle.secondary,
              onPressed: () => context.go('/welcome'),
            ),
            const SizedBox(height: 12),
            HouselyButton(
              label: 'Delete account',
              style: HouselyButtonStyle.destructive,
              onPressed: () => context.push('/delete-account'),
            ),
          ],
        ),
      ),
    ),
  );
}
