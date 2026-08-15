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
                  onPressed: () => context.replace('/create-account'),
                ),
                const SizedBox(height: HouselySpace.sm),
                HouselyButton(
                  label: 'Sign in',
                  style: HouselyButtonStyle.secondary,
                  onPressed: () => context.replace('/sign-in'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({required this.draft, super.key});

  final AccessDraft draft;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late final TextEditingController _identifier = TextEditingController(
    text: widget.draft.signInIdentifier,
  );

  final TextEditingController _password = TextEditingController();

  bool _showErrors = false;
  bool _loading = false;

  bool get _identifierValid {
    final value = _identifier.text.trim();

    if (value.isEmpty) return false;

    final looksLikeEmail = value.contains('@');
    final looksLikePhone = value.replaceAll(' ', '').startsWith('+');

    return looksLikeEmail || looksLikePhone;
  }

  bool get _passwordValid => _password.text.isNotEmpty;

  bool get _valid => _identifierValid && _passwordValid;

  Future<void> _signIn() async {
    setState(() {
      _showErrors = !_valid;
    });

    if (!_valid) return;

    widget.draft.signInIdentifier = _identifier.text.trim();

    setState(() {
      _loading = true;
    });

    // MOCK AUTH ONLY.
    // Replace this with Supabase Auth later.
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() {
      _loading = false;
    });

    context.replace('/home');
  }

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AccessScaffold(
    eyebrow: 'Account',
    title: 'Welcome back',
    message: 'Sign in to continue to your Home, household and private records.',
    onBack: () => context.go('/welcome'),
    child: AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_showErrors && !_valid) ...[
            HouselyValidationSummary(
              errors: [
                if (!_identifierValid) 'Enter a valid email or phone number.',
                if (!_passwordValid) 'Enter your password.',
              ],
            ),
            const SizedBox(height: HouselySpace.md),
          ],

          HouselyField(
            label: 'Email or phone number',
            hint: 'shaheer@example.com or +44 7700 900123',
            controller: _identifier,
            state: _showErrors && !_identifierValid
                ? HouselyComponentState.error
                : HouselyComponentState.idle,
            errorText: 'Enter your email address or phone number.',
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: HouselySpace.md),

          HouselyField(
            label: 'Password',
            type: HouselyFieldType.password,
            controller: _password,
            state: _showErrors && !_passwordValid
                ? HouselyComponentState.error
                : HouselyComponentState.idle,
            errorText: 'Enter your password.',
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: HouselySpace.sm),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                widget.draft.signInIdentifier = _identifier.text.trim();

                context.replace('/forgot-password');
              },
              child: const Text('Forgot password?'),
            ),
          ),

          const SizedBox(height: HouselySpace.lg),

          HouselyButton(
            label: 'Sign in',
            state: _loading
                ? HouselyComponentState.loading
                : HouselyComponentState.idle,
            onPressed: _loading ? null : _signIn,
          ),

          const SizedBox(height: HouselySpace.md),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'New to Housely?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: () => context.replace('/create-account'),
                child: const Text('Create account'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({required this.draft, super.key});

  final AccessDraft draft;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _identifier = TextEditingController(
    text: widget.draft.signInIdentifier.isNotEmpty
        ? widget.draft.signInIdentifier
        : widget.draft.recoveryIdentifier,
  );
  bool _showError = false;

  bool get _valid {
    final value = _identifier.text.trim();

    if (value.isEmpty) return false;

    return value.contains('@') || value.replaceAll(' ', '').startsWith('+');
  }

  void _sendReset() {
    setState(() {
      _showError = !_valid;
    });

    if (!_valid) return;

    widget.draft.recoveryIdentifier = _identifier.text.trim();

    context.replace('/password-reset-sent');
  }

  @override
  void dispose() {
    _identifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AccessScaffold(
    eyebrow: 'Account recovery',
    title: 'Reset your password',
    message:
        'Enter the email address or verified phone number connected to your Housely account.',
    onBack: () => context.go('/sign-in'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HouselyField(
          label: 'Email or phone number',
          hint: 'shaheer@example.com or +44 7700 900123',
          controller: _identifier,
          state: _showError && !_valid
              ? HouselyComponentState.error
              : HouselyComponentState.idle,
          errorText: 'Enter a valid email address or phone number.',
          onChanged: (_) {
            setState(() {
              _showError = false;
            });
          },
        ),

        const SizedBox(height: HouselySpace.xl),

        HouselyButton(
          label: 'Send reset link',
          state: _valid
              ? HouselyComponentState.idle
              : HouselyComponentState.disabled,
          onPressed: _valid ? _sendReset : null,
        ),
      ],
    ),
  );
}

