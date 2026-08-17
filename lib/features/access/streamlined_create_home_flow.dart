import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/components/components.dart';
import '../../design_system/theme/housely_tokens.dart';
import 'access_draft.dart';
import 'access_scaffold.dart';

class StreamlinedCreateHomeScreen extends StatefulWidget {
  const StreamlinedCreateHomeScreen({required this.draft, super.key});

  final AccessDraft draft;

  @override
  State<StreamlinedCreateHomeScreen> createState() =>
      _StreamlinedCreateHomeScreenState();
}

class _StreamlinedCreateHomeScreenState
    extends State<StreamlinedCreateHomeScreen> {
  late final TextEditingController _name = TextEditingController(
    text: widget.draft.homeName,
  );
  late final TextEditingController _postcode = TextEditingController(
    text: widget.draft.postcode,
  );
  late final TextEditingController _addressLine1 = TextEditingController(
    text: widget.draft.addressLine1,
  );
  late final TextEditingController _addressLine2 = TextEditingController(
    text: widget.draft.addressLine2,
  );
  late final TextEditingController _city = TextEditingController(
    text: widget.draft.city,
  );

  bool _showManualAddress = false;
  bool _addressSearchPerformed = false;

  late String? _selectedAddress =
      widget.draft.addressLine1.isNotEmpty &&
          widget.draft.city.isNotEmpty &&
          widget.draft.postcode.isNotEmpty
      ? widget.draft.formattedAddress
      : null;

  bool get _postcodeLooksValid {
    final value = _postcode.text.trim().toUpperCase();
    return RegExp(r'^[A-Z0-9]{2,4} [0-9][A-Z]{2}$').hasMatch(value);
  }

  List<String> get _mockAddresses {
    if (_postcode.text.trim().toUpperCase() != 'EH2 2LE') return const [];
    return const [
      '24 George Street, Edinburgh, EH2 2LE',
      '26 George Street, Edinburgh, EH2 2LE',
      '28 George Street, Edinburgh, EH2 2LE',
    ];
  }

  bool get _manualAddressReady =>
      _showManualAddress &&
      _addressLine1.text.trim().isNotEmpty &&
      _city.text.trim().isNotEmpty &&
      _postcodeLooksValid;

  bool get _canContinue =>
      _name.text.trim().isNotEmpty &&
      (_selectedAddress != null || _manualAddressReady);

  void _selectAddress(String address) {
    final parts = address.split(',');
    setState(() {
      _selectedAddress = address;
      _addressLine1.text = parts.isNotEmpty ? parts[0].trim() : '';
      _city.text = parts.length > 1 ? parts[1].trim() : '';
      _postcode.text = parts.length > 2 ? parts[2].trim() : _postcode.text;
      _showManualAddress = false;
    });
  }

  void _continue() {
    if (!_canContinue) return;

    final newAddressLine1 = _addressLine1.text.trim();
    final newAddressLine2 = _addressLine2.text.trim();
    final newCity = _city.text.trim();
    final newPostcode = _postcode.text.trim().toUpperCase();

    final propertyChanged =
        widget.draft.addressLine1 != newAddressLine1 ||
        widget.draft.addressLine2 != newAddressLine2 ||
        widget.draft.city != newCity ||
        widget.draft.postcode != newPostcode;

    if (propertyChanged) {
      widget.draft.resetTenancy();
    }

    widget.draft
      ..homeName = _name.text.trim()
      ..addressLine1 = newAddressLine1
      ..addressLine2 = newAddressLine2
      ..city = newCity
      ..postcode = newPostcode;

    context.push('/tenancy-status');
  }

  @override
  void dispose() {
    _name.dispose();
    _postcode.dispose();
    _addressLine1.dispose();
    _addressLine2.dispose();
    _city.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AccessScaffold(
    eyebrow: 'Home',
    title: 'Tell us about your Home',
    message:
        'Create the Home first. You can finish household setup after you get inside.',
    onBack: () => context.go('/start-choice'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HouselyPrivacyNotice(
          title: 'Your address stays private',
          message:
              'The full address is visible only to accepted members of this Home.',
        ),
        const SizedBox(height: HouselySpace.lg),
        HouselyField(
          label: 'Home name',
          hint: 'George Street Flat',
          controller: _name,
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: HouselySpace.md),
        HouselyField(
          label: 'Postcode',
          hint: 'EH2 2LE',
          controller: _postcode,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: const [HouselyUkPostcodeFormatter()],
          onChanged: (_) {
            setState(() {
              _selectedAddress = null;
              _addressSearchPerformed = false;
            });
          },
        ),
        const SizedBox(height: HouselySpace.sm),
        HouselyButton(
          label: 'Find address',
          style: HouselyButtonStyle.secondary,
          onPressed: !_postcodeLooksValid
              ? null
              : () => setState(() => _addressSearchPerformed = true),
        ),
        if (_addressSearchPerformed && _mockAddresses.isNotEmpty) ...[
          const SizedBox(height: HouselySpace.md),
          HouselyGroupedList(
            children: _mockAddresses
                .map(
                  (address) => ListTile(
                    title: Text(address),
                    trailing: _selectedAddress == address
                        ? const Icon(Icons.check_rounded)
                        : const Icon(Icons.chevron_right_rounded),
                    onTap: () => _selectAddress(address),
                  ),
                )
                .toList(),
          ),
        ],
        if (_addressSearchPerformed && _mockAddresses.isEmpty) ...[
          const SizedBox(height: HouselySpace.md),
          const HouselyMessageState(
            kind: HouselyMessageKind.empty,
            title: 'No prototype address found',
            message:
                'Use EH2 2LE for the prototype, or enter the address manually.',
          ),
        ],
        const SizedBox(height: HouselySpace.sm),
        HouselyButton(
          label: _showManualAddress
              ? 'Hide manual address'
              : 'Enter address manually',
          style: HouselyButtonStyle.text,
          onPressed: () => setState(() {
            _showManualAddress = !_showManualAddress;
            if (_showManualAddress) _selectedAddress = null;
          }),
        ),
        if (_showManualAddress) ...[
          const SizedBox(height: HouselySpace.md),
          HouselyField(
            label: 'Address line 1',
            hint: '24 George Street',
            controller: _addressLine1,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: HouselySpace.md),
          HouselyField(
            label: 'Address line 2',
            hint: 'Flat 4B (optional)',
            controller: _addressLine2,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: HouselySpace.md),
          HouselyField(
            label: 'City',
            hint: 'Edinburgh',
            controller: _city,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
          ),
        ],
        if (_selectedAddress != null) ...[
          const SizedBox(height: HouselySpace.lg),
          HouselyMessageState(
            kind: HouselyMessageKind.success,
            title: 'Address selected',
            message: _selectedAddress!,
          ),
        ],
        const SizedBox(height: HouselySpace.xl),
        HouselyButton(
          label: 'Continue',
          state: _canContinue
              ? HouselyComponentState.idle
              : HouselyComponentState.disabled,
          onPressed: _canContinue ? _continue : null,
        ),
      ],
    ),
  );
}

