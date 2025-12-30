/// RoleRight model for role-based permissions
class RoleRight {
  final int id;
  final int roleId;
  final int menuId;
  final bool canView;
  final bool canCreate;
  final bool canEdit;
  final bool canDelete;

  RoleRight({
    required this.id,
    required this.roleId,
    required this.menuId,
    this.canView = false,
    this.canCreate = false,
    this.canEdit = false,
    this.canDelete = false,
  });

  factory RoleRight.fromJson(Map<String, dynamic> json) {
    return RoleRight(
      id: json['id'],
      roleId: json['role_id'],
      menuId: json['menu_id'],
      canView: json['can_view'] ?? false,
      canCreate: json['can_create'] ?? false,
      canEdit: json['can_edit'] ?? false,
      canDelete: json['can_delete'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role_id': roleId,
      'menu_id': menuId,
      'can_view': canView,
      'can_create': canCreate,
      'can_edit': canEdit,
      'can_delete': canDelete,
    };
  }

  /// Create a copy with updated permissions
  RoleRight copyWith({
    int? id,
    int? roleId,
    int? menuId,
    bool? canView,
    bool? canCreate,
    bool? canEdit,
    bool? canDelete,
  }) {
    return RoleRight(
      id: id ?? this.id,
      roleId: roleId ?? this.roleId,
      menuId: menuId ?? this.menuId,
      canView: canView ?? this.canView,
      canCreate: canCreate ?? this.canCreate,
      canEdit: canEdit ?? this.canEdit,
      canDelete: canDelete ?? this.canDelete,
    );
  }

  /// Check if this role has any permissions
  bool get hasAnyPermission => canView || canCreate || canEdit || canDelete;

  /// Check if this role has all permissions
  bool get hasAllPermissions => canView && canCreate && canEdit && canDelete;
}