class PasswordResetSentScreen extends StatelessWidget {
  const PasswordResetSentScreen({required this.draft, super.key});

  final AccessDraft draft;

  @override
  Widget build(BuildContext context) => AccessScaffold(
    eyebrow: 'Account recovery',
    title: 'Check your messages',

    message:
        'We’ve sent account recovery instructions to ${draft.recoveryIdentifier.isEmpty ? 'your email or phone number' : draft.recoveryIdentifier}.',
    onBack: () => context.go('/sign-in'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HouselyMessageState(
          kind: HouselyMessageKind.success,
          title: 'Recovery instructions sent',
          message:
              'Follow the secure recovery instructions to regain access to your account.',
        ),

        const SizedBox(height: HouselySpace.xl),

        HouselyButton(
          label: 'Back to sign in',
          onPressed: () => context.replace('/sign-in'),
        ),

        const SizedBox(height: HouselySpace.sm),

        HouselyButton(
          label: 'Send again',
          style: HouselyButtonStyle.text,
          onPressed: () => context.replace('/forgot-password'),
        ),
      ],
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
  late final TextEditingController _phone = TextEditingController(
    text: widget.draft.phone,
  );
  late final TextEditingController _email = TextEditingController(
    text: widget.draft.email,
  );
  late final TextEditingController _password = TextEditingController(
    text: widget.draft.password,
  );
  bool _terms = false;
  bool _showErrors = false;

  bool get _phoneValid {
    final value = _phone.text.trim().replaceAll(' ', '').replaceAll('-', '');

    return value.startsWith('+') && value.length >= 9;
  }

  bool get _emailValid {
    final value = _email.text.trim();

    // Email is optional.
    // If the user enters one, it must look like an email.
    return value.isEmpty || value.contains('@');
  }

  bool get _valid =>
      _name.text.trim().isNotEmpty &&
      _phoneValid &&
      _emailValid &&
      _password.text.length >= 12 &&
      _terms;

  void _continue() {
    setState(() => _showErrors = !_valid);

    if (!_valid) return;

    widget.draft
      ..name = _name.text.trim()
      ..phone = _phone.text.trim().replaceAll(' ', '').replaceAll('-', '')
      ..email = _email.text.trim()
      ..password = _password.text;

    context.replace('/verify-phone');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AccessScaffold(
    eyebrow: 'Account',
    title: 'Create your account',
    message:
        'Start with the minimum information needed to identify you securely.',
    onBack: () => context.replace('/welcome'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_showErrors) ...[
          HouselyValidationSummary(
            errors: [
              if (_name.text.trim().isEmpty) 'Enter your full name.',
              if (!_phoneValid) 'Enter a valid phone number with country code.',
              if (!_emailValid) 'Check your email address.',
              if (_password.text.length < 12)
                'Use at least 12 password characters.',
              if (!_terms) 'Accept the terms to continue.',
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
          label: 'Phone number',
          hint: '+44 7700 900123',
          type: HouselyFieldType.phone,
          controller: _phone,
          state: _showErrors && !_phoneValid
              ? HouselyComponentState.error
              : HouselyComponentState.idle,
          errorText: 'Enter your phone number with country code.',
          helperText:
              'Required for account verification and household invites.',
          onChanged: (_) => setState(() {}),
        ),

        const SizedBox(height: HouselySpace.md),

        HouselyField(
          label: 'Email address (optional)',
          hint: 'shaheer@example.com',
          type: HouselyFieldType.email,
          controller: _email,
          state: _showErrors && !_emailValid
              ? HouselyComponentState.error
              : HouselyComponentState.idle,
          errorText: 'Enter a valid email address.',
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

        HouselyButton(
          label: 'Continue',
          state: _valid
              ? HouselyComponentState.idle
              : HouselyComponentState.disabled,
          onPressed: _valid ? _continue : null,
        ),
      ],
    ),
  );
}

class VerifyPhoneScreen extends StatefulWidget {
  const VerifyPhoneScreen({required this.draft, super.key});

  final AccessDraft draft;

  @override
  State<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  final TextEditingController _code = TextEditingController();

  bool _resent = false;
  bool _showError = false;

  bool get _valid => _code.text.trim().length == 6;

  void _verify() {
    setState(() {
      _showError = !_valid;
    });

    if (!_valid) return;

    widget.draft.phoneVerified = true;

    context.replace('/start-choice');
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AccessScaffold(
    eyebrow: 'Account',
    title: 'Verify your phone',
    message:
        'We sent a 6-digit code to ${widget.draft.phone.isEmpty ? 'your phone number' : widget.draft.phone}.',
    onBack: () => context.go('/create-account'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HouselyPrivacyNotice(
          title: 'Why verify your number?',
          message:
              'A verified number helps Housely securely identify your account and connect invitations intended for you.',
        ),

        const SizedBox(height: HouselySpace.xl),

        HouselyField(
          label: 'Verification code',
          hint: '123456',
          controller: _code,
          state: _showError && !_valid
              ? HouselyComponentState.error
              : HouselyComponentState.idle,
          errorText: 'Enter the 6-digit verification code.',
          onChanged: (_) => setState(() {}),
        ),

        const SizedBox(height: HouselySpace.xl),

        HouselyButton(
          label: 'Verify phone',
          state: _valid
              ? HouselyComponentState.idle
              : HouselyComponentState.disabled,
          onPressed: _valid ? _verify : null,
        ),

        const SizedBox(height: HouselySpace.sm),

        HouselyButton(
          label: _resent ? 'Code sent again' : 'Send code again',
          style: HouselyButtonStyle.text,
          state: _resent
              ? HouselyComponentState.success
              : HouselyComponentState.idle,
          onPressed: () {
            setState(() {
              _resent = true;
            });
          },
        ),

        HouselyButton(
          label: 'Change phone number',
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
    onBack: () => context.go('/verify-phone'),
    child: Column(
      children: [
        HouselySelectionTile(
          title: 'Create a Home',
          subtitle:
              'Set up your property, tenancy, household and shared costs.',
          icon: Icons.home_outlined,
          selected: false,
          onTap: () => context.replace('/create-home'),
        ),
        const SizedBox(height: HouselySpace.sm),
        HouselySelectionTile(
          title: 'Join a Home',
          subtitle:
              'Accept an invitation or request to join an existing household.',
          icon: Icons.group_add_outlined,
          selected: false,
          onTap: () => context.replace('/join-home'),
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
    onBack: () => context.replace('/start-choice'),
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
          onPressed: () => context.replace('/start-choice'),
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

  late String? _selectedMockAddress =
      widget.draft.addressLine1.isNotEmpty &&
          widget.draft.city.isNotEmpty &&
          widget.draft.postcode.isNotEmpty
      ? widget.draft.formattedAddress
      : null;

  bool _addressSearchPerformed = false;
  bool get _hasLookupAddress => _selectedMockAddress != null;

  bool get _hasManualAddress =>
      _showManualAddress &&
      _addressLine1.text.trim().isNotEmpty &&
      _city.text.trim().isNotEmpty &&
      _postcode.text.trim().isNotEmpty;

  bool get _canContinue =>
      _name.text.trim().isNotEmpty && (_hasLookupAddress || _hasManualAddress);

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

      final parts = address.split(',');

      _addressLine1.text = parts.first.trim();
      _city.text = parts.length > 1 ? parts[1].trim() : '';

      _showManualAddress = false;
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

    context.replace('/tenancy-status');
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

              if (_selectedMockAddress != null) {
                _addressLine1.clear();
                _addressLine2.clear();
                _city.clear();
              }

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

              if (_showManualAddress && _selectedMockAddress != null) {
                _addressLine1.clear();
                _addressLine2.clear();
                _city.clear();
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
        context.replace('/upload-tenancy');
        break;

      case TenancyRelationship.notNamedOnTenancy:
        context.replace('/tenancy-detected');
        break;

      case TenancyRelationship.unsure:
        context.replace('/upload-tenancy');
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

class UploadTenancyScreen extends StatefulWidget {
  const UploadTenancyScreen({required this.draft, super.key});

  final AccessDraft draft;

  @override
  State<UploadTenancyScreen> createState() => _UploadTenancyScreenState();
}

class _UploadTenancyScreenState extends State<UploadTenancyScreen> {
  bool _uploading = false;

  bool get _hasDocument => widget.draft.tenancyDocumentName != null;

  Future<void> _chooseMockDocument() async {
    setState(() {
      _uploading = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 650));

    if (!mounted) return;

    setState(() {
      widget.draft
        ..tenancyDocumentName = 'tenancy-agreement.pdf'
        ..tenancyDocumentType = 'PDF'
        ..tenancyDocumentSizeBytes = 1840000
        ..tenancySkipped = false;

      _uploading = false;
    });
  }

  void _removeDocument() {
    setState(() {
      widget.draft
        ..tenancyDocumentName = null
        ..tenancyDocumentType = null
        ..tenancyDocumentSizeBytes = null
        ..tenancyProcessingComplete = false
        ..matchedTenantName = null
        ..tenancyIdentityConfirmed = false
        ..namedTenantVerified = false
        ..homeSetupAdmin = false;

      widget.draft.detectedTenantNames.clear();
    });
  }

  void _continue() {
    if (!_hasDocument) return;

    context.replace('/tenancy-processing');
  }

  @override
  Widget build(BuildContext context) => AccessScaffold(
    eyebrow: 'Tenancy',
    title: 'Add your tenancy agreement',
    message:
        'We’ll use your agreement to identify the people named on the tenancy and help set up the right household access.',
    onBack: () => context.go('/tenancy-status'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HouselyPrivacyNotice(
          title: 'Your tenancy stays private',
          message:
              'Only accepted Home members with the right Household access will be able to view this document.',
        ),

        const SizedBox(height: HouselySpace.xl),

        if (!_hasDocument && !_uploading)
          HouselySurface(
            child: Column(
              children: [
                const Icon(
                  Icons.description_outlined,
                  size: 38,
                  color: HouselyPalette.violet,
                ),

                const SizedBox(height: HouselySpace.md),

                Text(
                  'Upload your tenancy agreement',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: HouselySpace.xs),

                Text(
                  'PDF or image. For this prototype, Housely will use a sample tenancy document.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: HouselySpace.lg),

                HouselyButton(
                  label: 'Choose document',
                  leadingIcon: Icons.upload_file_outlined,
                  onPressed: _chooseMockDocument,
                ),
              ],
            ),
          ),

        if (_uploading)
          const HouselyUploadProgress(
            fileName: 'tenancy-agreement.pdf',
            progress: .65,
          ),

        if (_hasDocument && !_uploading)
          HouselySurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.picture_as_pdf_outlined,
                      color: HouselyPalette.violet,
                    ),

                    const SizedBox(width: HouselySpace.sm),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.draft.tenancyDocumentName!,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),

                          const SizedBox(height: 2),

                          Text(
                            'PDF · 1.8 MB',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
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
              ],
            ),
          ),

        const SizedBox(height: HouselySpace.xl),

        HouselyButton(
          label: 'Continue',
          state: _hasDocument
              ? HouselyComponentState.idle
              : HouselyComponentState.disabled,
          onPressed: _hasDocument ? _continue : null,
        ),

        const SizedBox(height: HouselySpace.sm),

        HouselyButton(
          label: 'I don’t have my tenancy right now',
          style: HouselyButtonStyle.text,
          onPressed: () {
            widget.draft.tenancySkipped = true;

            context.replace('/tenancy-detected');
          },
        ),
      ],
    ),
  );
}

class TenancyProcessingScreen extends StatefulWidget {
  const TenancyProcessingScreen({required this.draft, super.key});

  final AccessDraft draft;

  @override
  State<TenancyProcessingScreen> createState() =>
      _TenancyProcessingScreenState();
}

class _TenancyProcessingScreenState extends State<TenancyProcessingScreen> {
  int _stage = 0;

  static const _stages = [
    'Reading agreement',
    'Finding tenant names',
    'Checking tenancy details',
  ];

  @override
  void initState() {
    super.initState();

    _runMockProcessing();
  }

  Future<void> _runMockProcessing() async {
    for (var i = 0; i < _stages.length; i++) {
      if (!mounted) return;

      setState(() {
        _stage = i;
      });

      await Future<void>.delayed(const Duration(milliseconds: 700));
    }

    if (!mounted) return;

    widget.draft
      ..matchedTenantName = null
      ..tenancyIdentityConfirmed = false
      ..namedTenantVerified = false
      ..homeSetupAdmin = false;

    widget.draft.detectedTenantNames
      ..clear()
      ..addAll(['Muhammad Shaheer Shoukathali', 'Alex Morgan', 'Meera Thomas']);

    context.replace('/tenancy-detected');
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
        HouselySurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const HouselySkeleton(width: 120, height: 16),

              const SizedBox(height: HouselySpace.md),

              const HouselySkeleton(height: 14),

              const SizedBox(height: HouselySpace.sm),

              const HouselySkeleton(width: 220, height: 14),
            ],
          ),
        ),

        const SizedBox(height: HouselySpace.xl),

        HouselyProgress(
          value: (_stage + 1) / _stages.length,
          label: _stages[_stage],
          semanticLabel: 'Tenancy processing progress',
        ),

        const SizedBox(height: HouselySpace.lg),

        Text(
          'Housely is looking for tenant names and basic tenancy information.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    ),
  );
}

class DetectedTenantsScreen extends StatelessWidget {
  const DetectedTenantsScreen({required this.draft, super.key});

  final AccessDraft draft;

  bool get _hasDetectedNames => draft.detectedTenantNames.isNotEmpty;

  @override
  Widget build(BuildContext context) => AccessScaffold(
    eyebrow: 'Tenancy',
    title: _hasDetectedNames
        ? 'We found ${draft.detectedTenantNames.length} people'
        : 'Tenancy details not added yet',
    message: _hasDetectedNames
        ? 'These names appear on the tenancy agreement. Review them before we continue.'
        : 'You can continue setting up your Home and add tenancy details later.',
    onBack: () => context.go('/tenancy-status'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_hasDetectedNames) ...[
          HouselyGroupedList(
            children: draft.detectedTenantNames.map((name) {
              final looksLikeCurrentUser = _looksLikeCurrentUser(name);

              return HouselyMemberRow(
                name: name,
                role: 'Named on tenancy',
                status: looksLikeCurrentUser
                    ? 'Possible match'
                    : 'Not connected',
              );
            }).toList(),
          ),

          const SizedBox(height: HouselySpace.lg),

          const HouselyPrivacyNotice(
            title: 'No one has access yet',
            message:
                'Finding a name in the agreement does not automatically add that person to your Home.',
          ),
        ] else ...[
          const HouselyMessageState(
            kind: HouselyMessageKind.empty,
            title: 'No tenancy document',
            message:
                'You can upload your tenancy later from your Home settings.',
          ),
        ],

        const SizedBox(height: HouselySpace.xl),

        HouselyButton(
          label: _hasDetectedNames ? 'Review my match' : 'Continue setup',
          onPressed: () {
            if (_hasDetectedNames) {
              context.replace('/tenant-match');
            } else {
              context.replace('/invite-members');
            }
          },
        ),

        if (!_hasDetectedNames) ...[
          const SizedBox(height: HouselySpace.sm),

          HouselyButton(
            label: 'Upload tenancy instead',
            style: HouselyButtonStyle.text,
            onPressed: () => context.replace('/upload-tenancy'),
          ),
        ],
      ],
    ),
  );

  bool _looksLikeCurrentUser(String tenantName) {
    if (draft.name.trim().isEmpty) return false;

    final appName = draft.name.toLowerCase();
    final documentName = tenantName.toLowerCase();

    return appName == documentName ||
        documentName.contains(appName) ||
        appName.contains(documentName);
  }
}

class TenantMatchScreen extends StatefulWidget {
  const TenantMatchScreen({required this.draft, super.key});

  final AccessDraft draft;

  @override
  State<TenantMatchScreen> createState() => _TenantMatchScreenState();
}

class _TenantMatchScreenState extends State<TenantMatchScreen> {
  String? _selectedName;

  @override
  void initState() {
    super.initState();

    _selectedName = widget.draft.matchedTenantName;
  }

  bool _looksLikeCurrentUser(String tenantName) {
    final accountName = widget.draft.name.trim().toLowerCase();

    if (accountName.isEmpty) return false;

    final documentName = tenantName.trim().toLowerCase();

    return accountName == documentName ||
        documentName.contains(accountName) ||
        accountName.contains(documentName);
  }

  void _continue() {
    if (_selectedName == null) return;

    widget.draft.matchedTenantName = _selectedName;

    context.replace('/tenant-match-confirm');
  }

  @override
  Widget build(BuildContext context) => AccessScaffold(
    eyebrow: 'Tenancy',
    title: 'Which name is yours?',
    message: 'Choose the name that represents you on the tenancy agreement.',
    onBack: () => context.go('/tenancy-detected'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final name in widget.draft.detectedTenantNames) ...[
          HouselySelectionTile(
            title: name,
            subtitle: _looksLikeCurrentUser(name)
                ? 'Likely match with your Housely profile'
                : 'Named on the tenancy',
            icon: _looksLikeCurrentUser(name)
                ? Icons.person_search_outlined
                : Icons.person_outline_rounded,
            selected: _selectedName == name,
            onTap: () {
              setState(() {
                _selectedName = name;
              });
            },
          ),

          const SizedBox(height: HouselySpace.sm),
        ],

        const SizedBox(height: HouselySpace.md),

        const HouselyPrivacyNotice(
          title: 'You stay in control',
          message:
              'Housely can suggest a likely match from your name, but it will never confirm the match without you.',
        ),

        const SizedBox(height: HouselySpace.xl),

        HouselyButton(
          label: 'Continue',
          state: _selectedName != null
              ? HouselyComponentState.idle
              : HouselyComponentState.disabled,
          onPressed: _selectedName != null ? _continue : null,
        ),

        const SizedBox(height: HouselySpace.sm),

        HouselyButton(
          label: 'None of these are me',
          style: HouselyButtonStyle.text,
          onPressed: () {
            widget.draft.matchedTenantName = null;

            context.replace('/tenant-match-missing');
          },
        ),
      ],
    ),
  );
}

class TenantMatchConfirmScreen extends StatelessWidget {
  const TenantMatchConfirmScreen({required this.draft, super.key});

  final AccessDraft draft;

  void _confirm(BuildContext context) {
    if (draft.matchedTenantName == null) {
      context.go('/tenant-match');
      return;
    }

    draft
      ..tenancyIdentityConfirmed = true
      ..namedTenantVerified = true;

    context.replace('/tenancy-role');
  }

  @override
  Widget build(BuildContext context) => AccessScaffold(
    eyebrow: 'Tenancy',
    title: 'Confirm this is you',
    message:
        'Make sure the selected tenancy name belongs to you before continuing.',
    onBack: () => context.go('/tenant-match'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HouselySurface(
          child: Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 32),

              const SizedBox(width: HouselySpace.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      draft.matchedTenantName ?? 'No name selected',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    const SizedBox(height: 2),

                    Text(
                      'Named on tenancy',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: HouselySpace.lg),

        const HouselyPrivacyNotice(
          title: 'What this confirmation means',
          message:
              'You are confirming that this tenancy name belongs to your Housely account. This does not create or change any legal tenancy rights.',
        ),

        const SizedBox(height: HouselySpace.xl),

        HouselyButton(
          label: 'Yes, this is me',
          onPressed: () => _confirm(context),
        ),

        const SizedBox(height: HouselySpace.sm),

        HouselyButton(
          label: 'Choose another name',
          style: HouselyButtonStyle.text,
          onPressed: () => context.go('/tenant-match'),
        ),
      ],
    ),
  );
}

class TenantMatchMissingScreen extends StatelessWidget {
  const TenantMatchMissingScreen({required this.draft, super.key});

  final AccessDraft draft;

  @override
  Widget build(BuildContext context) => AccessScaffold(
    eyebrow: 'Tenancy',
    title: 'We couldn’t match your name',
    message:
        'That’s okay. It may be a different document, a name variation, or you may not be named on this agreement.',
    onBack: () => context.go('/tenant-match'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HouselyMessageState(
          kind: HouselyMessageKind.empty,
          title: 'No confirmed match',
          message:
              'Housely will not mark you as a verified named tenant unless you confirm a matching tenancy name.',
        ),

        const SizedBox(height: HouselySpace.xl),

        HouselyButton(
          label: 'Review names again',
          onPressed: () => context.go('/tenant-match'),
        ),

        const SizedBox(height: HouselySpace.sm),

        HouselyButton(
          label: 'Continue without verification',
          style: HouselyButtonStyle.secondary,
          onPressed: () {
            draft
              ..matchedTenantName = null
              ..tenancyIdentityConfirmed = false
              ..namedTenantVerified = false
              ..homeSetupAdmin = false;

            context.replace('/tenancy-members-review');
          },
        ),
      ],
    ),
  );
}

class TenancyRoleScreen extends StatelessWidget {
  const TenancyRoleScreen({required this.draft, super.key});

