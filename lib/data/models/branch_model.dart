/// Branch model with enhanced fields
class Branch {
  final int id;
  final String name;
  final int? organizationId;
  final String? organizationName;
  final String? address;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final String? contactPerson;
  final String? contactPhone;
  final String? contactEmail;
  final bool isActive;
  final String? createdAt;

  Branch({
    required this.id,
    required this.name,
    this.organizationId,
    this.organizationName,
    this.address,
    this.addressLine2,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.contactPerson,
    this.contactPhone,
    this.contactEmail,
    required this.isActive,
    this.createdAt,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'],
      name: json['name'],
      organizationId: json['organization_id'],
      organizationName: json['organization_name'],
      address: json['address'],
      addressLine2: json['address_line2'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postal_code'],
      country: json['country'],
      contactPerson: json['contact_person'],
      contactPhone: json['contact_phone'],
      contactEmail: json['contact_email'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'organization_id': organizationId,
      'organization_name': organizationName,
      'address': address,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'contact_person': contactPerson,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'is_active': isActive,
      'created_at': createdAt,
    };
  }
}
