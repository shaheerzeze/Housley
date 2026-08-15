enum HouseholdMemberType { namedTenant, householdMember, guest }

enum HouseholdConnectionStatus {
  notConnected,
  invitePending,
  connected,
  offApp,
}

enum HouseholdInvitationStatus { none, pending, accepted, declined, cancelled }

class HouseholdMemberPermissions {
  const HouseholdMemberPermissions({
    this.canInviteMembers = false,
    this.canRemoveMembers = false,
    this.canManageSharedBills = false,
    this.canViewTenancyDocuments = false,
    this.canManageHomeSettings = false,
  });

  final bool canInviteMembers;
  final bool canRemoveMembers;
  final bool canManageSharedBills;
  final bool canViewTenancyDocuments;
  final bool canManageHomeSettings;

  static const standardNamedTenant = HouseholdMemberPermissions(
    canManageSharedBills: true,
    canViewTenancyDocuments: true,
  );

  static const setupAdmin = HouseholdMemberPermissions(
    canInviteMembers: true,
    canRemoveMembers: true,
    canManageSharedBills: true,
    canViewTenancyDocuments: true,
    canManageHomeSettings: true,
  );

  static const householdMember = HouseholdMemberPermissions(
    canManageSharedBills: true,
  );

  static const guest = HouseholdMemberPermissions();
}

class HouseholdMember {
  HouseholdMember({
    required this.id,
    required this.name,
    required this.type,
    this.phone,
    this.houselyUserId,
    this.isCurrentUser = false,
    this.isVerifiedNamedTenant = false,
    this.connectionStatus = HouseholdConnectionStatus.notConnected,
    this.invitationStatus = HouseholdInvitationStatus.none,
    this.permissions = HouseholdMemberPermissions.standardNamedTenant,
  });

  final String id;

  String name;
  String? phone;

  /// Later this will store the real Supabase auth/profile user id.
  String? houselyUserId;

  HouseholdMemberType type;

  bool isCurrentUser;
  bool isVerifiedNamedTenant;

  HouseholdConnectionStatus connectionStatus;
  HouseholdInvitationStatus invitationStatus;

  HouseholdMemberPermissions permissions;

  bool get isLinkedToHousely => houselyUserId != null;

  bool get isNamedTenant => type == HouseholdMemberType.namedTenant;
}
