enum TenancyRelationship { namedOnTenancy, notNamedOnTenancy, unsure }

class AccessDraft {
  // Account
  String name = '';
  String email = '';
  String password = '';
  // Sign in / password recovery
String signInEmail = '';
String resetEmail = '';

  // Home
  String homeName = '';
  String addressLine1 = '';
  String addressLine2 = '';
  String city = '';
  String postcode = '';
  String country = 'United Kingdom';

  // Tenancy
  TenancyRelationship? tenancyRelationship;

  // Later phases
  String? tenancyDocumentName;
  bool tenancySkipped = false;

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
