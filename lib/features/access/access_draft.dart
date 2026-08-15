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

  // Members
  final List<String> invites = [];

  String get formattedAddress {
    return [
      addressLine1,
      addressLine2,
      city,
      postcode,
    ].where((value) => value.trim().isNotEmpty).join(', ');
  }
}