  final AccessDraft draft;

  void _continue(BuildContext context) {
    draft.homeSetupAdmin = true;

    context.replace('/tenancy-members-review');
  }

  @override
  Widget build(BuildContext context) => AccessScaffold(
    eyebrow: 'Home access',
    title: 'Your tenancy status is confirmed',
    message:
        'Housely can now give you the correct setup permissions for this Home.',
    onBack: () => context.go('/tenant-match-confirm'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HouselyMessageState(
          kind: HouselyMessageKind.success,
          title: 'Named tenancy member',
          message:
              '${draft.matchedTenantName ?? draft.name} has been confirmed as matching your Housely account.',
        ),

        const SizedBox(height: HouselySpace.lg),

        HouselySurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Home setup admin',
                style: Theme.of(context).textTheme.titleMedium,
              ),

              const SizedBox(height: HouselySpace.xs),

              Text(
                'Because you are the first verified tenancy member setting up this Home, you can complete the household setup, connect members and manage initial Home access.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),

        const SizedBox(height: HouselySpace.lg),

        const HouselyPrivacyNotice(
          title: 'App access is not legal authority',
          message:
              'Being a Home setup admin only controls Housely features. It does not make you the lead tenant, landlord or give you additional legal rights over other tenancy members.',
        ),

        const SizedBox(height: HouselySpace.xl),

        HouselyButton(label: 'Continue', onPressed: () => _continue(context)),
      ],
    ),
  );
}

