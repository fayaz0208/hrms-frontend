import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../data/models/role_model.dart';
import '../../data/models/menu_model.dart';
import '../../data/models/role_right_model.dart';
import '../../data/services/role_service.dart';
import '../../data/services/storage_service.dart';

/// Provider for managing roles, menus, and permissions state
class RoleProvider with ChangeNotifier {
  final RoleService _roleService = RoleService();
  final StorageService _storageService = StorageService();

  // Cache expiration duration (1 hour)
  static const Duration _cacheExpiration = Duration(hours: 1);

  // ==================== STATE VARIABLES ====================

  // Roles
  List<Role> _roles = [];
  bool _isRolesLoading = false;
  String? _rolesError;

  // Menus
  List<Menu> _menus = [];
  bool _isMenusLoading = false;
  String? _menusError;

  // Role Rights (Permissions)
  List<RoleRight> _roleRights = [];
  bool _isRoleRightsLoading = false;
  String? _roleRightsError;

  // Search/Filter
  String _searchQuery = '';

  // Cache status
  bool _isUsingCachedData = false;

  // ==================== GETTERS ====================

  List<Role> get roles => _roles;
  bool get isRolesLoading => _isRolesLoading;
  String? get rolesError => _rolesError;

  List<Menu> get menus => _menus;
  bool get isMenusLoading => _isMenusLoading;
  String? get menusError => _menusError;

  List<RoleRight> get roleRights => _roleRights;
  bool get isRoleRightsLoading => _isRoleRightsLoading;
  String? get roleRightsError => _roleRightsError;

  String get searchQuery => _searchQuery;
  bool get isUsingCachedData => _isUsingCachedData;

  /// Get filtered roles based on search query
  List<Role> get filteredRoles {
    if (_searchQuery.isEmpty) return _roles;
    return _roles.where((role) {
      return role.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (role.description?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
              false);
    }).toList();
  }

  /// Get parent menus (menus without parent_id)
  List<Menu> get parentMenus {
    return _menus.where((menu) => menu.parentId == null).toList()
      ..sort((a, b) => a.menuOrder.compareTo(b.menuOrder));
  }

  /// Get child menus for a specific parent
  List<Menu> getChildMenus(int parentId) {
    return _menus.where((menu) => menu.parentId == parentId).toList()
      ..sort((a, b) => a.menuOrder.compareTo(b.menuOrder));
  }

  /// Get role right for a specific role and menu
  RoleRight? getRoleRight(int roleId, int menuId) {
    try {
      return _roleRights.firstWhere(
        (rr) => rr.roleId == roleId && rr.menuId == menuId,
      );
    } catch (e) {
      return null;
    }
  }

  // ==================== CACHE METHODS ====================

  /// Check if cache is valid
  Future<bool> _isCacheValid(String key) async {
    try {
      final timestamp = await _storageService.getCacheTimestamp(key);
      if (timestamp == null) return false;

      final now = DateTime.now();
      final difference = now.difference(timestamp);
      final isValid = difference < _cacheExpiration;

      debugPrint(
        '📅 Cache validity for $key: $isValid (age: ${difference.inMinutes}min)',
      );
      return isValid;
    } catch (e) {
      debugPrint('❌ Error checking cache validity: $e');
      return false;
    }
  }

  /// Load roles from cache
  Future<void> _loadRolesFromCache() async {
    try {
      final cachedData = await _storageService.getRolesData();
      if (cachedData != null) {
        final List<dynamic> jsonList = jsonDecode(cachedData);
        _roles = jsonList.map((json) => Role.fromJson(json)).toList();
        debugPrint('✅ Loaded ${_roles.length} roles from cache');
      }
    } catch (e) {
      debugPrint('❌ Error loading roles from cache: $e');
    }
  }

  /// Save roles to cache
  Future<void> _saveRolesToCache() async {
    try {
      final jsonList = _roles.map((role) => role.toJson()).toList();
      await _storageService.saveRolesData(jsonEncode(jsonList));
      await _storageService.saveCacheTimestamp('roles_data', DateTime.now());
      debugPrint('✅ Saved ${_roles.length} roles to cache');
    } catch (e) {
      debugPrint('❌ Error saving roles to cache: $e');
    }
  }

