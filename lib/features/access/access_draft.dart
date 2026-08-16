import 'household_member.dart';

enum TenancyRelationship { namedOnTenancy, notNamedOnTenancy, unsure }

class AccessDraft {
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

  /// Tenancy member currently being connected.
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
      if (member.id == id) {
        return member;
      }
    }

    return null;
  }

  HouseholdMember? get selectedTenantMember {
    final id = selectedTenantMemberId;

    if (id == null) return null;

    for (final member in householdMembers) {
      if (member.id == id) {
        return member;
      }
    }

    return null;
  }

  void initialiseHouseholdMembersFromTenancy() {
    if (detectedTenantNames.isEmpty) return;

    for (var index = 0; index < detectedTenantNames.length; index++) {
      final tenantName = detectedTenantNames[index];

      final alreadyExists = householdMembers.any(
        (member) => member.name.toLowerCase() == tenantName.toLowerCase(),
      );

      if (alreadyExists) continue;

      final isYou = tenantName == matchedTenantName;

      householdMembers.add(
        HouseholdMember(
          id: 'tenancy-member-$index',
          name: tenantName,
          type: HouseholdMemberType.namedTenant,
          appRole: isYou && homeSetupAdmin
              ? HouseholdAppRole.setupAdmin
              : HouseholdAppRole.standard,
          isCurrentUser: isYou,
          isVerifiedNamedTenant: isYou && namedTenantVerified,
          connectionStatus: isYou
              ? HouseholdConnectionStatus.connected
              : HouseholdConnectionStatus.notConnected,
          invitationStatus: HouseholdInvitationStatus.none,
          houselyUserId: isYou ? 'current-user' : null,
          phone: isYou ? phone : null,
          permissions: isYou && homeSetupAdmin
              ? HouseholdMemberPermissions.setupAdmin
              : HouseholdMemberPermissions.standardNamedTenant,
        ),
      );
    }
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
