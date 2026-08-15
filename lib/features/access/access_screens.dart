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
    eyebrow: 'Step 1 of 5',
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
    eyebrow: 'Step 2 of 5',
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
    eyebrow: 'Step 3 of 5',
    title: 'How would you like to start?',
    message:
        'You can create one active Home, join an invitation, or keep personal records without a Home.',
    onBack: () => context.go('/verify-email'),
    child: Column(
      children: [
        HouselySelectionTile(
          title: 'Create a Home',
          subtitle:
              'Set up your household and invite the people you live with.',
          icon: Icons.home_outlined,
          selected: true,
          onTap: () => context.go('/create-home'),
        ),
        const SizedBox(height: HouselySpace.sm),
        HouselySelectionTile(
          title: 'Join with an invitation',
          subtitle: 'Open a link or enter the code sent by a household admin.',
          icon: Icons.mail_outline_rounded,
          selected: false,
          onTap: () {},
        ),
        const SizedBox(height: HouselySpace.sm),
        HouselySelectionTile(
          title: 'Continue without a Home',
          subtitle: 'Use your personal Vault and Stuff records for now.',
          icon: Icons.person_outline_rounded,
          selected: false,
          onTap: () => context.go('/home'),
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
  late final TextEditingController _address = TextEditingController(
    text: widget.draft.address,
  );
  bool _disclosure = false;

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AccessScaffold(
    eyebrow: 'Step 4 of 5',
    title: 'Create your Home',
    message:
        'Give this household a familiar name. Housely uses one active Home, so there is no hidden switcher.',
    onBack: () => context.go('/start-choice'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HouselyPrivacyNotice(
          title: 'Household information',
          message:
              'The full address is sensitive and is visible only to accepted Home members.',
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
          label: 'Full address',
          hint: '18 George Street, Edinburgh',
          controller: _address,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: HouselySpace.md),
        HouselyCheckbox(
          label: 'This is a rented Home',
          supportingText:
              'This helps tailor Deposit Guard guidance. It is not landlord-certified.',
          value: _disclosure,
          onChanged: (value) => setState(() => _disclosure = value ?? false),
        ),
        const SizedBox(height: HouselySpace.xl),
        HouselyButton(
          label: 'Create Home',
          state: _name.text.trim().isEmpty || _address.text.trim().isEmpty
              ? HouselyComponentState.disabled
              : HouselyComponentState.idle,
          onPressed: () {
            widget.draft
              ..homeName = _name.text.trim()
              ..address = _address.text.trim();
            context.go('/invite-members');
          },
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
          address: widget.draft.address.isEmpty
              ? 'Household'
              : widget.draft.address,
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