  /// Load menus from cache
  Future<void> _loadMenusFromCache() async {
    try {
      final cachedData = await _storageService.getMenusData();
      if (cachedData != null) {
        final List<dynamic> jsonList = jsonDecode(cachedData);
        _menus = jsonList.map((json) => Menu.fromJson(json)).toList();
        debugPrint('✅ Loaded ${_menus.length} menus from cache');
      }
    } catch (e) {
      debugPrint('❌ Error loading menus from cache: $e');
    }
  }

  /// Save menus to cache
  Future<void> _saveMenusToCache() async {
    try {
      final jsonList = _menus.map((menu) => menu.toJson()).toList();
      await _storageService.saveMenusData(jsonEncode(jsonList));
      await _storageService.saveCacheTimestamp('menus_data', DateTime.now());
      debugPrint('✅ Saved ${_menus.length} menus to cache');
    } catch (e) {
      debugPrint('❌ Error saving menus to cache: $e');
    }
  }

  /// Load role rights from cache
  Future<void> _loadRoleRightsFromCache() async {
    try {
      final cachedData = await _storageService.getRoleRightsData();
      if (cachedData != null) {
        final List<dynamic> jsonList = jsonDecode(cachedData);
        _roleRights = jsonList.map((json) => RoleRight.fromJson(json)).toList();
        debugPrint('✅ Loaded ${_roleRights.length} role rights from cache');
      }
    } catch (e) {
      debugPrint('❌ Error loading role rights from cache: $e');
    }
  }

  /// Save role rights to cache
  Future<void> _saveRoleRightsToCache() async {
    try {
      final jsonList = _roleRights.map((rr) => rr.toJson()).toList();
      await _storageService.saveRoleRightsData(jsonEncode(jsonList));
      await _storageService.saveCacheTimestamp(
        'role_rights_data',
        DateTime.now(),
      );
      debugPrint('✅ Saved ${_roleRights.length} role rights to cache');
    } catch (e) {
      debugPrint('❌ Error saving role rights to cache: $e');
    }
  }

  // ==================== ROLES METHODS ====================

  /// Fetch all roles
  Future<void> fetchRoles() async {
    _isRolesLoading = true;
    _rolesError = null;
    _isUsingCachedData = false;
    notifyListeners();

    try {
      // Try to fetch from API
      _roles = await _roleService.getRoles();
      _rolesError = null;

      // Save to cache on success
      await _saveRolesToCache();
      debugPrint('✅ Fetched ${_roles.length} roles from API');
    } catch (e) {
      debugPrint('❌ Error fetching roles from API: $e');
      _rolesError = e.toString();

      // Try to load from cache as fallback
      final cacheValid = await _isCacheValid('roles_data');
      if (cacheValid || _roles.isEmpty) {
        await _loadRolesFromCache();
        if (_roles.isNotEmpty) {
          _isUsingCachedData = true;
          _rolesError = 'Using cached data (offline)';
          debugPrint('📦 Using cached roles data');
        }
      }
    } finally {
      _isRolesLoading = false;
      notifyListeners();
    }
  }

