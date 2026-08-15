import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/components/components.dart';
import '../../design_system/theme/housely_tokens.dart';
import '../shared/feature_scaffold.dart';
import 'vault_state.dart';

class VaultOverviewScreen extends StatelessWidget {
  const VaultOverviewScreen({required this.state, super.key});
  final VaultFeatureState state;

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
              HouselySpace.md,
              HouselySize.phoneGutter,
              HouselySpace.section,
            ),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Vault',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  HouselyIconButton(
                    icon: Icons.add_rounded,
                    label: 'Upload document',
                    onPressed: () => context.push('/upload-document'),
                  ),
                ],
              ),
              const SizedBox(height: HouselySpace.md),
              const HouselyField(
                label: 'Search documents',
                hint: 'Tenancy agreement',
                type: HouselyFieldType.search,
              ),
              const SizedBox(height: HouselySpace.md),
              HouselyRecordCard(
                color: HouselyPalette.skySoft,
                onTap: () => context.push('/deposit-guard'),
                child: Row(
                  children: [
                    const HomePulse(size: 52),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Deposit Guard',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.depositLocked
                                ? 'Move-in record locked'
                                : '${state.totalEvidence} files · Continue evidence',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      state.depositLocked
                          ? Icons.verified_user_outlined
                          : Icons.chevron_right_rounded,
                      color: state.depositLocked ? HouselyPalette.mint : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: HouselySpace.xl),
              HouselySection(
                title: 'Recent files',
                child: HouselyGroupedList(
                  children: state.documents
                      .map(
                        (doc) => HouselyFileRow(
                          title: doc.title,
                          metadata:
                              '${doc.category} · ${doc.visibility} · ${doc.date}',
                          onTap: () => context.push('/document-detail'),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class UploadDocumentScreen extends StatefulWidget {
  const UploadDocumentScreen({required this.state, super.key});
  final VaultFeatureState state;
  @override
  State<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  final title = TextEditingController();
  String visibility = 'Household';
  bool selected = false;
  bool uploading = false;

  @override
  void dispose() {
    title.dispose();
    super.dispose();
  }

  Future<void> upload() async {
    if (!selected || title.text.trim().isEmpty) return;
    setState(() => uploading = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    widget.state.addDocument(
      VaultDocument(
        title: title.text.trim(),
        category: 'Home records',
        visibility: visibility,
        date: 'Today',
      ),
    );
    if (mounted) context.go('/document-detail');
  }

  @override
  Widget build(BuildContext context) => FeatureScaffold(
    title: 'Upload document',
    subtitle: 'Add structure and a clear visibility boundary to this file.',
    onBack: () => context.pop(),
    bottom: HouselyStickyAction(
      label: 'Upload document',
      onPressed: selected && title.text.trim().isNotEmpty && !uploading
          ? upload
          : null,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HouselySelectionTile(
          title: selected ? 'tenancy-inventory.pdf' : 'Choose a file',
          subtitle: selected
              ? 'PDF · 2.4 MB · Ready'
              : 'PDF, image or document · Up to 25 MB',
          icon: Icons.upload_file_outlined,
          selected: selected,
          onTap: () => setState(() => selected = true),
        ),
        const SizedBox(height: 16),
        HouselyField(
          label: 'Document title',
          hint: 'Tenancy inventory',
          controller: title,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        RadioGroup<String>(
          groupValue: visibility,
          onChanged: (value) {
            if (value != null) setState(() => visibility = value);
          },
          child: const HouselySurface(
            child: Column(
              children: [
                HouselyRadio<String>(label: 'Household', value: 'Household'),
                HouselyRadio<String>(label: 'Personal', value: 'Personal'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const HouselyPrivacyNotice(
          title: 'Visibility cannot exceed access',
          message:
              'The server will verify your permission before the file becomes available.',
        ),
        if (uploading) ...[
          const SizedBox(height: 16),
          const HouselyUploadProgress(
            fileName: 'tenancy-inventory.pdf',
            progress: .72,
          ),
        ],
      ],
    ),
  );
}

class DocumentDetailScreen extends StatelessWidget {
  const DocumentDetailScreen({required this.state, super.key});
  final VaultFeatureState state;
  @override
  Widget build(BuildContext context) {
    final doc = state.documents.first;
    return FeatureScaffold(
      title: 'Document',
      onBack: () => context.pop(),
      action: HouselyIconButton(
        icon: Icons.more_horiz_rounded,
        label: 'Document options',
        onPressed: () {},
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HouselyFilePreview(
            title: doc.title,
            metadata: '${doc.category} · ${doc.date}',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              HouselyScopeBadge(
                scope: doc.visibility == 'Personal'
                    ? HouselyScope.personal
                    : HouselyScope.household,
              ),
              const SizedBox(width: 8),
              const HouselyStatusPill(
                label: 'Version 1',
                status: HouselyStatus.success,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const HouselyGroupedList(
            children: [
              HouselyRecordRow(
                title: 'Uploaded by you',
                subtitle: 'Today · Original file',
                icon: Icons.person_outline_rounded,
              ),
              HouselyRecordRow(
                title: 'George Street Flat',
                subtitle: 'Related Home',
                icon: Icons.home_outlined,
              ),
              HouselyRecordRow(
                title: 'Secure access',
                subtitle: 'Preview links expire automatically',
                icon: Icons.lock_clock_outlined,
              ),
            ],
          ),
          const SizedBox(height: 20),
          HouselyButton(
            label: 'Download securely',
            leadingIcon: Icons.download_outlined,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class DepositGuardIntroScreen extends StatelessWidget {
  const DepositGuardIntroScreen({required this.state, super.key});
  final VaultFeatureState state;
  @override
  Widget build(BuildContext context) => FeatureScaffold(
    title: 'Deposit Guard',
    subtitle: state.depositLocked
        ? 'Your move-in record is locked and timestamped.'
        : 'Build a clear, room-by-room move-in record before anything changes.',
    onBack: () => context.pop(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(child: HomePulse(size: 88)),
        const SizedBox(height: 24),
        const HouselyGroupedList(
          children: [
            HouselyRecordRow(
              title: 'Guided room capture',
              subtitle: 'Track completeness area by area',
              icon: Icons.camera_alt_outlined,
            ),
            HouselyRecordRow(
              title: 'Timestamps and fingerprint',
              subtitle: 'Final bytes are hashed when locked',
              icon: Icons.fingerprint_rounded,
            ),
            HouselyRecordRow(
              title: 'Append-only originals',
              subtitle: 'Locked evidence is not silently replaced',
              icon: Icons.verified_user_outlined,
            ),
          ],
        ),
        const SizedBox(height: 16),
        const HouselyPrivacyNotice(
          title: 'Evidence, not a legal guarantee',
          message:
              'Housely records provenance and completeness but cannot guarantee acceptance in a dispute.',
        ),
        const SizedBox(height: 24),
        HouselyButton(
          label: state.depositLocked
              ? 'View locked record'
              : 'Start move-in record',
          onPressed: () => context.push('/deposit-checklist'),
        ),
      ],
    ),
  );
}

class DepositChecklistScreen extends StatelessWidget {
  const DepositChecklistScreen({required this.state, super.key});
  final VaultFeatureState state;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: state,
    builder: (context, _) => FeatureScaffold(
      title: 'Move-in checklist',
      subtitle:
          '${state.areas.values.where((count) => count > 0).length} of ${state.areas.length} areas started · ${state.totalEvidence} files',
      onBack: () => context.pop(),
      bottom: HouselyStickyAction(
        label: 'Review and lock',
        onPressed: state.evidenceComplete
            ? () => context.push('/review-lock')
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HouselyProgress(
            value:
                state.areas.values.where((count) => count > 0).length /
                state.areas.length,
            label: 'Record completeness',
          ),
          const SizedBox(height: 20),
          ...state.areas.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: HouselyChecklistCard(
                title: entry.key,
                completed: entry.value,
                total: entry.value == 0 ? 3 : entry.value,
                onTap: () => state.capture(entry.key),
              ),
            ),
          ),
          const HouselyPrivacyNotice(
            title: 'Tap an area to simulate capture',
            message:
                'Camera and upload integration will replace this local interaction when the backend is added.',
          ),
        ],
      ),
    ),
  );
}

class ReviewLockScreen extends StatelessWidget {
  const ReviewLockScreen({required this.state, super.key});
  final VaultFeatureState state;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: state,
    builder: (context, _) => FeatureScaffold(
      title: state.depositLocked ? 'Move-in record' : 'Review and lock',
      subtitle: state.depositLocked
          ? 'Locked records are immutable and append-only.'
          : 'Confirm completeness before creating the immutable record.',
      onBack: () => context.pop(),
      bottom: state.depositLocked
          ? null
          : HouselyStickyAction(
              label: 'Lock move-in record',
              onPressed: state.evidenceComplete
                  ? () async {
                      final ok = await showHouselyConfirmation(
                        context,
                        title: 'Lock this move-in record?',
                        message:
                            'Original evidence becomes append-only. New evidence will be added as a later version.',
                        confirmLabel: 'Lock record',
                      );
                      if (ok == true) state.lock();
                    }
                  : null,
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HouselyBalanceSummary(
            amount: '${state.totalEvidence}',
            label: 'Original evidence files',
          ),
          const SizedBox(height: 16),
          HouselyGroupedList(
            children: [
              HouselyRecordRow(
                title: '${state.areas.length} areas',
                subtitle: 'Room-by-room checklist',
                icon: Icons.grid_view_outlined,
              ),
              const HouselyRecordRow(
                title: 'Household visibility',
                subtitle: 'George Street Flat',
                icon: Icons.home_outlined,
              ),
              HouselyRecordRow(
                title: state.depositLocked
                    ? 'Fingerprint created'
                    : 'Fingerprint created on lock',
                subtitle: state.depositLocked
                    ? 'SHA-256 · Verified'
                    : 'Calculated from final uploaded bytes',
                icon: Icons.fingerprint_rounded,
                iconColor: state.depositLocked ? HouselyPalette.mint : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          HouselyMessageState(
            kind: state.depositLocked
                ? HouselyMessageKind.success
                : HouselyMessageKind.offline,
            title: state.depositLocked ? 'Record locked' : 'Ready to lock',
            message: state.depositLocked
                ? 'This move-in record now has an immutable timestamp and fingerprint.'
                : 'The real app will require a server connection for this final action.',
          ),
        ],
      ),
    ),
  );
}
