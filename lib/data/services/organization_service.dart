import '../models/organization_model.dart';
import '../models/branch_model.dart';
import '../models/department_model.dart';
import 'api_service.dart';

/// Service for managing organizations, branches, and departments
class OrganizationService {
  final ApiService _apiService = ApiService();

  // ==================== ORGANIZATIONS ====================

  /// Get all organizations
  Future<List<Organization>> getOrganizations({
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await _apiService.get(
        '/organizations/',
        queryParameters: params,
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Organization.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch organizations: $e');
    }
  }

  /// Get organization by ID
  Future<Organization> getOrganizationById(int id) async {
    try {
      final response = await _apiService.get('/organizations/$id');
      return Organization.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch organization: $e');
    }
  }

  /// Create new organization
  Future<Organization> createOrganization(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/organizations/', data: data);
      return Organization.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create organization: $e');
    }
  }

  /// Update organization
  Future<Organization> updateOrganization(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.put('/organizations/$id', data: data);
      return Organization.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update organization: $e');
    }
  }

  /// Delete organization
  Future<void> deleteOrganization(int id) async {
    try {
      await _apiService.delete('/organizations/$id');
    } catch (e) {
      throw Exception('Failed to delete organization: $e');
    }
  }

  // ==================== BRANCHES ====================

  /// Get all branches
  Future<List<Branch>> getBranches({Map<String, dynamic>? params}) async {
    try {
      final response = await _apiService.get(
        '/branches/',
        queryParameters: params,
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Branch.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch branches: $e');
    }
  }

  /// Get branch by ID
  Future<Branch> getBranchById(int id) async {
    try {
      final response = await _apiService.get('/branches/$id');
      return Branch.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch branch: $e');
    }
  }

  /// Create new branch
  Future<Branch> createBranch(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/branches/', data: data);
      return Branch.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create branch: $e');
    }
  }

  /// Update branch
  Future<Branch> updateBranch(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/branches/$id', data: data);
      return Branch.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update branch: $e');
    }
  }

  /// Delete branch
  Future<void> deleteBranch(int id) async {
    try {
      await _apiService.delete('/branches/$id');
    } catch (e) {
      throw Exception('Failed to delete branch: $e');
    }
  }

  // ==================== DEPARTMENTS ====================

  /// Get all departments
  Future<List<Department>> getDepartments({
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await _apiService.get(
        '/departments/',
        queryParameters: params,
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Department.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch departments: $e');
    }
  }

  /// Get department by ID
  Future<Department> getDepartmentById(int id) async {
    try {
      final response = await _apiService.get('/departments/$id');
      return Department.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch department: $e');
    }
  }

  /// Create new department
  Future<Department> createDepartment(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/departments/', data: data);
      return Department.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create department: $e');
    }
  }

  /// Update department
  Future<Department> updateDepartment(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/departments/$id', data: data);
      return Department.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update department: $e');
    }
  }

  /// Delete department
  Future<void> deleteDepartment(int id) async {
    try {
      await _apiService.delete('/departments/$id');
    } catch (e) {
      throw Exception('Failed to delete department: $e');
    }
  }
}
