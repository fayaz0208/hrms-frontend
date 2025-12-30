import '../models/role_model.dart';
import '../models/menu_model.dart';
import '../models/role_right_model.dart';
import 'api_service.dart';

/// Service for managing roles, menus, and role rights (permissions)
class RoleService {
  final ApiService _apiService = ApiService();

  // ==================== ROLES ====================

  /// Get all roles
  Future<List<Role>> getRoles({Map<String, dynamic>? params}) async {
    try {
      final response = await _apiService.get(
        '/roles/',
        queryParameters: params,
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Role.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch roles: $e');
    }
  }

  /// Get role by ID
  Future<Role> getRoleById(int id) async {
    try {
      final response = await _apiService.get('/roles/$id');
      return Role.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch role: $e');
    }
  }

  /// Create new role
  Future<Role> createRole(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/roles/', data: data);
      return Role.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create role: $e');
    }
  }

  /// Update role
  Future<Role> updateRole(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/roles/$id', data: data);
      return Role.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update role: $e');
    }
  }

  /// Delete role
  Future<void> deleteRole(int id) async {
    try {
      await _apiService.delete('/roles/$id');
    } catch (e) {
      throw Exception('Failed to delete role: $e');
    }
  }

  // ==================== MENUS ====================

  /// Get all menus
  Future<List<Menu>> getMenus({Map<String, dynamic>? params}) async {
    try {
      final response = await _apiService.get(
        '/menus/',
        queryParameters: params,
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Menu.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch menus: $e');
    }
  }

  /// Get menu by ID
  Future<Menu> getMenuById(int id) async {
    try {
      final response = await _apiService.get('/menus/$id');
      return Menu.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch menu: $e');
    }
  }

  /// Create new menu
  Future<Menu> createMenu(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/menus/', data: data);
      return Menu.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create menu: $e');
    }
  }

  /// Update menu
  Future<Menu> updateMenu(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/menus/$id', data: data);
      return Menu.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update menu: $e');
    }
  }

  /// Delete menu
  Future<void> deleteMenu(int id) async {
    try {
      await _apiService.delete('/menus/$id');
    } catch (e) {
      throw Exception('Failed to delete menu: $e');
    }
  }

  // ==================== ROLE RIGHTS ====================

  /// Get all role rights (permissions)
  Future<List<RoleRight>> getRoleRights({Map<String, dynamic>? params}) async {
    try {
      final response = await _apiService.get(
        '/role-rights/',
        queryParameters: params,
      );
      final List<dynamic> data = response.data;
      return data.map((json) => RoleRight.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch role rights: $e');
    }
  }

  /// Get role right by ID
  Future<RoleRight> getRoleRightById(int id) async {
    try {
      final response = await _apiService.get('/role-rights/$id');
      return RoleRight.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch role right: $e');
    }
  }

  /// Create new role right
  Future<RoleRight> createRoleRight(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/role-rights/', data: data);
      return RoleRight.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create role right: $e');
    }
  }

  /// Update role right
  Future<RoleRight> updateRoleRight(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/role-rights/$id', data: data);
      return RoleRight.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update role right: $e');
    }
  }

  /// Delete role right
  Future<void> deleteRoleRight(int id) async {
    try {
      await _apiService.delete('/role-rights/$id');
    } catch (e) {
      throw Exception('Failed to delete role right: $e');
    }
  }

  /// Bulk update role rights for a specific role
  /// This is useful for the permissions matrix screen
  Future<void> bulkUpdateRoleRights(
    int roleId,
    List<Map<String, dynamic>> rights,
  ) async {
    try {
      await _apiService.post(
        '/role-rights/bulk',
        data: {'role_id': roleId, 'rights': rights},
      );
    } catch (e) {
      throw Exception('Failed to bulk update role rights: $e');
    }
  }

  /// Get role rights by role ID
  Future<List<RoleRight>> getRoleRightsByRoleId(int roleId) async {
    try {
      final response = await _apiService.get(
        '/role-rights/',
        queryParameters: {'role_id': roleId},
      );
      final List<dynamic> data = response.data;
      return data.map((json) => RoleRight.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch role rights for role: $e');
    }
  }

  /// Get role rights by menu ID
  Future<List<RoleRight>> getRoleRightsByMenuId(int menuId) async {
    try {
      final response = await _apiService.get(
        '/role-rights/',
        queryParameters: {'menu_id': menuId},
      );
      final List<dynamic> data = response.data;
      return data.map((json) => RoleRight.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch role rights for menu: $e');
    }
  }

  /// Get permissions matrix (all roles, menus, and role rights in one call)
  Future<Map<String, dynamic>> getPermissionsMatrix() async {
    try {
      final response = await _apiService.get('/role-rights/permissions-matrix');
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch permissions matrix: $e');
    }
  }
}
