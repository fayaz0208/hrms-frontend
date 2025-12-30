/// Menu model for navigation menus
class Menu {
  final int id;
  final String name;
  final String displayName;
  final String? route;
  final String? icon;
  final int? parentId;
  final int menuOrder;
  final bool isActive;

  Menu({
    required this.id,
    required this.name,
    required this.displayName,
    this.route,
    this.icon,
    this.parentId,
    this.menuOrder = 0,
    this.isActive = true,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'],
      name: json['name'],
      displayName: json['display_name'],
      route: json['route'],
      icon: json['icon'],
      parentId: json['parent_id'],
      menuOrder: json['menu_order'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'route': route,
      'icon': icon,
      'parent_id': parentId,
      'menu_order': menuOrder,
      'is_active': isActive,
    };
  }

  /// Check if this menu is a parent menu (has no route)
  bool get isParent => route == null;

  /// Check if this menu is a child menu
  bool get isChild => parentId != null;
}
