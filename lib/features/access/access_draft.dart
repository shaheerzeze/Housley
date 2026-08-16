import 'package:flutter/foundation.dart';

import 'household_member.dart';

enum TenancyRelationship { namedOnTenancy, notNamedOnTenancy, unsure }

class AccessDraft extends ChangeNotifier {
  // Account
  String name = '';

  /// Required and later verified.
  /// Store the full international number, e.g. +447700900123.
  String phone = '';

  /// Optional.
  String email = '';

  String password = '';

  // Sign in / recovery
  String signInIdentifier = '';
  String recoveryIdentifier = '';

  bool get hasEmail => email.trim().isNotEmpty;

  bool phoneVerified = false;

  // Home
  String homeName = '';
  String addressLine1 = '';
  String addressLine2 = '';
  String city = '';
  String postcode = '';
  String country = 'United Kingdom';

  // Tenancy
  TenancyRelationship? tenancyRelationship;

  String? tenancyDocumentName;
  String? tenancyDocumentType;
  int? tenancyDocumentSizeBytes;

  bool tenancySkipped = false;
  bool tenancyProcessingComplete = false;

  final List<String> detectedTenantNames = [];

  // Tenancy identity matching
  String? matchedTenantName;

  bool tenancyIdentityConfirmed = false;
  bool namedTenantVerified = false;

  /// Housely product permission only.
  /// This does not represent extra legal tenancy rights.
  bool homeSetupAdmin = false;
  bool tenancySetupComplete = false;

  // Members
  final List<String> invites = [];

  /// Structured household members used by Phase 4+.
  final List<HouseholdMember> householdMembers = [];

  /// Tenancy member currently being connected / managed.
  String? selectedTenantMemberId;

  /// Phone number currently being searched.
  String memberLookupPhone = '';

  /// Mock account found from the exact phone lookup.
  String? foundHouselyUserId;
  String? foundHouselyUserName;
  String? foundHouselyUserPhone;

  /// Mock incoming invitation context.
  /// Later this comes from the backend.
  String? incomingInvitationMemberId;

  int householdMemberSequence = 0;

  String nextHouseholdMemberId() {
    householdMemberSequence++;
    return 'household-member-$householdMemberSequence';
  }

  HouseholdMember? get incomingInvitationMember {
    final id = incomingInvitationMemberId;
    if (id == null) return null;

    for (final member in householdMembers) {
      if (member.id == id) return member;
    }

    return null;
  }

  HouseholdMember? get selectedTenantMember {
    final id = selectedTenantMemberId;
    if (id == null) return null;

    for (final member in householdMembers) {
      if (member.id == id) return member;
    }

    return null;
  }

  HouseholdMember? memberById(String id) {
    for (final member in householdMembers) {
      if (member.id == id) return member;
    }
    return null;
  }

  HouseholdMember? _namedTenantByName(String tenantName) {
    final normalised = tenantName.trim().toLowerCase();

    for (final member in householdMembers) {
      if (member.type == HouseholdMemberType.namedTenant &&
          member.name.trim().toLowerCase() == normalised) {
        return member;
      }
    }

    return null;
  }