  /// Create new role
  Future<bool> createRole(Map<String, dynamic> data) async {
    try {
      final newRole = await _roleService.createRole(data);
      _roles.add(newRole);
      await _saveRolesToCache();
      notifyListeners();
      return true;
    } catch (e) {
      _rolesError = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update existing role
  Future<bool> updateRole(int id, Map<String, dynamic> data) async {
    try {
      final updatedRole = await _roleService.updateRole(id, data);
      final index = _roles.indexWhere((r) => r.id == id);
      if (index != -1) {
        _roles[index] = updatedRole;
        await _saveRolesToCache();
        notifyListeners();
      }
      return true;
    } catch (e) {
      _rolesError = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete role
  Future<bool> deleteRole(int id) async {
    try {
      await _roleService.deleteRole(id);
      _roles.removeWhere((r) => r.id == id);
      await _saveRolesToCache();
      notifyListeners();
      return true;
    } catch (e) {
      _rolesError = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Set search query for filtering roles
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ==================== MENUS METHODS ====================

  /// Fetch all menus
  Future<void> fetchMenus() async {
    _isMenusLoading = true;
    _menusError = null;
    notifyListeners();

    try {
      // Try to fetch from API
      _menus = await _roleService.getMenus();
      _menusError = null;

      // Save to cache on success
      await _saveMenusToCache();
      debugPrint('✅ Fetched ${_menus.length} menus from API');
    } catch (e) {
      debugPrint('❌ Error fetching menus from API: $e');
      _menusError = e.toString();

      // Try to load from cache as fallback
      final cacheValid = await _isCacheValid('menus_data');
      if (cacheValid || _menus.isEmpty) {
        await _loadMenusFromCache();
        if (_menus.isNotEmpty) {
          _isUsingCachedData = true;
          _menusError = 'Using cached data (offline)';
          debugPrint('📦 Using cached menus data');
        }
      }
    } finally {
      _isMenusLoading = false;
      notifyListeners();
    }
  }

  // ==================== ROLE RIGHTS METHODS ====================

  /// Fetch all role rights
  Future<void> fetchRoleRights() async {
    _isRoleRightsLoading = true;
    _roleRightsError = null;
    notifyListeners();

    try {
      // Try to fetch from API
      _roleRights = await _roleService.getRoleRights();
      _roleRightsError = null;

      // Save to cache on success
      await _saveRoleRightsToCache();
      debugPrint('✅ Fetched ${_roleRights.length} role rights from API');
    } catch (e) {
      debugPrint('❌ Error fetching role rights from API: $e');
      _roleRightsError = e.toString();

      // Try to load from cache as fallback
      final cacheValid = await _isCacheValid('role_rights_data');
      if (cacheValid || _roleRights.isEmpty) {
        await _loadRoleRightsFromCache();
        if (_roleRights.isNotEmpty) {
          _isUsingCachedData = true;
          _roleRightsError = 'Using cached data (offline)';
          debugPrint('📦 Using cached role rights data');
        }
      }
    } finally {
      _isRoleRightsLoading = false;
      notifyListeners();
    }
  }

  /// Update a single permission
  Future<bool> updatePermission({
    required int roleId,
    required int menuId,
    required String permissionType,
    required bool value,
  }) async {
    try {
      // Find existing role right
      final existingRoleRight = getRoleRight(roleId, menuId);

      if (existingRoleRight != null) {
        // Update existing
        final data = {
          'can_view': permissionType == 'view'
              ? value
              : existingRoleRight.canView,
          'can_create': permissionType == 'create'
              ? value
              : existingRoleRight.canCreate,
          'can_edit': permissionType == 'edit'
              ? value
              : existingRoleRight.canEdit,
          'can_delete': permissionType == 'delete'
              ? value
              : existingRoleRight.canDelete,
        };

        final updated = await _roleService.updateRoleRight(
          existingRoleRight.id,
          data,
        );

        // Update local state
        final index = _roleRights.indexWhere(
          (rr) => rr.id == existingRoleRight.id,
        );
        if (index != -1) {
          _roleRights[index] = updated;
        }
      } else {
        // Create new role right
        final data = {
          'role_id': roleId,
          'menu_id': menuId,
          'can_view': permissionType == 'view' ? value : false,
          'can_create': permissionType == 'create' ? value : false,
          'can_edit': permissionType == 'edit' ? value : false,
          'can_delete': permissionType == 'delete' ? value : false,
        };

        final newRoleRight = await _roleService.createRoleRight(data);
        _roleRights.add(newRoleRight);
      }

      // Save to cache after update
      await _saveRoleRightsToCache();
      notifyListeners();
      return true;
    } catch (e) {
      _roleRightsError = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Bulk update permissions for a role
  Future<bool> bulkUpdatePermissions({
    required int roleId,
    required List<Map<String, dynamic>> rights,
  }) async {
    try {
      await _roleService.bulkUpdateRoleRights(roleId, rights);

      // Reload role rights to get updated data
      await fetchRoleRights();

      return true;
    } catch (e) {
      _roleRightsError = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Load all data needed for permissions matrix
  Future<void> loadPermissionsData() async {
    // Load from cache first for instant display
    await Future.wait([
      _loadRolesFromCache(),
      _loadMenusFromCache(),
      _loadRoleRightsFromCache(),
    ]);

    // Show cached data immediately if available
    if (_roles.isNotEmpty || _menus.isNotEmpty || _roleRights.isNotEmpty) {
      _isUsingCachedData = true;
      notifyListeners();
    }

    // Then fetch fresh data from API
    await Future.wait([fetchRoles(), fetchMenus(), fetchRoleRights()]);
  }

  /// Clear all errors
  void clearErrors() {
    _rolesError = null;
    _menusError = null;
    _roleRightsError = null;
    notifyListeners();
  }

  /// Get any error message
  String? get error => _rolesError ?? _menusError ?? _roleRightsError;
}
