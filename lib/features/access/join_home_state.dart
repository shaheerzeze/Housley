import 'package:flutter/foundation.dart';

enum JoinHomeStatus {
  idle,
  lookingUp,
  homeFound,
  invalidCode,
  expiredCode,
  networkError,
  joining,
  joined,
  alreadyMember,
}

enum JoinHomeMemberMatch { namedTenant, householdMember }

class JoinHomeState extends ChangeNotifier {
  static const String demoHomeCode = 'HSLY-7K4P9Q';
  static const String expiredDemoCode = 'HSLY-EXPIRED';
  static const String networkErrorDemoCode = 'HSLY-OFFLINE';

  JoinHomeStatus status = JoinHomeStatus.idle;

  String enteredCode = '';

  String? resolvedHomeId;
  String? resolvedHomeName;
  String? resolvedHomeAddress;
  String? resolvedHomeAdmin;

  JoinHomeMemberMatch? joinedAs;
  String? joinedMemberName;

  String get homeCode => demoHomeCode;

  String get inviteLink => 'housely://join-home?code=$homeCode';

  bool get isLoading =>
      status == JoinHomeStatus.lookingUp || status == JoinHomeStatus.joining;

  bool get hasResolvedHome => status == JoinHomeStatus.homeFound;

  bool get canJoin => hasResolvedHome;

  void reset() {
    status = JoinHomeStatus.idle;
    enteredCode = '';
    _clearResolvedHome();
    joinedAs = null;
    joinedMemberName = null;
    notifyListeners();
  }

  void prefillCode(String value) {
    final normalised = normaliseCode(value);
    if (enteredCode == normalised) return;

    enteredCode = normalised;
    notifyListeners();
  }

  String normaliseCode(String rawValue) {
    final trimmed = rawValue.trim();

    if (trimmed.toLowerCase().startsWith('housely://')) {
      final uri = Uri.tryParse(trimmed);
      final queryCode = uri?.queryParameters['code'];
      if (queryCode != null && queryCode.trim().isNotEmpty) {
        return queryCode.trim().toUpperCase();
      }

      if (uri != null && uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.last.trim().toUpperCase();
      }
    }

    if (trimmed.contains('?code=')) {
      final uri = Uri.tryParse(trimmed);
      final queryCode = uri?.queryParameters['code'];
      if (queryCode != null && queryCode.trim().isNotEmpty) {
        return queryCode.trim().toUpperCase();
      }
    }

    return trimmed.replaceAll(' ', '').toUpperCase();
  }

  Future<bool> lookupHome(String rawCode) async {
    final code = normaliseCode(rawCode);
    enteredCode = code;
    _clearResolvedHome();

    if (code.isEmpty) {
      status = JoinHomeStatus.invalidCode;
      notifyListeners();
      return false;
    }

    status = JoinHomeStatus.lookingUp;
    notifyListeners();

    // MOCK LOOKUP ONLY.
    // Later this becomes JoinHomeRepository.findHomeByCode().
    await Future<void>.delayed(const Duration(milliseconds: 650));

    if (code == networkErrorDemoCode) {
      status = JoinHomeStatus.networkError;
      notifyListeners();
      return false;
    }

    if (code == expiredDemoCode) {
      status = JoinHomeStatus.expiredCode;
      notifyListeners();
      return false;
    }

    if (code != demoHomeCode) {
      status = JoinHomeStatus.invalidCode;
      notifyListeners();
      return false;
    }

    resolvedHomeId = 'mock-home-george-street';
    resolvedHomeName = 'George Street Flat';
    resolvedHomeAddress = '24 George Street, Edinburgh, EH2 2LE';
    resolvedHomeAdmin = 'Shaheer';
    status = JoinHomeStatus.homeFound;
    notifyListeners();
    return true;
  }

  Future<bool> lookupQrPayload(String rawPayload) {
    return lookupHome(rawPayload);
  }

  Future<void> joinHome({
    required String verifiedPhone,
    required String displayName,
  }) async {
    if (status == JoinHomeStatus.joined) {
      status = JoinHomeStatus.alreadyMember;
      notifyListeners();
      return;
    }

    if (!hasResolvedHome) return;

    status = JoinHomeStatus.joining;
    notifyListeners();

    // MOCK JOIN ONLY.
    // Later this becomes an idempotent backend membership transaction.
    await Future<void>.delayed(const Duration(milliseconds: 650));

    final normalisedPhone = verifiedPhone
        .trim()
        .replaceAll(' ', '')
        .replaceAll('-', '');

    // Existing demo tenancy-member match.
    if (normalisedPhone == '+447700900123') {
      joinedAs = JoinHomeMemberMatch.namedTenant;
      joinedMemberName = 'Alex Morgan';
    } else {
      joinedAs = JoinHomeMemberMatch.householdMember;
      joinedMemberName = displayName.trim().isEmpty
          ? 'Household member'
          : displayName.trim();
    }

    status = JoinHomeStatus.joined;
    notifyListeners();
  }

  void _clearResolvedHome() {
    resolvedHomeId = null;
    resolvedHomeName = null;
    resolvedHomeAddress = null;
    resolvedHomeAdmin = null;
  }
}
