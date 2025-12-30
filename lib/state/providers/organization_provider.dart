import 'package:flutter/foundation.dart';
import '../../data/models/organization_model.dart';
import '../../data/models/branch_model.dart';
import '../../data/models/department_model.dart';
import '../../data/models/subscription_plan_model.dart';
import '../../data/services/organization_service.dart';
import '../../data/services/subscription_plan_service.dart';

/// Provider for managing organization, branch, and department state
class OrganizationProvider with ChangeNotifier {
  final OrganizationService _organizationService = OrganizationService();
  final SubscriptionPlanService _planService = SubscriptionPlanService();

  // Cache for subscription plans
  Map<int, SubscriptionPlan> _planCache = {};

  // Organizations
  List<Organization> _organizations = [];
  Organization? _selectedOrganization;

  // Branches
  List<Branch> _branches = [];
  Branch? _selectedBranch;

  // Departments
  List<Department> _departments = [];
  Department? _selectedDepartment;

  // Loading states
  bool _isLoading = false;
  bool _isOrganizationsLoading = false;
  bool _isBranchesLoading = false;
  bool _isDepartmentsLoading = false;

  // Error handling
  String? _error;

  // Filters
  String _searchQuery = '';
  int? _filterOrganizationId;
  int? _filterBranchId;

  // Getters
  List<Organization> get organizations => _organizations;
  Organization? get selectedOrganization => _selectedOrganization;

  List<Branch> get branches => _branches;
  Branch? get selectedBranch => _selectedBranch;

  List<Department> get departments => _departments;
  Department? get selectedDepartment => _selectedDepartment;

  bool get isLoading => _isLoading;
  bool get isOrganizationsLoading => _isOrganizationsLoading;
  bool get isBranchesLoading => _isBranchesLoading;
  bool get isDepartmentsLoading => _isDepartmentsLoading;

  String? get error => _error;
  String get searchQuery => _searchQuery;
  int? get filterOrganizationId => _filterOrganizationId;
  int? get filterBranchId => _filterBranchId;

  // Filtered lists
  List<Organization> get filteredOrganizations {
    if (_searchQuery.isEmpty) return _organizations;
    return _organizations.where((org) {
      return org.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (org.contactEmail.toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();
  }

  List<Branch> get filteredBranches {
    var filtered = _branches;

    if (_filterOrganizationId != null) {
      filtered = filtered
          .where((b) => b.organizationId == _filterOrganizationId)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((b) {
        return b.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (b.city?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                false);
      }).toList();
    }

    return filtered;
  }

  List<Department> get filteredDepartments {
    var filtered = _departments;

    if (_filterBranchId != null) {
      filtered = filtered.where((d) => d.branchId == _filterBranchId).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((d) {
        return d.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  // ==================== SEARCH & FILTER ====================

  /// Update search query for organizations
  void searchOrganizations(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ==================== ORGANIZATIONS ====================

  /// Fetch all organizations
  Future<void> fetchOrganizations() async {
    _isOrganizationsLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Always fetch plans to ensure fresh data
      await fetchSubscriptionPlans();

      _organizations = await _organizationService.getOrganizations();
      _isOrganizationsLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isOrganizationsLoading = false;
      notifyListeners();
    }
  }

  /// Fetch organization by ID
  Future<void> fetchOrganizationById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedOrganization = await _organizationService.getOrganizationById(
        id,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create new organization
  Future<bool> createOrganization(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newOrg = await _organizationService.createOrganization(data);
      _organizations.add(newOrg);
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

  /// Update organization
  Future<bool> updateOrganization(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedOrg = await _organizationService.updateOrganization(
        id,
        data,
      );
      final index = _organizations.indexWhere((org) => org.id == id);
      if (index != -1) {
        _organizations[index] = updatedOrg;
      }
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

  /// Delete organization
  Future<bool> deleteOrganization(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _organizationService.deleteOrganization(id);
      _organizations.removeWhere((org) => org.id == id);
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

  // ==================== BRANCHES ====================

  /// Fetch all branches
  Future<void> fetchBranches({int? organizationId}) async {
    _isBranchesLoading = true;
    _error = null;
    notifyListeners();

    try {
      final params = organizationId != null
          ? {'organization_id': organizationId}
          : null;
      _branches = await _organizationService.getBranches(params: params);
      _isBranchesLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isBranchesLoading = false;
      notifyListeners();
    }
  }

  /// Fetch branch by ID
  Future<void> fetchBranchById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedBranch = await _organizationService.getBranchById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create new branch
  Future<bool> createBranch(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newBranch = await _organizationService.createBranch(data);
      _branches.add(newBranch);
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

  /// Update branch
  Future<bool> updateBranch(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedBranch = await _organizationService.updateBranch(id, data);
      final index = _branches.indexWhere((b) => b.id == id);
      if (index != -1) {
        _branches[index] = updatedBranch;
      }
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

  /// Delete branch
  Future<bool> deleteBranch(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _organizationService.deleteBranch(id);
      _branches.removeWhere((b) => b.id == id);
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

  // ==================== DEPARTMENTS ====================

  /// Fetch all departments
  Future<void> fetchDepartments({int? branchId}) async {
    _isDepartmentsLoading = true;
    _error = null;
    notifyListeners();

    try {
      final params = branchId != null ? {'branch_id': branchId} : null;
      _departments = await _organizationService.getDepartments(params: params);
      _isDepartmentsLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isDepartmentsLoading = false;
      notifyListeners();
    }
  }

  /// Fetch department by ID
  Future<void> fetchDepartmentById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedDepartment = await _organizationService.getDepartmentById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create new department
  Future<bool> createDepartment(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newDept = await _organizationService.createDepartment(data);
      _departments.add(newDept);
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

  /// Update department
  Future<bool> updateDepartment(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedDept = await _organizationService.updateDepartment(id, data);
      final index = _departments.indexWhere((d) => d.id == id);
      if (index != -1) {
        _departments[index] = updatedDept;
      }
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

  /// Delete department
  Future<bool> deleteDepartment(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _organizationService.deleteDepartment(id);
      _departments.removeWhere((d) => d.id == id);
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

  // ==================== FILTERS ====================

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Set organization filter
  void setOrganizationFilter(int? orgId) {
    _filterOrganizationId = orgId;
    notifyListeners();
  }

  /// Set branch filter
  void setBranchFilter(int? branchId) {
    _filterBranchId = branchId;
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _filterOrganizationId = null;
    _filterBranchId = null;
    notifyListeners();
  }

  // ==================== SUBSCRIPTION PLANS ====================

  /// Fetch and cache subscription plans
  Future<void> fetchSubscriptionPlans() async {
    try {
      final plans = await _planService.getSubscriptionPlans();
      _planCache = {for (var plan in plans) plan.id: plan};
      notifyListeners();
    } catch (e) {
      // Silently fail - plan names will show as IDs if fetch fails
      debugPrint('Failed to fetch subscription plans: $e');
    }
  }

  /// Get plan name by ID, returns "Plan #X" if not found in cache
  String getPlanName(int? planId) {
    if (planId == null) return '-';
    if (_planCache.containsKey(planId)) {
      return _planCache[planId]!.name;
    }
    return 'Plan #$planId';
  }

  /// Get plan by ID from cache
  SubscriptionPlan? getPlanById(int? planId) {
    if (planId == null) return null;
    return _planCache[planId];
  }
}