  /// Reconciles document-derived tenancy people with the current identity.
  ///
  /// Important: this does not blindly recreate every member. Existing review,
  /// invitation and connection state is preserved for people who are still in
  /// the same tenancy. Only identity-derived state ("this is me") is changed
  /// when [matchedTenantName] changes.
  void initialiseHouseholdMembersFromTenancy({bool notify = false}) {
    if (detectedTenantNames.isEmpty) {
      if (notify) notifyListeners();
      return;
    }

    final detectedKeys = detectedTenantNames
        .map((value) => value.trim().toLowerCase())
        .toSet();

    // Remove only document-derived named tenants that no longer exist in the
    // current processed document. Manually-added household members/guests stay.
    householdMembers.removeWhere(
      (member) =>
          member.type == HouseholdMemberType.namedTenant &&
          !detectedKeys.contains(member.name.trim().toLowerCase()),
    );

    for (var index = 0; index < detectedTenantNames.length; index++) {
      final tenantName = detectedTenantNames[index];
      final isYou = tenantName == matchedTenantName;
      var member = _namedTenantByName(tenantName);

      if (member == null) {
        member = HouseholdMember(
          id: 'tenancy-member-$index',
          name: tenantName,
          type: HouseholdMemberType.namedTenant,
          appRole: HouseholdAppRole.standard,
          connectionStatus: HouseholdConnectionStatus.notConnected,
          invitationStatus: HouseholdInvitationStatus.none,
          permissions: HouseholdMemberPermissions.standardNamedTenant,
          tenancyReviewStatus: TenancyMemberReviewStatus.needsReview,
        );
        householdMembers.add(member);
      }

      final wasCurrentUser =
          member.isCurrentUser || member.houselyUserId == 'current-user';

      if (isYou) {
        member
          ..isCurrentUser = true
          ..isVerifiedNamedTenant = namedTenantVerified
          ..connectionStatus = HouseholdConnectionStatus.connected
          ..invitationStatus = HouseholdInvitationStatus.none
          ..houselyUserId = 'current-user'
          ..phone = phone.isEmpty ? member.phone : phone
          ..appRole = homeSetupAdmin
              ? HouseholdAppRole.setupAdmin
              : HouseholdAppRole.standard
          ..permissions = homeSetupAdmin
              ? HouseholdMemberPermissions.setupAdmin
              : HouseholdMemberPermissions.standardNamedTenant
          ..tenancyReviewStatus = TenancyMemberReviewStatus.confirmed;
      } else if (wasCurrentUser) {
        // This person used to be "you", but the user went back and selected a
        // different tenancy identity. Clear only identity-derived state.
        member
          ..isCurrentUser = false
          ..isVerifiedNamedTenant = false
          ..connectionStatus = HouseholdConnectionStatus.notConnected
          ..invitationStatus = HouseholdInvitationStatus.none
          ..houselyUserId = null
          ..phone = null
          ..appRole = HouseholdAppRole.standard
          ..permissions = HouseholdMemberPermissions.standardNamedTenant
          ..tenancyReviewStatus = TenancyMemberReviewStatus.needsReview;
      } else {
        member
          ..isCurrentUser = false
          ..isVerifiedNamedTenant = false;
      }
    }

    if (selectedTenantMemberId != null &&
        memberById(selectedTenantMemberId!) == null) {
      selectedTenantMemberId = null;
    }

    if (notify) notifyListeners();
  }

  void updateTenancyRelationship(TenancyRelationship relationship) {
    if (tenancyRelationship == relationship) return;

    tenancyRelationship = relationship;
    tenancyDocumentName = null;
    tenancyDocumentType = null;
    tenancyDocumentSizeBytes = null;
    tenancySkipped = false;
    tenancySetupComplete = false;

    resetProcessedTenancy(notify: false);
    notifyListeners();
  }

  void setDetectedTenantNames(Iterable<String> names) {
    resetTenancyIdentity(notify: false);

    detectedTenantNames
      ..clear()
      ..addAll(names);

    tenancyProcessingComplete = true;
    initialiseHouseholdMembersFromTenancy();
    notifyListeners();
  }

  void setMatchedTenantName(String? tenantName) {
    if (matchedTenantName == tenantName) return;

    matchedTenantName = tenantName;
    tenancyIdentityConfirmed = false;
    namedTenantVerified = false;
    homeSetupAdmin = false;

    // Reconcile immediately so going back, changing "which name is yours?",
    // and returning to review never leaves the old person marked as current.
    initialiseHouseholdMembersFromTenancy();
    notifyListeners();
  }

  void confirmTenancyIdentity() {
    if (matchedTenantName == null) return;

    tenancyIdentityConfirmed = true;
    namedTenantVerified = true;
    initialiseHouseholdMembersFromTenancy();
    notifyListeners();
  }

  void continueWithoutTenancyVerification() {
    matchedTenantName = null;
    tenancyIdentityConfirmed = false;
    namedTenantVerified = false;
    homeSetupAdmin = false;
    initialiseHouseholdMembersFromTenancy();
    notifyListeners();
  }

  void setHomeSetupAdmin(bool value) {
    homeSetupAdmin = value;
    initialiseHouseholdMembersFromTenancy();
    notifyListeners();
  }

  void selectTenantMember(String? memberId) {
    selectedTenantMemberId = memberId;
    notifyListeners();
  }

  void confirmTenancyMember(String memberId) {
    final member = memberById(memberId);
    if (member == null) return;

    member.tenancyReviewStatus = TenancyMemberReviewStatus.confirmed;
    notifyListeners();
  }

  void excludeTenancyMember(String memberId) {
    final member = memberById(memberId);
    if (member == null || member.isCurrentUser) return;

    member.tenancyReviewStatus = TenancyMemberReviewStatus.excluded;

    if (selectedTenantMemberId == memberId) {
      selectedTenantMemberId = null;
    }

    notifyListeners();
  }

  void resetMemberLookup({bool notify = true}) {
    selectedTenantMemberId = null;
    memberLookupPhone = '';
    foundHouselyUserId = null;
    foundHouselyUserName = null;
    foundHouselyUserPhone = null;
    incomingInvitationMemberId = null;

    if (notify) notifyListeners();
  }

  void clearLookupResult({bool keepSelection = true}) {
    memberLookupPhone = '';
    foundHouselyUserId = null;
    foundHouselyUserName = null;
    foundHouselyUserPhone = null;

    if (!keepSelection) selectedTenantMemberId = null;
    notifyListeners();
  }

