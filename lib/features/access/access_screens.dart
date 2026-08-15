import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/components/components.dart';
import '../../design_system/theme/housely_tokens.dart';
import 'access_draft.dart';
import 'access_scaffold.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(HouselySize.phoneGutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: HomePulse(size: 52),
                ),
                const Spacer(flex: 2),
                Text(
                  'Your home, connected.',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: HouselySpace.md),
                Text(
                  'Share costs, protect important records and keep ownership clear—without losing control of what stays private.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: HouselyPalette.textSecondary,
                  ),
                ),
                const SizedBox(height: HouselySpace.xxl),
                const HouselyPrivacyNotice(
                  title: 'Privacy is part of the structure',
                  message:
                      'Personal, Household and Private Group records stay in separate boundaries.',
                ),
                const Spacer(flex: 3),
                HouselyButton(
                  label: 'Create account',
                  onPressed: () => context.go('/create-account'),
                ),
                const SizedBox(height: HouselySpace.sm),
                HouselyButton(
                  label: 'Sign in',
                  style: HouselyButtonStyle.secondary,
                  onPressed: () => context.go('/create-account'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({required this.draft, super.key});
  final AccessDraft draft;

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  late final TextEditingController _name = TextEditingController(
    text: widget.draft.name,
  );
  late final TextEditingController _email = TextEditingController(
    text: widget.draft.email,
  );
  late final TextEditingController _password = TextEditingController(
    text: widget.draft.password,
  );
  bool _terms = false;
  bool _showErrors = false;

  bool get _valid =>
      _name.text.trim().isNotEmpty &&
      _email.text.contains('@') &&
      _password.text.length >= 12 &&
      _terms;

  void _continue() {
    setState(() => _showErrors = !_valid);
    if (!_valid) return;
    widget.draft
      ..name = _name.text.trim()
      ..email = _email.text.trim()
      ..password = _password.text;
    context.go('/verify-email');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AccessScaffold(
    eyebrow: 'Account',
    title: 'Create your account',
    message:
        'Start with the minimum information needed to identify you securely.',
    onBack: () => context.go('/welcome'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_showErrors) ...[
          const HouselyValidationSummary(
            errors: [
              'Enter your name and a valid email.',
              'Use at least 12 password characters.',
              'Accept the terms to continue.',
            ],
          ),
          const SizedBox(height: HouselySpace.md),
        ],
        HouselyField(
          label: 'Full name',
          controller: _name,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: HouselySpace.md),
        HouselyField(
          label: 'Email address',
          type: HouselyFieldType.email,
          controller: _email,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: HouselySpace.md),
        HouselyField(
          label: 'Password',
          type: HouselyFieldType.password,
          controller: _password,
          helperText: 'Use at least 12 characters.',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: HouselySpace.md),
        HouselyCheckbox(
          label: 'I agree to the Terms and Privacy Policy',
          value: _terms,
          onChanged: (value) => setState(() => _terms = value ?? false),
        ),
        const SizedBox(height: HouselySpace.xl),
        HouselyButton(label: 'Continue', onPressed: _continue),
      ],
    ),
  );
}

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({required this.draft, super.key});
  final AccessDraft draft;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _resent = false;

  @override
  Widget build(BuildContext context) => AccessScaffold(
    eyebrow: 'Account',
    title: 'Check your email',
    message:
        'We sent a verification link to ${widget.draft.email.isEmpty ? 'your email address' : widget.draft.email}.',
    onBack: () => context.go('/create-account'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HouselyMessageState(
          kind: HouselyMessageKind.success,
          title: 'Verification sent',
          message:
              'Open the secure link in the same device to return to Housely.',
        ),
        const SizedBox(height: HouselySpace.xl),
        HouselyButton(
          label: 'I’ve verified my email',
          onPressed: () => context.go('/start-choice'),
        ),
        const SizedBox(height: HouselySpace.sm),
        HouselyButton(
          label: _resent ? 'Email sent again' : 'Resend email',
          style: HouselyButtonStyle.text,
          state: _resent
              ? HouselyComponentState.success
              : HouselyComponentState.idle,
          onPressed: () => setState(() => _resent = true),
        ),
        HouselyButton(
          label: 'Change email address',
          style: HouselyButtonStyle.text,
          onPressed: () => context.go('/create-account'),
        ),
      ],
    ),
  );
}

