enum HouseholdMemberType { namedTenant, householdMember, guest }

enum HouseholdConnectionStatus {
  notConnected,
  invitePending,
  connected,
  offApp,
}

enum HouseholdAppRole { setupAdmin, standard, guest }

enum HouseholdInvitationStatus { none, pending, accepted, declined, cancelled }

class HouseholdMemberPermissions {
  const HouseholdMemberPermissions({
    this.canInviteMembers = false,
    this.canRemoveMembers = false,
    this.canManageSharedBills = false,
    this.canViewTenancyDocuments = false,
    this.canManageHomeSettings = false,
    this.canManageMemberPermissions = false,
  });

  final bool canInviteMembers;
  final bool canRemoveMembers;
  final bool canManageSharedBills;
  final bool canViewTenancyDocuments;
  final bool canManageHomeSettings;
  final bool canManageMemberPermissions;
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
    canManageMemberPermissions: true,
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
    this.appRole = HouseholdAppRole.standard,
  });

  final String id;

  String name;
  String? phone;

  /// Later this will store the real Supabase auth/profile user id.
  String? houselyUserId;

  HouseholdMemberType type;
  HouseholdAppRole appRole;

  bool isCurrentUser;
  bool isVerifiedNamedTenant;

  HouseholdConnectionStatus connectionStatus;
  HouseholdInvitationStatus invitationStatus;

  HouseholdMemberPermissions permissions;

  bool get isLinkedToHousely => houselyUserId != null;

  bool get isNamedTenant => type == HouseholdMemberType.namedTenant;
  bool get isOffApp => connectionStatus == HouseholdConnectionStatus.offApp;

  bool get hasPendingInvite =>
      invitationStatus == HouseholdInvitationStatus.pending;
}

HouseholdMemberPermissions permissionsForMember({
  required HouseholdMemberType type,
  required HouseholdAppRole role,
}) {
  if (role == HouseholdAppRole.setupAdmin) {
    return HouseholdMemberPermissions.setupAdmin;
  }

  if (role == HouseholdAppRole.guest) {
    return HouseholdMemberPermissions.guest;
  }

  return switch (type) {
    HouseholdMemberType.namedTenant =>
      HouseholdMemberPermissions.standardNamedTenant,

    HouseholdMemberType.householdMember =>
      HouseholdMemberPermissions.householdMember,

    HouseholdMemberType.guest => HouseholdMemberPermissions.guest,
  };
}
