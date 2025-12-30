import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/providers/role_provider.dart';
import '../../../data/models/role_model.dart';
import '../../../data/models/menu_model.dart';
import '../../layouts/main_layout.dart';
import 'role_form_screen.dart';

class RolesListScreen extends StatefulWidget {
  const RolesListScreen({super.key});

  @override
  State<RolesListScreen> createState() => _RolesListScreenState();
}

class _RolesListScreenState extends State<RolesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch roles, menus, and role-rights from backend
      final provider = Provider.of<RoleProvider>(context, listen: false);
      provider.fetchRoles();
      provider.fetchMenus(); // Load menus for Permission Matrix
      provider.fetchRoleRights(); // Load existing permissions
    });
  }

  Future<void> _deleteRole(BuildContext context, Role role) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Role'),
        content: Text(
          'Are you sure you want to delete the role "${role.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final provider = Provider.of<RoleProvider>(context, listen: false);
      final success = await provider.deleteRole(role.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Role "${role.name}" deleted successfully'
                  : 'Failed to delete role',
            ),
            backgroundColor: success ? AppColors.success : AppColors.danger,
          ),
        );
      }
    }
  }

  // Build permissions for a specific category using real backend data
  List<_Permission> _buildPermissionsForCategory(
    String categoryName,
    List<Role> roles,
    RoleProvider provider,
  ) {
    // Try to find menu by name with multiple strategies
    Menu? menu;

    // Strategy 1: Exact display name match
    try {
      menu = provider.menus.firstWhere(
        (m) => m.displayName.toLowerCase() == categoryName.toLowerCase(),
      );
    } catch (e) {
      // Strategy 2: Partial match in display name
      try {
        menu = provider.menus.firstWhere(
          (m) =>
              m.displayName.toLowerCase().contains(categoryName.toLowerCase()),
        );
      } catch (e) {
        // Strategy 3: Partial match in name field
        try {
          menu = provider.menus.firstWhere(
            (m) => m.name.toLowerCase().contains(categoryName.toLowerCase()),
          );
        } catch (e) {
          // Menu not found - will create fallback permissions
          menu = null;
          if (kDebugMode) {
            print('Warning: Menu not found for category "$categoryName"');
            print(
              'Available menus: ${provider.menus.map((m) => m.displayName).join(", ")}',
            );
          }
        }
      }
    }

    final permissions = <_Permission>[];

    // Create permission entries for each action type
    final actionTypes = [
      {'type': 'view', 'label': 'View'},
      {'type': 'create', 'label': 'Create'},
      {'type': 'edit', 'label': 'Edit'},
      {'type': 'delete', 'label': 'Delete'},
    ];

    for (final action in actionTypes) {
      final rolePermissions = <int, bool>{};

      for (final role in roles) {
        bool hasPermission = false;

        if (menu != null) {
          // Get actual permission from backend
          final roleRight = provider.getRoleRight(role.id, menu.id);

          if (roleRight != null) {
            switch (action['type']) {
              case 'view':
                hasPermission = roleRight.canView;
                break;
              case 'create':
                hasPermission = roleRight.canCreate;
                break;
              case 'edit':
                hasPermission = roleRight.canEdit;
                break;
              case 'delete':
                hasPermission = roleRight.canDelete;
                break;
            }
          }
        }
        // If menu not found, hasPermission remains false

        rolePermissions[role.id] = hasPermission;
      }

      permissions.add(
        _Permission(
          name: '${action['label']} $categoryName',
          menuId: menu?.id ?? 0, // Use 0 if menu not found
          permissionType: action['type'] as String,
          rolePermissions: rolePermissions,
        ),
      );
    }

    return permissions;
  }

  // Handler for permission toggle with optimistic updates
  Future<void> _handlePermissionToggle({
    required int roleId,
    required int menuId,
    required String permissionType,
    required bool newValue,
  }) async {
    // Check if menuId is valid
    if (menuId == 0) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Cannot update permission: Menu not found in backend. Please ensure menus are configured.',
            ),
            backgroundColor: AppColors.warning,
            duration: Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    final provider = Provider.of<RoleProvider>(context, listen: false);

    // Store the old value for rollback if needed
    final oldRoleRight = provider.getRoleRight(roleId, menuId);
    bool oldValue = false;
    if (oldRoleRight != null) {
      switch (permissionType) {
        case 'view':
          oldValue = oldRoleRight.canView;
          break;
        case 'create':
          oldValue = oldRoleRight.canCreate;
          break;
        case 'edit':
          oldValue = oldRoleRight.canEdit;
          break;
        case 'delete':
          oldValue = oldRoleRight.canDelete;
          break;
      }
    }

    // Optimistically update the UI immediately
    // This is done by calling updatePermission which will update local state
    // and trigger a rebuild before the API call completes
    try {
      final success = await provider.updatePermission(
        roleId: roleId,
        menuId: menuId,
        permissionType: permissionType,
        value: newValue,
      );

      if (context.mounted) {
        if (success) {
          // Show subtle success feedback
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text('Permission ${newValue ? 'granted' : 'revoked'}'),
                ],
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        } else {
          // Rollback the optimistic update by calling updatePermission again with old value
          await provider.updatePermission(
            roleId: roleId,
            menuId: menuId,
            permissionType: permissionType,
            value: oldValue,
          );

          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Failed to update permission. Please try again.',
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.danger,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Rollback on error
      await provider.updatePermission(
        roleId: roleId,
        menuId: menuId,
        permissionType: permissionType,
        value: oldValue,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('Error: ${e.toString()}')),
              ],
            ),
            backgroundColor: AppColors.danger,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Roles & Permissions',
      child: Consumer<RoleProvider>(
        builder: (context, provider, _) {
          if (provider.isRolesLoading && provider.roles.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Map actual roles from database to display format
          final roleData = provider.roles.map((role) {
            // Assign colors and icons based on role name or use defaults
            Color color;
            IconData icon;

            final roleName = role.name.toLowerCase();
            if (roleName.contains('super') || roleName.contains('admin')) {
              color = const Color(0xFFFF6B6B);
              icon = Icons.shield;
            } else if (roleName.contains('admin')) {
              color = const Color(0xFFFFA500);
              icon = Icons.admin_panel_settings;
            } else if (roleName.contains('manager') ||
                roleName.contains('supervisor')) {
              color = const Color(0xFFFFC107);
              icon = Icons.supervisor_account;
            } else if (roleName.contains('employee') ||
                roleName.contains('staff')) {
              color = const Color(0xFF5B8DEF);
              icon = Icons.person;
            } else {
              // Default color and icon for custom roles
              color = const Color(0xFF9C27B0);
              icon = Icons.badge;
            }

            return {
              'id': role.id,
              'name': role.name,
              'description': role.description ?? 'No description',
              'users': role.userCount ?? 0,
              'color': color,
              'icon': icon,
              'isSystemRole': role.isSystemRole,
              'role': role, // Keep reference to full role object
            };
          }).toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  color: Theme.of(context).colorScheme.surface,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Roles & Permissions',
                              style: TextStyle(
                                fontSize: !kIsWeb && Platform.isAndroid
                                    ? 20
                                    : 28,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage access control and permissions',
                              style: TextStyle(
                                fontSize: !kIsWeb && Platform.isAndroid
                                    ? 11
                                    : 14,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey.shade400
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await showRoleFormDialog(
                            context: context,
                          );
                          if (result == true && context.mounted) {
                            Provider.of<RoleProvider>(
                              context,
                              listen: false,
                            ).fetchRoles();
                          }
                        },
                        icon: Icon(
                          Icons.add,
                          size: !kIsWeb && Platform.isAndroid ? 16 : 20,
                        ),
                        label: Text(
                          'Create Role',
                          style: TextStyle(
                            fontSize: !kIsWeb && Platform.isAndroid ? 11 : 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: !kIsWeb && Platform.isAndroid ? 10 : 24,
                            vertical: !kIsWeb && Platform.isAndroid ? 8 : 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Role Cards - Responsive
                Container(
                  padding: const EdgeInsets.all(24),
                  color: Theme.of(context).colorScheme.surface,
                  child: roleData.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                size: 64,
                                color: AppColors.textMuted.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No roles created yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Click "Create Role" to add your first role',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            // Use wrap for smaller screens
                            if (constraints.maxWidth < 900) {
                              return Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: roleData.map((role) {
                                  return SizedBox(
                                    width: (constraints.maxWidth - 12) / 2,
                                    child: _RoleCard(
                                      roleId: role['id'] as int,
                                      name: role['name'] as String,
                                      description:
                                          role['description'] as String,
                                      userCount: role['users'] as int,
                                      color: role['color'] as Color,
                                      icon: role['icon'] as IconData,
                                      isSystemRole:
                                          role['isSystemRole'] as bool,
                                      onEdit: () async {
                                        final result = await showRoleFormDialog(
                                          context: context,
                                          role: role['role'] as Role,
                                        );
                                        if (result == true && context.mounted) {
                                          provider.fetchRoles();
                                        }
                                      },
                                      onDelete: () => _deleteRole(
                                        context,
                                        role['role'] as Role,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            }
                            // Use row for larger screens
                            return Row(
                              children: roleData.map((role) {
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: _RoleCard(
                                      roleId: role['id'] as int,
                                      name: role['name'] as String,
                                      description:
                                          role['description'] as String,
                                      userCount: role['users'] as int,
                                      color: role['color'] as Color,
                                      icon: role['icon'] as IconData,
                                      isSystemRole:
                                          role['isSystemRole'] as bool,
                                      onEdit: () async {
                                        final result = await showRoleFormDialog(
                                          context: context,
                                          role: role['role'] as Role,
                                        );
                                        if (result == true && context.mounted) {
                                          provider.fetchRoles();
                                        }
                                      },
                                      onDelete: () => _deleteRole(
                                        context,
                                        role['role'] as Role,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                ),

                // Permission Matrix
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Permission Matrix',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFFF1F5F9)
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      provider.roles.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Text(
                                  'No roles available. Create a role to manage permissions.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFF94A3B8)
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                _PermissionSection(
                                  title: 'Users',
                                  icon: Icons.people,
                                  roles: provider.roles,
                                  permissions: _buildPermissionsForCategory(
                                    'Users',
                                    provider.roles,
                                    provider,
                                  ),
                                  onPermissionToggle: _handlePermissionToggle,
                                ),
                                const SizedBox(height: 24),
                                _PermissionSection(
                                  title: 'Courses',
                                  icon: Icons.school,
                                  roles: provider.roles,
                                  permissions: _buildPermissionsForCategory(
                                    'Courses',
                                    provider.roles,
                                    provider,
                                  ),
                                  onPermissionToggle: _handlePermissionToggle,
                                ),
                                const SizedBox(height: 24),
                                _PermissionSection(
                                  title: 'Payroll',
                                  icon: Icons.attach_money,
                                  roles: provider.roles,
                                  permissions: _buildPermissionsForCategory(
                                    'Payroll',
                                    provider.roles,
                                    provider,
                                  ),
                                  onPermissionToggle: _handlePermissionToggle,
                                ),
                                const SizedBox(height: 24),
                                _PermissionSection(
                                  title: 'Attendance',
                                  icon: Icons.event_available,
                                  roles: provider.roles,
                                  permissions: _buildPermissionsForCategory(
                                    'Attendance',
                                    provider.roles,
                                    provider,
                                  ),
                                  onPermissionToggle: _handlePermissionToggle,
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Role Card Widget
class _RoleCard extends StatelessWidget {
  final int roleId;
  final String name;
  final String description;
  final int userCount;
  final Color color;
  final IconData icon;
  final bool isSystemRole;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RoleCard({
    required this.roleId,
    required this.name,
    required this.description,
    required this.userCount,
    required this.color,
    required this.icon,
    required this.isSystemRole,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              !kIsWeb && Platform.isAndroid
                  ? PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 18),
                      padding: EdgeInsets.zero,
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit();
                            break;
                          case 'delete':
                            if (!isSystemRole) onDelete();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          enabled: !isSystemRole,
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete,
                                size: 16,
                                color: isSystemRole
                                    ? AppColors.textMuted
                                    : AppColors.danger,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(
                                  color: isSystemRole
                                      ? AppColors.textMuted
                                      : AppColors.danger,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Edit button
                        IconButton(
                          icon: const Icon(Icons.edit, size: 16),
                          onPressed: onEdit,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          color: AppColors.primary,
                          tooltip: 'Edit role',
                        ),
                        const SizedBox(width: 4),
                        // Delete button (disabled for system roles)
                        IconButton(
                          icon: const Icon(Icons.delete, size: 16),
                          onPressed: isSystemRole ? null : onDelete,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          color: isSystemRole
                              ? AppColors.textMuted
                              : AppColors.danger,
                          tooltip: isSystemRole
                              ? 'System role cannot be deleted'
                              : 'Delete role',
                        ),
                      ],
                    ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade400
                  : AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.people, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '$userCount users',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade500
                        : AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Permission Section Widget
class _PermissionSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_Permission> permissions;
  final List<Role> roles;
  final Function({
    required int roleId,
    required int menuId,
    required String permissionType,
    required bool newValue,
  })
  onPermissionToggle;

  const _PermissionSection({
    required this.title,
    required this.icon,
    required this.permissions,
    required this.roles,
    required this.onPermissionToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (roles.isEmpty) {
      return const SizedBox.shrink();
    }

    // Generate dynamic column widths
    final columnWidths = <int, TableColumnWidth>{
      0: const FixedColumnWidth(200), // Permission name column - fixed width
    };
    for (int i = 0; i < roles.length; i++) {
      columnWidths[i + 1] = const FixedColumnWidth(
        120,
      ); // Role columns - fixed width
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFFF1F5F9)
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Modern card-based permission layout with horizontal scroll
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E293B)
                : const Color(0xFFFAFBFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          child: !kIsWeb && Platform.isAndroid
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row with Role Names
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5B8DEF), Color(0xFF4A7BD8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Permission column header
                            const SizedBox(
                              width: 220,
                              child: Text(
                                'PERMISSION',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Role headers
                            ...roles.map((role) {
                              return SizedBox(
                                width: 140,
                                child: Center(
                                  child: Text(
                                    role.name.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.8,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                      // Permission rows
                      ...permissions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final permission = entry.value;
                        final isEven = index % 2 == 0;

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? (isEven
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFF0F172A))
                                : (isEven
                                      ? Colors.white
                                      : const Color(0xFFF9FAFB)),
                            border: Border(
                              bottom: index == permissions.length - 1
                                  ? BorderSide.none
                                  : BorderSide(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? const Color(0xFF334155)
                                          : const Color(0xFFE5E7EB),
                                      width: 1,
                                    ),
                            ),
                            borderRadius: index == permissions.length - 1
                                ? const BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  )
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Permission name
                              SizedBox(
                                width: 220,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF5B8DEF),
                                            Color(0xFF4A7BD8),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        permission.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? const Color(0xFFE2E8F0)
                                              : const Color(0xFF1F2937),
                                          letterSpacing: 0.1,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Role checkboxes
                              ...roles.map((role) {
                                final hasPermission =
                                    permission.rolePermissions[role.id] ??
                                    false;
                                final isSuperAdmin =
                                    role.name.toLowerCase() == 'super admin' ||
                                    role.name.toLowerCase() == 'super_admin' ||
                                    role.name.toLowerCase() == 'superadmin';

                                return SizedBox(
                                  width: 140,
                                  child: Center(
                                    child: _ModernPermissionToggle(
                                      value: isSuperAdmin
                                          ? true
                                          : hasPermission,
                                      isDisabled: isSuperAdmin,
                                      onChanged: isSuperAdmin
                                          ? null
                                          : (newValue) {
                                              onPermissionToggle(
                                                roleId: role.id,
                                                menuId: permission.menuId,
                                                permissionType:
                                                    permission.permissionType,
                                                newValue: newValue,
                                              );
                                            },
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row with Role Names - Scrollable
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF5B8DEF), Color(0xFF4A7BD8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Permission column header
                            const SizedBox(
                              width: 220,
                              child: Text(
                                'PERMISSION',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Role headers
                            ...roles.map((role) {
                              return SizedBox(
                                width: 140,
                                child: Center(
                                  child: Text(
                                    role.name.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.8,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                    // Permission rows - Independent scrolling for non-Android
                    ...permissions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final permission = entry.value;
                      final isEven = index % 2 == 0;

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? (isEven
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFF0F172A))
                                : (isEven
                                      ? Colors.white
                                      : const Color(0xFFF9FAFB)),
                            border: Border(
                              bottom: index == permissions.length - 1
                                  ? BorderSide.none
                                  : BorderSide(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? const Color(0xFF334155)
                                          : const Color(0xFFE5E7EB),
                                      width: 1,
                                    ),
                            ),
                            borderRadius: index == permissions.length - 1
                                ? const BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  )
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Permission name
                              SizedBox(
                                width: 220,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF5B8DEF),
                                            Color(0xFF4A7BD8),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        permission.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? const Color(0xFFE2E8F0)
                                              : const Color(0xFF1F2937),
                                          letterSpacing: 0.1,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Role checkboxes
                              ...roles.map((role) {
                                final hasPermission =
                                    permission.rolePermissions[role.id] ??
                                    false;
                                final isSuperAdmin =
                                    role.name.toLowerCase() == 'super admin' ||
                                    role.name.toLowerCase() == 'super_admin' ||
                                    role.name.toLowerCase() == 'superadmin';

                                return SizedBox(
                                  width: 140,
                                  child: Center(
                                    child: _ModernPermissionToggle(
                                      value: isSuperAdmin
                                          ? true
                                          : hasPermission,
                                      isDisabled: isSuperAdmin,
                                      onChanged: isSuperAdmin
                                          ? null
                                          : (newValue) {
                                              onPermissionToggle(
                                                roleId: role.id,
                                                menuId: permission.menuId,
                                                permissionType:
                                                    permission.permissionType,
                                                newValue: newValue,
                                              );
                                            },
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
        ),
      ],
    );
  }
}

// Permission Model
class _Permission {
  final String name;
  final int menuId;
  final String permissionType; // 'view', 'create', 'edit', 'delete'
  final Map<int, bool> rolePermissions; // Map of role ID to permission status

  _Permission({
    required this.name,
    required this.menuId,
    required this.permissionType,
    required this.rolePermissions,
  });
}

// Modern Permission Toggle Widget - Stateless for proper state management
class _ModernPermissionToggle extends StatelessWidget {
  final bool value;
  final bool isDisabled;
  final Function(bool)? onChanged;

  const _ModernPermissionToggle({
    required this.value,
    this.isDisabled = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _HoverableToggle(
      value: value,
      isDisabled: isDisabled,
      onChanged: onChanged,
    );
  }
}

// Separate stateful widget for hover effect only
class _HoverableToggle extends StatefulWidget {
  final bool value;
  final bool isDisabled;
  final Function(bool)? onChanged;

  const _HoverableToggle({
    required this.value,
    this.isDisabled = false,
    required this.onChanged,
  });

  @override
  State<_HoverableToggle> createState() => _HoverableToggleState();
}

class _HoverableToggleState extends State<_HoverableToggle> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.isDisabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.isDisabled || widget.onChanged == null
            ? null
            : () => widget.onChanged!(!widget.value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 48,
          height: 28,
          decoration: BoxDecoration(
            gradient: widget.value
                ? const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      const Color(0xFFE5E7EB),
                      _isHovered
                          ? const Color(0xFFD1D5DB)
                          : const Color(0xFFE5E7EB),
                    ],
                  ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.value
                          ? const Color(0xFF10B981).withOpacity(0.3)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                left: widget.value ? 22 : 2,
                top: 2,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: widget.isDisabled
                        ? Colors.grey.shade300
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: widget.value
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: widget.isDisabled
                              ? Colors.grey.shade500
                              : const Color(0xFF10B981),
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