class StreamlinedTenancyStatusScreen extends StatelessWidget {
  const StreamlinedTenancyStatusScreen({required this.draft, super.key});

  final AccessDraft draft;

  void _select(BuildContext context, TenancyRelationship relationship) {
    draft.updateTenancyRelationship(relationship);

    switch (relationship) {
      case TenancyRelationship.namedOnTenancy:
      case TenancyRelationship.unsure:
        context.push('/upload-tenancy');
        break;
      case TenancyRelationship.notNamedOnTenancy:
        draft
          ..tenancySkipped = true
          ..markTenancySetupComplete();
        context.go('/home');
        break;
    }
  }

  @override
  Widget build(BuildContext context) => AccessScaffold(
    eyebrow: 'Tenancy',
    title: 'Are you named on the tenancy?',
    message:
        'If you are named on the agreement, Housely can connect your account to that tenancy identity.',
    onBack: () => context.pop(),
    child: Column(
      children: [
        HouselySelectionTile(
          title: 'Yes, I’m named on the tenancy',
          subtitle: 'Upload the agreement and claim only your own name.',
          icon: Icons.description_outlined,
          selected:
              draft.tenancyRelationship == TenancyRelationship.namedOnTenancy,
          onTap: () => _select(context, TenancyRelationship.namedOnTenancy),
        ),
        const SizedBox(height: HouselySpace.sm),
        HouselySelectionTile(
          title: 'No, I’m not on the tenancy',
          subtitle:
              'Create the Home now. Tenancy details can be managed later.',
          icon: Icons.home_outlined,
          selected:
              draft.tenancyRelationship ==
              TenancyRelationship.notNamedOnTenancy,
          onTap: () => _select(context, TenancyRelationship.notNamedOnTenancy),
        ),
        const SizedBox(height: HouselySpace.sm),
        HouselySelectionTile(
          title: 'I’m not sure',
          subtitle: 'Upload the agreement and check whether your name appears.',
          icon: Icons.help_outline_rounded,
          selected: draft.tenancyRelationship == TenancyRelationship.unsure,
          onTap: () => _select(context, TenancyRelationship.unsure),
        ),
      ],
    ),
  );
}

