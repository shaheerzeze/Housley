import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../design_system/components/components.dart';
import '../../design_system/theme/housely_tokens.dart';
import 'access_draft.dart';
import 'access_scaffold.dart';
import 'join_home_state.dart';

class InviteToHomeScreen extends StatelessWidget {
  const InviteToHomeScreen({
    required this.draft,
    required this.state,
    super.key,
  });

  final AccessDraft draft;
  final JoinHomeState state;

  Future<void> _copyCode(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: state.homeCode));

    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Home code copied')));
  }

  Future<void> _copyInvite(BuildContext context) async {
    final homeName = draft.homeName.trim().isEmpty
        ? 'my Housely Home'
        : draft.homeName.trim();

    final message =
        '''You’re invited to join $homeName on Housely.

Home code: ${state.homeCode}

Open Housely and choose Join a Home, or open:
${state.inviteLink}''';

    await Clipboard.setData(ClipboardData(text: message));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invite copied — share it in any messaging app'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeName = draft.homeName.trim().isEmpty
        ? 'Your Home'
        : draft.homeName.trim();

    return AccessScaffold(
      eyebrow: 'Household',
      title: 'Invite to your Home',
      message:
          'Share the Home code or QR with someone you trust to join $homeName.',
      onBack: () => context.pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HouselySurface(
            child: Column(
              children: [
                Text(
                  'Home code',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: HouselySpace.sm),
                SelectableText(
                  state.homeCode,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: HouselySpace.md),
                HouselyButton(
                  label: 'Copy code',
                  leadingIcon: Icons.copy_rounded,
                  style: HouselyButtonStyle.secondary,
                  onPressed: () => _copyCode(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: HouselySpace.lg),
          HouselySurface(
            child: Column(
              children: [
                Text(
                  'Scan to join',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: HouselySpace.md),
                Container(
                  padding: const EdgeInsets.all(HouselySpace.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: QrImageView(
                    data: state.inviteLink,
                    version: QrVersions.auto,
                    size: 210,
                  ),
                ),
                const SizedBox(height: HouselySpace.md),
                Text(
                  'This QR contains the same Home code. Scanning it opens the same Join Home flow.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: HouselySpace.lg),
          const HouselyPrivacyNotice(
            title: 'Share carefully',
            message:
                'Anyone with this code can reach the Home join flow. In the backend version, codes can be rotated, revoked and protected with membership rules.',
          ),
          const SizedBox(height: HouselySpace.xl),
          HouselyButton(
            label: 'Share invite',
            leadingIcon: Icons.ios_share_rounded,
            onPressed: () => _copyInvite(context),
          ),
        ],
      ),
    );
  }
}

class JoinHomeScreen extends StatefulWidget {
  const JoinHomeScreen({
    required this.draft,
    required this.state,
    this.initialCode,
    super.key,
  });

  final AccessDraft draft;
  final JoinHomeState state;
  final String? initialCode;

  @override
  State<JoinHomeScreen> createState() => _JoinHomeScreenState();
}

class _JoinHomeScreenState extends State<JoinHomeScreen> {
  late final TextEditingController _code = TextEditingController(
    text: widget.initialCode?.isNotEmpty == true
        ? widget.state.normaliseCode(widget.initialCode!)
        : widget.state.enteredCode,
  );

  bool _autoLookupStarted = false;

  bool get _canSearch =>
      _code.text.trim().isNotEmpty && !widget.state.isLoading;

  @override
  void initState() {
    super.initState();

    widget.state.addListener(_stateChanged);

    if (widget.initialCode?.trim().isNotEmpty == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoLookupIncomingCode();
      });
    }
  }

  void _stateChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _autoLookupIncomingCode() async {
    if (_autoLookupStarted || !mounted) return;
    _autoLookupStarted = true;

    final found = await widget.state.lookupHome(_code.text);

    if (!mounted) return;

    if (found) {
      context.replace('/join-home-preview');
    }
  }

  Future<void> _findHome() async {
    FocusScope.of(context).unfocus();

    final found = await widget.state.lookupHome(_code.text);

    if (!mounted) return;

    if (found) {
      context.push('/join-home-preview');
    }
  }

  @override
  void dispose() {
    widget.state.removeListener(_stateChanged);
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = switch (widget.state.status) {
      JoinHomeStatus.invalidCode => (
        'Home not found',
        'Check the code and try again. Home codes are not case-sensitive.',
      ),
      JoinHomeStatus.expiredCode => (
        'This Home code has expired',
        'Ask a Home admin for a new code or QR.',
      ),
      JoinHomeStatus.networkError => (
        'We couldn’t check the Home',
        'Check your connection and try again.',
      ),
      _ => null,
    };

    return AccessScaffold(
      eyebrow: 'Join a Home',
      title: 'Join your household',
      message:
          'Enter the code shared by a Home admin, or scan the Home QR code.',
      onBack: () => context.go('/start-choice'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HouselyPrivacyNotice(
            title: 'No public Home search',
            message:
                'Housely does not let people search households by address. You need a Home code, QR or invitation link.',
          ),
          const SizedBox(height: HouselySpace.xl),
          HouselyField(
            label: 'Home code',
            hint: 'HSLY-7K4P9Q',
            controller: _code,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: const [HouselyHomeCodeFormatter()],
            helperText: 'Enter the code shared by your Home admin.',
            onChanged: (value) {
              widget.state.prefillCode(value);
              setState(() {});
            },
          ),
          if (error != null) ...[
            const SizedBox(height: HouselySpace.md),
            HouselyMessageState(
              kind: HouselyMessageKind.empty,
              title: error.$1,
              message: error.$2,
            ),
          ],
          const SizedBox(height: HouselySpace.xl),
          HouselyButton(
            label: 'Find Home',
            state: widget.state.isLoading
                ? HouselyComponentState.loading
                : _canSearch
                ? HouselyComponentState.idle
                : HouselyComponentState.disabled,
            onPressed: _canSearch ? _findHome : null,
          ),
          const SizedBox(height: HouselySpace.md),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: HouselySpace.md,
                ),
                child: Text(
                  'or',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: HouselySpace.md),
          HouselyButton(
            label: 'Scan QR code',
            leadingIcon: Icons.qr_code_scanner_rounded,
            style: HouselyButtonStyle.secondary,
            onPressed: () => context.push('/scan-home-qr'),
          ),
        ],
      ),
    );
  }
}

class ScanHomeQrScreen extends StatefulWidget {
  const ScanHomeQrScreen({required this.state, super.key});

  final JoinHomeState state;

  @override
  State<ScanHomeQrScreen> createState() => _ScanHomeQrScreenState();
}

class _ScanHomeQrScreenState extends State<ScanHomeQrScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handlingScan = false;
  String? _error;

  Future<void> _handlePayload(String payload) async {
    if (_handlingScan) return;
    _handlingScan = true;

    final found = await widget.state.lookupQrPayload(payload);

    if (!mounted) return;

    if (found) {
      await _controller.stop();
      if (!mounted) return;
      context.replace('/join-home-preview');
      return;
    }

    setState(() {
      _error = switch (widget.state.status) {
        JoinHomeStatus.expiredCode => 'That Housely QR has expired.',
        JoinHomeStatus.networkError => 'We couldn’t check that QR. Try again.',
        _ => 'That isn’t a valid Housely Home QR code.',
      };
      _handlingScan = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraScannerUnsupported =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux);

    if (cameraScannerUnsupported) {
      return AccessScaffold(
        eyebrow: 'Scan QR',
        title: 'Camera scanning needs a supported device',
        message:
            'Use Android, iOS, macOS or web to scan with the camera. On Windows development, you can still test the exact QR payload flow below.',
        onBack: () => context.pop(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const HouselyPrivacyNotice(
              title: 'Same Join Home engine',
              message:
                  'The demo scan below sends the same Housely QR payload that a real camera scan would send.',
            ),
            const SizedBox(height: HouselySpace.xl),
            HouselyButton(
              label: 'Simulate scanning this Home QR',
              leadingIcon: Icons.qr_code_scanner_rounded,
              onPressed: () => _handlePayload(widget.state.inviteLink),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: MobileScanner(
                controller: _controller,
                onDetect: (capture) {
                  if (capture.barcodes.isEmpty) return;
                  final payload = capture.barcodes.first.rawValue;
                  if (payload == null || payload.trim().isEmpty) return;
                  _handlePayload(payload);
                },
              ),
            ),

            Center(
              child: IgnorePointer(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ),
            ),
            Positioned(
              left: HouselySpace.lg,
              right: HouselySpace.lg,
              bottom: HouselySpace.xl,
              child: Column(
                children: [
                  Text(
                    'Point the camera at a Housely Home QR code',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: HouselySpace.md),
                    Container(
                      padding: const EdgeInsets.all(HouselySpace.md),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .72),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                  const SizedBox(height: HouselySpace.lg),

                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text(
                      'Go back',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JoinHomePreviewScreen extends StatelessWidget {
  const JoinHomePreviewScreen({
    required this.draft,
    required this.state,
    super.key,
  });

  final AccessDraft draft;
  final JoinHomeState state;

  Future<void> _join(BuildContext context) async {
    await state.joinHome(verifiedPhone: draft.phone, displayName: draft.name);

    if (!context.mounted) return;

    context.replace('/join-home-success');
  }

  @override
  Widget build(BuildContext context) {
    if (!state.hasResolvedHome) {
      return AccessScaffold(
        eyebrow: 'Join a Home',
        title: 'Home details unavailable',
        message: 'The Home lookup is no longer active. Enter the code again.',
        onBack: () => context.go('/join-home'),
        child: HouselyButton(
          label: 'Enter code again',
          onPressed: () => context.go('/join-home'),
        ),
      );
    }

    return AnimatedBuilder(
      animation: state,
      builder: (context, _) => AccessScaffold(
        eyebrow: 'Home found',
        title: state.resolvedHomeName ?? 'Housely Home',
        message: 'Check that this is the household you intended to join.',
        onBack: () => context.pop(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HouselySurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.resolvedHomeName ?? 'Home',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: HouselySpace.xs),
                  Text(
                    state.resolvedHomeAddress ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: HouselySpace.md),
                  Text(
                    'Home admin: ${state.resolvedHomeAdmin ?? 'Household admin'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: HouselySpace.lg),
            const HouselyPrivacyNotice(
              title: 'Joining creates Home access',
              message:
                  'For this prototype, a valid Home code lets the verified Housely account join. The backend version will make this an idempotent membership transaction and can add approval or stronger invite rules.',
            ),
            const SizedBox(height: HouselySpace.xl),
            HouselyButton(
              label: 'Join this Home',
              state: state.status == JoinHomeStatus.joining
                  ? HouselyComponentState.loading
                  : HouselyComponentState.idle,
              onPressed: state.status == JoinHomeStatus.joining
                  ? null
                  : () => _join(context),
            ),
            const SizedBox(height: HouselySpace.sm),
            HouselyButton(
              label: 'This isn’t my Home',
              style: HouselyButtonStyle.text,
              onPressed: () {
                state.reset();
                context.go('/join-home');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class JoinHomeSuccessScreen extends StatelessWidget {
  const JoinHomeSuccessScreen({required this.state, super.key});

  final JoinHomeState state;

  @override
  Widget build(BuildContext context) {
    final matchedNamedTenant =
        state.joinedAs == JoinHomeMemberMatch.namedTenant;

    return AccessScaffold(
      eyebrow: 'Joined',
      title: 'You’re in the Home',
      message: matchedNamedTenant
          ? 'Your verified account matched an existing tenancy member in this prototype.'
          : 'Your verified account has joined as a household member in this prototype.',
      onBack: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HouselyMessageState(
            kind: HouselyMessageKind.success,
            title: state.resolvedHomeName ?? 'Home joined',
            message: matchedNamedTenant
                ? '${state.joinedMemberName ?? 'Your account'} was linked to the existing named tenancy member.'
                : '${state.joinedMemberName ?? 'Your account'} was added as a household member.',
          ),
          const SizedBox(height: HouselySpace.lg),
          const HouselyPrivacyNotice(
            title: 'No duplicate tenancy member',
            message:
                'When a verified phone/account matches an existing tenancy identity, Housely links the account to that record instead of creating a second person.',
          ),
          const SizedBox(height: HouselySpace.xl),
          HouselyButton(
            label: 'Open Home',
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
    );
  }
}