class StartChoiceScreen extends StatelessWidget {
  const StartChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) => AccessScaffold(
    eyebrow: 'Getting started',
    title: 'How are you getting started?',
    message:
        'Set up your own Home or join a household that already uses Housely.',
    onBack: () => context.go('/verify-email'),
    child: Column(
      children: [
        HouselySelectionTile(
          title: 'Create a Home',
          subtitle:
              'Set up your property, tenancy, household and shared costs.',
          icon: Icons.home_outlined,
          selected: false,
          onTap: () => context.go('/create-home'),
        ),
        const SizedBox(height: HouselySpace.sm),
        HouselySelectionTile(
          title: 'Join a Home',
          subtitle:
              'Accept an invitation or request to join an existing household.',
          icon: Icons.group_add_outlined,
          selected: false,
          onTap: () => context.go('/join-home'),
        ),
      ],
    ),
  );
}

class JoinHomePlaceholderScreen extends StatelessWidget {
  const JoinHomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) => AccessScaffold(
    eyebrow: 'Join a Home',
    title: 'Join your household',
    message: 'Invitations and Home join requests will be available here.',
    onBack: () => context.go('/start-choice'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HouselyPrivacyNotice(
          title: 'Access stays private',
          message:
              'You won’t see Household information until your membership has been accepted.',
        ),
        const SizedBox(height: HouselySpace.xl),
        HouselyButton(
          label: 'Back',
          style: HouselyButtonStyle.secondary,
          onPressed: () => context.go('/start-choice'),
        ),
      ],
    ),
  );
}

class CreateHomeScreen extends StatefulWidget {
  const CreateHomeScreen({required this.draft, super.key});
  final AccessDraft draft;

  @override
  State<CreateHomeScreen> createState() => _CreateHomeScreenState();
}

class _CreateHomeScreenState extends State<CreateHomeScreen> {
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
  String? _selectedMockAddress;
  bool _addressSearchPerformed = false;

  bool get _canContinue =>
      _name.text.trim().isNotEmpty &&
      _addressLine1.text.trim().isNotEmpty &&
      _city.text.trim().isNotEmpty &&
      _postcode.text.trim().isNotEmpty;

  List<String> get _mockAddresses {
    final postcode = _postcode.text.trim().toUpperCase();

    if (postcode == 'EH2 2LE') {
      return [
        '24 George Street, Edinburgh, EH2 2LE',
        '26 George Street, Edinburgh, EH2 2LE',
        '28 George Street, Edinburgh, EH2 2LE',
      ];
    }

    return [];
  }

  void _selectAddress(String address) {
    setState(() {
      _selectedMockAddress = address;

      if (address.startsWith('24 ')) {
        _addressLine1.text = '24 George Street';
      } else if (address.startsWith('26 ')) {
        _addressLine1.text = '26 George Street';
      } else {
        _addressLine1.text = '28 George Street';
      }

      _city.text = 'Edinburgh';
    });
  }