class StreamlinedUploadTenancyScreen extends StatefulWidget {
  const StreamlinedUploadTenancyScreen({required this.draft, super.key});

  final AccessDraft draft;

  @override
  State<StreamlinedUploadTenancyScreen> createState() =>
      _StreamlinedUploadTenancyScreenState();
}

class _StreamlinedUploadTenancyScreenState
    extends State<StreamlinedUploadTenancyScreen> {
  bool _uploading = false;

  bool get _hasDocument => widget.draft.tenancyDocumentName != null;

  Future<void> _chooseDocument() async {
    setState(() => _uploading = true);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    widget.draft.resetProcessedTenancy();
    widget.draft
      ..tenancyDocumentName = 'tenancy-agreement.pdf'
      ..tenancyDocumentType = 'PDF'
      ..tenancyDocumentSizeBytes = 1840000
      ..tenancySkipped = false;

    setState(() => _uploading = false);
  }

  void _removeDocument() {
    widget.draft.resetProcessedTenancy();
    setState(() {
      widget.draft
        ..tenancyDocumentName = null
        ..tenancyDocumentType = null
        ..tenancyDocumentSizeBytes = null;
    });
  }

  @override
  Widget build(BuildContext context) => AccessScaffold(
    eyebrow: 'Tenancy',
    title: 'Add your tenancy agreement',
    message:
        'We only need to find the name that belongs to you. Other detected names can claim themselves later.',
    onBack: () => context.pop(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HouselyPrivacyNotice(
          title: 'Other people are not added automatically',
          message:
              'Names found in this document remain unclaimed until the right person joins and confirms their identity.',
        ),
        const SizedBox(height: HouselySpace.xl),
        if (!_hasDocument && !_uploading)
          HouselySurface(
            child: Column(
              children: [
                const Icon(
                  Icons.description_outlined,
                  size: 40,
                  color: HouselyPalette.violet,
                ),
                const SizedBox(height: HouselySpace.md),
                Text(
                  'Upload tenancy agreement',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: HouselySpace.sm),
                const Text(
                  'PDF or image. The prototype uses a sample agreement.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: HouselySpace.lg),
                HouselyButton(
                  label: 'Choose document',
                  leadingIcon: Icons.upload_file_outlined,
                  onPressed: _chooseDocument,
                ),
              ],
            ),
          ),
        if (_uploading)
          const HouselyUploadProgress(
            fileName: 'tenancy-agreement.pdf',
            progress: .7,
          ),
        if (_hasDocument && !_uploading)
          HouselySurface(
            child: Row(
              children: [
                const Icon(
                  Icons.picture_as_pdf_outlined,
                  color: HouselyPalette.violet,
                ),
                const SizedBox(width: HouselySpace.sm),
                Expanded(
                  child: Text(
                    widget.draft.tenancyDocumentName!,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                HouselyIconButton(
                  icon: Icons.delete_outline_rounded,
                  label: 'Remove document',
                  destructive: true,
                  onPressed: _removeDocument,
                ),
              ],
            ),
          ),
        const SizedBox(height: HouselySpace.xl),
        HouselyButton(
          label: 'Read agreement',
          state: _hasDocument
              ? HouselyComponentState.idle
              : HouselyComponentState.disabled,
          onPressed: _hasDocument
              ? () => context.push('/tenancy-processing')
              : null,
        ),
        const SizedBox(height: HouselySpace.sm),
        HouselyButton(
          label: 'I’ll add this later',
          style: HouselyButtonStyle.text,
          onPressed: () {
            widget.draft
              ..tenancySkipped = true
              ..markTenancySetupComplete();
            context.go('/home');
          },
        ),
      ],
    ),
  );
}

class StreamlinedTenancyProcessingScreen extends StatefulWidget {
  const StreamlinedTenancyProcessingScreen({required this.draft, super.key});

  final AccessDraft draft;

  @override
  State<StreamlinedTenancyProcessingScreen> createState() =>
      _StreamlinedTenancyProcessingScreenState();
}

class _StreamlinedTenancyProcessingScreenState
    extends State<StreamlinedTenancyProcessingScreen> {
  int _stage = 0;

  static const _stages = [
    'Reading agreement',
    'Finding tenant names',
    'Preparing your identity check',
  ];

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    for (var i = 0; i < _stages.length; i++) {
      if (!mounted) return;
      setState(() => _stage = i);
      await Future<void>.delayed(const Duration(milliseconds: 450));
    }

    if (!mounted) return;

    widget.draft.setDetectedTenantNames(const [
      'Muhammad Shaheer Shoukathali',
      'Alex Morgan',
      'Meera Thomas',
    ]);

    context.replace('/tenant-match');
  }

  @override
  Widget build(BuildContext context) => AccessScaffold(
    eyebrow: 'Tenancy',
    title: 'Reading your agreement',
    message: 'This should only take a moment.',
    onBack: null,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HouselyProgress(
          value: (_stage + 1) / _stages.length,
          label: _stages[_stage],
          semanticLabel: 'Tenancy processing progress',
        ),
        const SizedBox(height: HouselySpace.lg),
        Text(
          'We’ll ask you to claim only your own name next.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    ),
  );
}

class StreamlinedClaimTenancyNameScreen extends StatefulWidget {
  const StreamlinedClaimTenancyNameScreen({required this.draft, super.key});

  final AccessDraft draft;

  @override
  State<StreamlinedClaimTenancyNameScreen> createState() =>
      _StreamlinedClaimTenancyNameScreenState();
}

class _StreamlinedClaimTenancyNameScreenState
    extends State<StreamlinedClaimTenancyNameScreen> {
  String? _selectedName;

  @override
  void initState() {
    super.initState();
    _selectedName = widget.draft.matchedTenantName;
  }

  bool _looksLikeAccount(String tenantName) {
    final account = widget.draft.name.trim().toLowerCase();
    final tenant = tenantName.trim().toLowerCase();
    if (account.isEmpty) return false;
    return account == tenant ||
        account.contains(tenant) ||
        tenant.contains(account);
  }

  void _continue() {
    if (_selectedName == null) return;
    widget.draft.setMatchedTenantName(_selectedName);
    context.push('/tenant-match-confirm');
  }

  @override
  Widget build(BuildContext context) => AccessScaffold(
    eyebrow: 'Tenancy',
    title: 'Which name is yours?',
    message:
        'Choose only your own tenancy identity. Everyone else can claim their name when they join Housely.',
    onBack: () => context.go('/upload-tenancy'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final name in widget.draft.detectedTenantNames) ...[
          HouselySelectionTile(
            title: name,
            subtitle: _looksLikeAccount(name)
                ? 'Likely match with your Housely profile'
                : 'Unclaimed tenancy name',
            icon: _looksLikeAccount(name)
                ? Icons.person_search_outlined
                : Icons.person_outline_rounded,
            selected: _selectedName == name,
            onTap: () => setState(() => _selectedName = name),
          ),
          const SizedBox(height: HouselySpace.sm),
        ],
        const HouselyPrivacyNotice(
          title: 'You are not managing everyone else',
          message:
              'Selecting your name does not invite, remove or classify the other people found in the tenancy.',
        ),
        const SizedBox(height: HouselySpace.xl),
        HouselyButton(
          label: 'Continue',
          state: _selectedName == null
              ? HouselyComponentState.disabled
              : HouselyComponentState.idle,
          onPressed: _selectedName == null ? null : _continue,
        ),
        const SizedBox(height: HouselySpace.sm),
        HouselyButton(
          label: 'None of these are me',
          style: HouselyButtonStyle.text,
          onPressed: () {
            widget.draft.setMatchedTenantName(null);
            context.push('/tenant-match-missing');
          },
        ),
      ],
    ),
  );
}

