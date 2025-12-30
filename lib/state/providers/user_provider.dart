import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../data/models/role_model.dart';
import '../../data/models/branch_model.dart';
import '../../data/models/department_model.dart';
import '../../data/models/shift_model.dart';
import '../../data/services/user_service.dart';

/// Provider for user management state
class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();

  // State
  List<User> _users = [];
  List<User> _filteredUsers = [];
  List<Role> _roles = [];
  List<Branch> _branches = [];
  List<Department> _departments = [];
  List<Shift> _shifts = [];

  bool _isLoading = false;
  String? _error;

  // Filters
  String _searchQuery = '';
  int? _selectedRoleId;
  int? _selectedBranchId;
  bool? _showInactive;

  // Getters
  List<User> get users => _filteredUsers;
  List<Role> get roles => _roles;
  List<Branch> get branches => _branches;
  List<Department> get departments => _departments;
  List<Shift> get shifts => _shifts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get searchQuery => _searchQuery;
  int? get selectedRoleId => _selectedRoleId;
  int? get selectedBranchId => _selectedBranchId;
  bool? get showInactive => _showInactive;

  /// Fetch all users
  Future<void> fetchUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    print('🟢 UserProvider.fetchUsers() called');

    try {
      print('🟢 Calling _userService.getUsers()...');
      _users = await _userService.getUsers(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        roleId: _selectedRoleId,
        branchId: _selectedBranchId,
        inactive: _showInactive,
      );
      print('✅ fetchUsers success: ${_users.length} users fetched');
      _filteredUsers = List.from(_users);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ fetchUsers error: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch available roles
  Future<void> fetchRoles() async {
    try {
      print('🟢 Fetching roles...');
      _roles = await _userService.getAvailableRoles();
      print('✅ Roles fetched: ${_roles.length} roles');
      notifyListeners();
    } catch (e) {
      print('❌ Error fetching roles: $e');
      debugPrint('Error fetching roles: $e');
    }
  }

  /// Fetch branches
  Future<void> fetchBranches() async {
    try {
      print('🟢 Fetching branches...');
      _branches = await _userService.getBranches();
      print('✅ Branches fetched: ${_branches.length} branches');
      notifyListeners();
    } catch (e) {
      print('❌ Error fetching branches: $e');
      debugPrint('Error fetching branches: $e');
    }
  }

  /// Fetch departments
  Future<void> fetchDepartments() async {
    try {
      _departments = await _userService.getDepartments();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching departments: $e');
    }
  }

  /// Fetch shifts
  Future<void> fetchShifts() async {
    try {
      _shifts = await _userService.getShifts();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching shifts: $e');
    }
  }

  /// Create new user
  Future<bool> createUser(Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _userService.createUser(userData);
      await fetchUsers(); // Refresh list
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update existing user
  Future<bool> updateUser(int id, Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _userService.updateUser(id, userData);
      await fetchUsers(); // Refresh list
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete user
  Future<bool> deleteUser(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _userService.deleteUser(id);
      await fetchUsers(); // Refresh list
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get user by ID
  Future<User?> getUserById(int id) async {
    try {
      return await _userService.getUserById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Search users
  void searchUsers(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  /// Set role filter
  void setRoleFilter(int? roleId) {
    _selectedRoleId = roleId;
    _applyFilters();
  }

  /// Set branch filter
  void setBranchFilter(int? branchId) {
    _selectedBranchId = branchId;
    _applyFilters();
  }

  /// Set inactive filter
  void setInactiveFilter(bool? inactive) {
    _showInactive = inactive;
    _applyFilters();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedRoleId = null;
    _selectedBranchId = null;
    _showInactive = null;
    fetchUsers();
  }

  /// Apply local filters
  void _applyFilters() {
    _filteredUsers = _users.where((user) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = user.fullName.toLowerCase().contains(query);
        final matchesEmail = user.email.toLowerCase().contains(query);
        if (!matchesName && !matchesEmail) return false;
      }

      // Role filter
      if (_selectedRoleId != null && user.roleId != _selectedRoleId) {
        return false;
      }

      // Branch filter
      if (_selectedBranchId != null && user.branchId != _selectedBranchId) {
        return false;
      }

      // Inactive filter
      if (_showInactive != null && user.inactive != _showInactive) {
        return false;
      }

      return true;
    }).toList();

    notifyListeners();
  }

  /// Assign shift to user
  Future<bool> assignShiftToUser(int userId, int shiftId) async {
    try {
      await _userService.assignShiftToUser(userId, shiftId);
      await fetchUsers();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Assign shift to role
  Future<bool> assignShiftToRole(int roleId, int shiftId) async {
    try {
      await _userService.assignShiftToRole(roleId, shiftId);
      await fetchUsers();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Upload profile picture
  Future<String?> uploadProfilePicture(int userId, String filePath) async {
    try {
      return await _userService.uploadProfilePicture(userId, filePath);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _userService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
