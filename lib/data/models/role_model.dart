/// Role model for user roles
class Role {
  final int id;
  final String name;
  final String? description;
  final int? userCount;
  final bool isSystemRole;

  Role({
    required this.id,
    required this.name,
    this.description,
    this.userCount,
    this.isSystemRole = false,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      userCount: json['user_count'],
      isSystemRole: json['is_system_role'] ?? _isSystemRole(json['name']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description};
  }

  /// Check if a role name is a system role
  static bool _isSystemRole(String? name) {
    if (name == null) return false;
    final systemRoles = ['Super Admin', 'Admin', 'super_admin', 'admin'];
    return systemRoles.contains(name);
  }

  /// Check if this role can be deleted
  bool get canDelete => !isSystemRole;
}