class StreamlinedConfirmTenancyIdentityScreen extends StatelessWidget {
  const StreamlinedConfirmTenancyIdentityScreen({
    required this.draft,
    super.key,
  });

  final AccessDraft draft;

  void _confirm(BuildContext context) {
    if (draft.matchedTenantName == null) {
      context.go('/tenant-match');
      return;
    }

    draft.confirmTenancyIdentity();
    draft.setHomeSetupAdmin(true);
    draft.markTenancySetupComplete();

    // This is the only point where the creator onboarding journey is finished.
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) => AccessScaffold(
    eyebrow: 'Tenancy',
    title: 'Confirm this is you',
    message:
        'After this, your Home is ready. You can connect everyone else later.',
    onBack: () => context.pop(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HouselySurface(
          child: Row(
            children: [
              const Icon(Icons.verified_user_outlined, size: 32),
              const SizedBox(width: HouselySpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      draft.matchedTenantName ?? 'No name selected',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    const Text('Named on tenancy · Your identity'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: HouselySpace.lg),
        const HouselyPrivacyNotice(
          title: 'Other names stay unclaimed',
          message:
              'They remain linked to the tenancy document, but no Housely account is connected to them yet.',
        ),
        const SizedBox(height: HouselySpace.xl),
        HouselyButton(
          label: 'Confirm and enter my Home',
          onPressed: () => _confirm(context),
        ),
        const SizedBox(height: HouselySpace.sm),
        HouselyButton(
          label: 'Choose another name',
          style: HouselyButtonStyle.text,
          onPressed: () => context.pop(),
        ),
      ],
    ),
  );
}

class StreamlinedTenancyNameMissingScreen extends StatelessWidget {
  const StreamlinedTenancyNameMissingScreen({required this.draft, super.key});

  final AccessDraft draft;

  @override
  Widget build(BuildContext context) => AccessScaffold(
    eyebrow: 'Tenancy',
    title: 'Your name wasn’t found',
    message:
        'You can still create the Home. We’ll keep the tenancy unverified until you update it later.',
    onBack: () => context.pop(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HouselyMessageState(
          kind: HouselyMessageKind.empty,
          title: 'No tenancy identity claimed',
          message:
              'Housely will not mark you as a verified named tenant without your confirmation.',
        ),
        const SizedBox(height: HouselySpace.xl),
        HouselyButton(
          label: 'Review names again',
          onPressed: () => context.pop(),
        ),
        const SizedBox(height: HouselySpace.sm),
        HouselyButton(
          label: 'Create Home without verification',
          style: HouselyButtonStyle.secondary,
          onPressed: () {
            draft.continueWithoutTenancyVerification();
            draft.markTenancySetupComplete();
            context.go('/home');
          },
        ),
      ],
    ),
  );
}