class TenancyMembersReviewScreen extends StatelessWidget {
  const TenancyMembersReviewScreen({required this.draft, super.key});

  final AccessDraft draft;

  @override
  Widget build(BuildContext context) => AccessScaffold(
    eyebrow: 'Household',
    title: 'Review tenancy members',
    message:
        'These people were found in the agreement. They are not automatically added to your Housely Home.',
    onBack: () {
      if (draft.namedTenantVerified) {
        context.go('/tenancy-role');
      } else {
        context.go('/tenant-match-missing');
      }
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HouselyGroupedList(
          children: draft.detectedTenantNames.map((name) {
            final isCurrentUser = name == draft.matchedTenantName;

            return HouselyMemberRow(
              name: name,
              role: 'Named on tenancy',
              status: isCurrentUser ? 'You · Verified' : 'Not connected',
            );
          }).toList(),
        ),

        const SizedBox(height: HouselySpace.lg),

        const HouselyPrivacyNotice(
          title: 'Names do not create accounts',
          message:
              'Other tenancy members will only receive Home access after they are connected and accept an invitation.',
        ),

        const SizedBox(height: HouselySpace.xl),

        HouselyButton(
          label: 'Connect household members',
          onPressed: () => context.replace('/invite-members'),
        ),

        const SizedBox(height: HouselySpace.sm),

        HouselyButton(
          label: 'Do this later',
          style: HouselyButtonStyle.text,
          onPressed: () => context.go('/home'),
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
    eyebrow: 'Household',
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
          members: [
            widget.draft.name.isEmpty
                ? 'Muhammad Shaheer Shoukathali'
                : widget.draft.name,
          ],
        ),
        const SizedBox(height: HouselySpace.xl),
        HouselyField(
          label: 'Phone number',
          hint: '+44 7700 900123',
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
