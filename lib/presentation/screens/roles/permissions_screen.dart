import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/providers/role_provider.dart';
import '../../../data/models/role_model.dart';
import '../../../data/models/menu_model.dart';

/// Screen 15: Permissions Matrix
/// Complex grid layout showing roles vs menus with CRUD permissions
class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  // Track pending changes: Map<"roleId_menuId_permissionType", bool>
  final Map<String, bool> _pendingChanges = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RoleProvider>(context, listen: false).loadPermissionsData();
    });
  }

  bool _isSuperAdmin(Role role) {
    return role.name.toLowerCase() == 'super admin' ||
        role.name.toLowerCase() == 'super_admin';
  }

  String _getPendingKey(int roleId, int menuId, String permissionType) {
    return '${roleId}_${menuId}_$permissionType';
  }

  bool _getPermissionValue({
    required Role role,
    required Menu menu,
    required String permissionType,
    required RoleProvider provider,
  }) {
    final key = _getPendingKey(role.id, menu.id, permissionType);
    if (_pendingChanges.containsKey(key)) {
      return _pendingChanges[key]!;
    }

    final roleRight = provider.getRoleRight(role.id, menu.id);
    switch (permissionType) {
      case 'view':
        return roleRight?.canView ?? false;
      case 'create':
        return roleRight?.canCreate ?? false;
      case 'edit':
        return roleRight?.canEdit ?? false;
      case 'delete':
        return roleRight?.canDelete ?? false;
      default:
        return false;
    }
  }

  Widget _buildPermissionToggle({
    required Role role,
    required Menu menu,
    required String permissionType,
    required RoleProvider provider,
  }) {
    final isSuperAdmin = _isSuperAdmin(role);
    final value = _getPermissionValue(
      role: role,
      menu: menu,
      permissionType: permissionType,
      provider: provider,
    );
    final key = _getPendingKey(role.id, menu.id, permissionType);
    final hasPendingChange = _pendingChanges.containsKey(key);

    return _PermissionToggle(
      value: isSuperAdmin ? true : value,
      isDisabled: isSuperAdmin,
      hasPendingChange: hasPendingChange,
      onChanged: isSuperAdmin
          ? null
          : (newValue) {
              setState(() {
                _pendingChanges[key] = newValue;
              });
            },
    );
  }

  Widget _buildMenuRow({
    required Menu menu,
    required List<Role> roles,
    required RoleProvider provider,
    bool isChild = false,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            color: isChild ? Colors.grey.shade50 : null,
          ),
          child: Row(
            children: [
              // Menu Name Column
              Container(
                width: 250,
                padding: EdgeInsets.only(
                  left: isChild ? 32 : 16,
                  top: 12,
                  bottom: 12,
                  right: 16,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  children: [
                    if (menu.icon != null) ...[
                      Icon(Icons.circle, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        menu.displayName,
                        style: TextStyle(
                          fontWeight: isChild
                              ? FontWeight.normal
                              : FontWeight.bold,
                          fontSize: isChild ? 13 : 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Permission Checkboxes for each role
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: roles.map((role) {
                      return Container(
                        width: 200,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // View
                            _buildPermissionToggle(
                              role: role,
                              menu: menu,
                              permissionType: 'view',
                              provider: provider,
                            ),
                            // Create
                            _buildPermissionToggle(
                              role: role,
                              menu: menu,
                              permissionType: 'create',
                              provider: provider,
                            ),
                            // Edit
                            _buildPermissionToggle(
                              role: role,
                              menu: menu,
                              permissionType: 'edit',
                              provider: provider,
                            ),
                            // Delete
                            _buildPermissionToggle(
                              role: role,
                              menu: menu,
                              permissionType: 'delete',
                              provider: provider,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _saveAllChanges(RoleProvider provider) async {
    if (_pendingChanges.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No changes to save'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Group changes by role
      final Map<int, Map<int, Map<String, bool>>> changesByRole = {};

      for (final entry in _pendingChanges.entries) {
        final parts = entry.key.split('_');
        final roleId = int.parse(parts[0]);
        final menuId = int.parse(parts[1]);
        final permissionType = parts[2];

        changesByRole.putIfAbsent(roleId, () => {});
        changesByRole[roleId]!.putIfAbsent(menuId, () => {});
        changesByRole[roleId]![menuId]![permissionType] = entry.value;
      }

      // Process each role's changes
      for (final roleEntry in changesByRole.entries) {
        final roleId = roleEntry.key;
        final menuChanges = roleEntry.value;

        final rights = <Map<String, dynamic>>[];

        for (final menuEntry in menuChanges.entries) {
          final menuId = menuEntry.key;
          final permissions = menuEntry.value;

          // Get existing permissions
          final existingRight = provider.getRoleRight(roleId, menuId);

          rights.add({
            'menu_id': menuId,
            'can_view': permissions['view'] ?? existingRight?.canView ?? false,
            'can_create':
                permissions['create'] ?? existingRight?.canCreate ?? false,
            'can_edit': permissions['edit'] ?? existingRight?.canEdit ?? false,
            'can_delete':
                permissions['delete'] ?? existingRight?.canDelete ?? false,
          });
        }

        final success = await provider.bulkUpdatePermissions(
          roleId: roleId,
          rights: rights,
        );

        if (!success) {
          throw Exception('Failed to update permissions for role $roleId');
        }
      }

      setState(() {
        _pendingChanges.clear();
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All permissions saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving permissions: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissions Matrix'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_pendingChanges.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_pendingChanges.length} unsaved',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          Consumer<RoleProvider>(
            builder: (context, provider, _) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: _isSaving || _pendingChanges.isEmpty
                    ? null
                    : () => _saveAllChanges(provider),
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'Saving...' : 'Save All'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<RoleProvider>(
        builder: (context, provider, _) {
          if (provider.isRolesLoading ||
              provider.isMenusLoading ||
              provider.isRoleRightsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.roles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => provider.loadPermissionsData(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final roles = provider.roles;
          final parentMenus = provider.parentMenus;

          if (roles.isEmpty || parentMenus.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No roles or menus found'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => provider.loadPermissionsData(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Cache status banner
              if (provider.isUsingCachedData)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    border: Border(
                      bottom: BorderSide(color: Colors.orange.shade300),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.cloud_off,
                        color: Colors.orange.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Showing cached data (offline mode)',
                          style: TextStyle(
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.refresh,
                          color: Colors.orange.shade700,
                        ),
                        onPressed: () => provider.loadPermissionsData(),
                        tooltip: 'Refresh data',
                      ),
                    ],
                  ),
                ),
              // Header Row
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Menu Column Header
                    Container(
                      width: 250,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Menu',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    // Role Headers
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: roles.map((role) {
                            return Container(
                              width: 200,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    role.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: const [
                                      Text('V', style: TextStyle(fontSize: 11)),
                                      Text('C', style: TextStyle(fontSize: 11)),
                                      Text('E', style: TextStyle(fontSize: 11)),
                                      Text('D', style: TextStyle(fontSize: 11)),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Permissions Grid
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.loadPermissionsData(),
                  child: SingleChildScrollView(
                    child: Column(
                      children: parentMenus.expand((parentMenu) {
                        final childMenus = provider.getChildMenus(
                          parentMenu.id,
                        );
                        return [
                          // Parent Menu Row
                          _buildMenuRow(
                            menu: parentMenu,
                            roles: roles,
                            provider: provider,
                            isChild: false,
                          ),
                          // Child Menu Rows
                          ...childMenus.map((childMenu) {
                            return _buildMenuRow(
                              menu: childMenu,
                              roles: roles,
                              provider: provider,
                              isChild: true,
                            );
                          }),
                        ];
                      }).toList(),
                    ),
                  ),
                ),
              ),

              // Legend
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'V = View  |  C = Create  |  E = Edit  |  D = Delete',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Permission Toggle Widget
class _PermissionToggle extends StatefulWidget {
  final bool value;
  final bool isDisabled;
  final bool hasPendingChange;
  final Function(bool)? onChanged;

  const _PermissionToggle({
    required this.value,
    this.isDisabled = false,
    this.hasPendingChange = false,
    this.onChanged,
  });

  @override
  State<_PermissionToggle> createState() => _PermissionToggleState();
}

class _PermissionToggleState extends State<_PermissionToggle> {
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
        child: Stack(
          children: [
            AnimatedContainer(
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
                          _isHovered && !widget.isDisabled
                              ? const Color(0xFFD1D5DB)
                              : const Color(0xFFE5E7EB),
                        ],
                      ),
                borderRadius: BorderRadius.circular(14),
                border: widget.hasPendingChange
                    ? Border.all(color: Colors.orange, width: 2)
                    : null,
                boxShadow: _isHovered && !widget.isDisabled
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
            if (widget.hasPendingChange)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