  void setLookupResult({
    required String phone,
    String? userId,
    String? userName,
  }) {
    memberLookupPhone = phone;
    foundHouselyUserPhone = phone;
    foundHouselyUserId = userId;
    foundHouselyUserName = userName;
    notifyListeners();
  }

  void sendInvitationToSelectedMember() {
    final member = selectedTenantMember;
    if (member == null || foundHouselyUserId == null) return;

    member
      ..phone = foundHouselyUserPhone
      ..houselyUserId = foundHouselyUserId
      ..connectionStatus = HouseholdConnectionStatus.invitePending
      ..invitationStatus = HouseholdInvitationStatus.pending
      ..tenancyReviewStatus = TenancyMemberReviewStatus.confirmed;

    notifyListeners();
  }

  void resendInvitation(String memberId) {
    final member = memberById(memberId);
    if (member == null) return;

    member
      ..invitationStatus = HouseholdInvitationStatus.pending
      ..connectionStatus = HouseholdConnectionStatus.invitePending;

    notifyListeners();
  }

  void cancelInvitation(String memberId) {
    final member = memberById(memberId);
    if (member == null) return;

    member
      ..invitationStatus = HouseholdInvitationStatus.cancelled
      ..connectionStatus = HouseholdConnectionStatus.notConnected
      ..houselyUserId = null;

    notifyListeners();
  }

  void markSelectedMemberOffApp() {
    final member = selectedTenantMember;
    if (member == null) return;

    member
      ..phone = foundHouselyUserPhone ?? memberLookupPhone
      ..houselyUserId = null
      ..connectionStatus = HouseholdConnectionStatus.offApp
      ..invitationStatus = HouseholdInvitationStatus.none
      ..tenancyReviewStatus = TenancyMemberReviewStatus.confirmed;

    notifyListeners();
  }

  void acceptIncomingInvitation() {
    final member = incomingInvitationMember;
    if (member == null) return;

    member
      ..invitationStatus = HouseholdInvitationStatus.accepted
      ..connectionStatus = HouseholdConnectionStatus.connected;

    notifyListeners();
  }

  void declineIncomingInvitation() {
    final member = incomingInvitationMember;
    if (member == null) return;

    member
      ..invitationStatus = HouseholdInvitationStatus.declined
      ..connectionStatus = HouseholdConnectionStatus.notConnected;

    notifyListeners();
  }

  void updateMemberAccess({
    required String memberId,
    required HouseholdAppRole role,
  }) {
    final member = memberById(memberId);
    if (member == null) return;

    member
      ..appRole = role
      ..permissions = permissionsForMember(type: member.type, role: role);

    notifyListeners();
  }

  void addHouseholdMember(HouseholdMember member) {
    householdMembers.add(member);
    selectedTenantMemberId = member.id;
    notifyListeners();
  }

  void removeHouseholdMember(String memberId) {
    final member = memberById(memberId);
    if (member == null ||
        member.isVerifiedNamedTenant ||
        member.isCurrentUser) {
      return;
    }

    householdMembers.removeWhere((item) => item.id == memberId);

    if (selectedTenantMemberId == memberId) {
      selectedTenantMemberId = null;
    }

    notifyListeners();
  }

  void resetHouseholdFromTenancy({bool notify = true}) {
    // Keep manually-created non-tenancy members only if the tenancy itself is
    // not being replaced. For a full tenancy reset, callers use resetTenancy().
    householdMembers.clear();
    invites.clear();
    householdMemberSequence = 0;
    resetMemberLookup(notify: false);

    if (notify) notifyListeners();
  }

  void resetTenancyIdentity({bool notify = true}) {
    matchedTenantName = null;
    tenancyIdentityConfirmed = false;
    namedTenantVerified = false;
    homeSetupAdmin = false;
    resetHouseholdFromTenancy(notify: false);

    if (notify) notifyListeners();
  }

  void resetProcessedTenancy({bool notify = true}) {
    tenancyProcessingComplete = false;
    detectedTenantNames.clear();
    resetTenancyIdentity(notify: false);

    if (notify) notifyListeners();
  }

  void resetTenancy({bool notify = true}) {
    tenancyRelationship = null;
    tenancyDocumentName = null;
    tenancyDocumentType = null;
    tenancyDocumentSizeBytes = null;
    tenancySkipped = false;
    tenancySetupComplete = false;
    resetProcessedTenancy(notify: false);

    if (notify) notifyListeners();
  }

  void markTenancySetupComplete() {
    tenancySetupComplete = true;
    notifyListeners();
  }

  String get formattedAddress {
    return [
      addressLine1,
      addressLine2,
      city,
      postcode,
    ].where((value) => value.trim().isNotEmpty).join(', ');
  }
}