  void _continue() {
    if (!_canContinue) return;

    widget.draft
      ..homeName = _name.text.trim()
      ..addressLine1 = _addressLine1.text.trim()
      ..addressLine2 = _addressLine2.text.trim()
      ..city = _city.text.trim()
      ..postcode = _postcode.text.trim().toUpperCase();

    context.go('/tenancy-status');
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
  @override
  Widget build(BuildContext context) => AccessScaffold(
    eyebrow: 'Home',
    title: 'Tell us about your home',
    message:
        'We’ll use this to organise everything connected to your household.',
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
          onChanged: (_) => setState(() {}),
        ),

        const SizedBox(height: HouselySpace.md),

        HouselyField(
          label: 'Postcode',
          hint: 'EH2 2LE',
          controller: _postcode,
          onChanged: (_) {
            setState(() {
              _addressSearchPerformed = false;
              _selectedMockAddress = null;
            });
          },
        ),

        const SizedBox(height: HouselySpace.sm),

        HouselyButton(
          label: 'Find address',
          style: HouselyButtonStyle.secondary,
          onPressed: _postcode.text.trim().isEmpty
              ? null
              : () {
                  setState(() {
                    _addressSearchPerformed = true;
                  });
                },
        ),

        if (_addressSearchPerformed && _mockAddresses.isNotEmpty) ...[
          const SizedBox(height: HouselySpace.md),

          HouselyGroupedList(
            children: _mockAddresses.map((address) {
              return ListTile(
                title: Text(address),
                trailing: _selectedMockAddress == address
                    ? const Icon(Icons.check_rounded)
                    : const Icon(Icons.chevron_right_rounded),
                onTap: () => _selectAddress(address),
              );
            }).toList(),
          ),
        ],

        if (_addressSearchPerformed && _mockAddresses.isEmpty) ...[
          const SizedBox(height: HouselySpace.md),

          const HouselyMessageState(
            kind: HouselyMessageKind.empty,
            title: 'No address found',
            message:
                'Try EH2 2LE for the prototype, or enter your address manually.',
          ),
        ],

        const SizedBox(height: HouselySpace.sm),

        HouselyButton(
          label: _showManualAddress
              ? 'Hide manual address'
              : 'Enter address manually',
          style: HouselyButtonStyle.text,
          onPressed: () {
            setState(() {
              _showManualAddress = !_showManualAddress;

              if (_showManualAddress) {
                _selectedMockAddress = null;
              }
            });
          },
        ),

        if (_showManualAddress) ...[
          const SizedBox(height: HouselySpace.md),

          HouselyField(
            label: 'Address line 1',
            hint: '24 George Street',
            controller: _addressLine1,
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: HouselySpace.md),

          HouselyField(
            label: 'Address line 2',
            hint: 'Flat 4B (optional)',
            controller: _addressLine2,
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: HouselySpace.md),

          HouselyField(
            label: 'City',
            hint: 'Edinburgh',
            controller: _city,
            onChanged: (_) => setState(() {}),
          ),
        ],

        if (_selectedMockAddress != null) ...[
          const SizedBox(height: HouselySpace.lg),

          HouselyMessageState(
            kind: HouselyMessageKind.success,
            title: 'Address selected',
            message: _selectedMockAddress!,
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

class TenancyStatusScreen extends StatelessWidget {
  const TenancyStatusScreen({required this.draft, super.key});

  final AccessDraft draft;

  void _select(BuildContext context, TenancyRelationship relationship) {
    draft.tenancyRelationship = relationship;

    switch (relationship) {
      case TenancyRelationship.namedOnTenancy:
        context.go('/tenancy-next');
        break;

      case TenancyRelationship.notNamedOnTenancy:
        context.go('/tenancy-next');
        break;

      case TenancyRelationship.unsure:
        context.go('/tenancy-next');
        break;
    }
  }

  @override
  Widget build(BuildContext context) => AccessScaffold(
    eyebrow: 'Tenancy',
    title: 'Are you named on the tenancy?',
    message:
        'This helps Housely understand your relationship to ${draft.homeName.isEmpty ? 'this Home' : draft.homeName} and set the right household permissions.',
    onBack: () => context.go('/create-home'),
    child: Column(
      children: [
        HouselySelectionTile(
          title: 'Yes, I’m named on the tenancy',
          subtitle: 'You’ll add or upload your tenancy details next.',
          icon: Icons.description_outlined,
          selected:
              draft.tenancyRelationship == TenancyRelationship.namedOnTenancy,
          onTap: () => _select(context, TenancyRelationship.namedOnTenancy),
        ),

        const SizedBox(height: HouselySpace.sm),

        HouselySelectionTile(
          title: 'No, I’m not on the tenancy',
          subtitle: 'I live here, but I’m not named on the agreement.',
          icon: Icons.home_outlined,
          selected:
              draft.tenancyRelationship ==
              TenancyRelationship.notNamedOnTenancy,
          onTap: () => _select(context, TenancyRelationship.notNamedOnTenancy),
        ),

        const SizedBox(height: HouselySpace.sm),

        HouselySelectionTile(
          title: 'I’m not sure',
          subtitle: 'You can confirm your tenancy relationship later.',
          icon: Icons.help_outline_rounded,
          selected: draft.tenancyRelationship == TenancyRelationship.unsure,
          onTap: () => _select(context, TenancyRelationship.unsure),
        ),
      ],
    ),
  );
}

class TenancyNextPlaceholderScreen extends StatelessWidget {
  const TenancyNextPlaceholderScreen({required this.draft, super.key});

  final AccessDraft draft;

  @override
  Widget build(BuildContext context) => AccessScaffold(
    eyebrow: 'Tenancy',
    title: 'Tenancy setup continues next',
    message:
        'Your relationship has been saved. Document upload and tenancy matching will be designed in the next phase.',
    onBack: () => context.go('/tenancy-status'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HouselyPrivacyNotice(
          title: 'Saved locally for now',
          message:
              'This prototype does not upload or process real tenancy documents yet.',
        ),

        const SizedBox(height: HouselySpace.xl),

        HouselyButton(
          label: 'Back to tenancy',
          style: HouselyButtonStyle.secondary,
          onPressed: () => context.go('/tenancy-status'),
        ),
      ],
    ),
  );
}

class InviteMembersScreen extends StatefulWidget {
  const InviteMembersScreen({required this.draft, super.key});
  final AccessDraft draft;

  @override
  State<InviteMembersScreen> createState() => _InviteMembersScreenState();
}

class _InviteMembersScreenState extends State<InviteMembersScreen> {
  final _invite = TextEditingController();

  void _add() {
    if (_invite.text.trim().isEmpty) return;
    setState(() {
      widget.draft.invites.add(_invite.text.trim());
      _invite.clear();
    });
  }

  @override
  void dispose() {
    _invite.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AccessScaffold(
    eyebrow: 'Step 5 of 5',
    title: 'Invite your household',
    message:
        'Invited people receive no access until they accept and join your Home.',
    onBack: () => context.go('/create-home'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HouselyHomeIdentity(
          name: widget.draft.homeName.isEmpty
              ? 'Your Home'
              : widget.draft.homeName,
          address: widget.draft.formattedAddress.isEmpty
              ? 'Household'
              : widget.draft.formattedAddress,
          members: [widget.draft.name.isEmpty ? 'You' : widget.draft.name],
        ),
        const SizedBox(height: HouselySpace.xl),
        HouselyField(
          label: 'Email or name',
          hint: 'alex@example.com',
          controller: _invite,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: HouselySpace.sm),
        HouselyButton(
          label: 'Add invitation',
          style: HouselyButtonStyle.secondary,
          onPressed: _invite.text.trim().isEmpty ? null : _add,
        ),
        if (widget.draft.invites.isNotEmpty) ...[
          const SizedBox(height: HouselySpace.lg),
          HouselyGroupedList(
            children: widget.draft.invites
                .map(
                  (invite) => HouselyMemberRow(
                    name: invite,
                    role: 'Invited',
                    status: 'Pending',
                  ),
                )
                .toList(),
          ),
        ],
        const SizedBox(height: HouselySpace.xl),
        HouselyButton(
          label: 'Finish setup',
          onPressed: () => context.go('/home'),
        ),
        const SizedBox(height: HouselySpace.xs),
        HouselyButton(
          label: 'Skip for now',
          style: HouselyButtonStyle.text,
          onPressed: () => context.go('/home'),
        ),
      ],
    ),
  );
}
