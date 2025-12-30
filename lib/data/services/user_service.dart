import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../models/role_model.dart';
import '../models/branch_model.dart';
import '../models/department_model.dart';
import '../models/shift_model.dart';
import 'api_service.dart';

/// Service for user-related API calls
class UserService {
  final ApiService _apiService = ApiService();

  /// Get all users with optional filters
  Future<List<User>> getUsers({
    String? search,
    int? roleId,
    int? branchId,
    bool? inactive,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null) queryParams['search'] = search;
      if (roleId != null) queryParams['role_id'] = roleId;
      if (branchId != null) queryParams['branch_id'] = branchId;
      if (inactive != null) queryParams['inactive'] = inactive;

      final response = await _apiService.get(
        '/users/',
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data;
      return data.map((json) => User.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get user by ID
  Future<User> getUserById(int id) async {
    try {
      final response = await _apiService.get('/users/$id');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create new user
  Future<User> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _apiService.post('/users/', data: userData);
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update existing user
  Future<User> updateUser(int id, Map<String, dynamic> userData) async {
    try {
      final response = await _apiService.put('/users/$id', data: userData);
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete user
  Future<void> deleteUser(int id) async {
    try {
      await _apiService.delete('/users/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get available roles
  Future<List<Role>> getAvailableRoles() async {
    try {
      final response = await _apiService.get('/users/available-roles');
      final List<dynamic> data = response.data;
      return data.map((json) => Role.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get branches
  Future<List<Branch>> getBranches() async {
    try {
      final response = await _apiService.get('/branches/');
      final List<dynamic> data = response.data;
      return data.map((json) => Branch.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get departments
  Future<List<Department>> getDepartments() async {
    try {
      final response = await _apiService.get('/departments/');
      final List<dynamic> data = response.data;
      return data.map((json) => Department.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get shifts
  Future<List<Shift>> getShifts() async {
    try {
      final response = await _apiService.get('/shifts/');
      final List<dynamic> data = response.data;
      return data.map((json) => Shift.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Assign shift to user
  Future<void> assignShiftToUser(int userId, int shiftId) async {
    try {
      await _apiService.post(
        '/users/$userId/assign-shift',
        data: {'shift_id': shiftId},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Assign shift to all users in a role
  Future<void> assignShiftToRole(int roleId, int shiftId) async {
    try {
      await _apiService.post(
        '/users/assign-shift-by-role',
        data: {'role_id': roleId, 'shift_id': shiftId},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload profile picture
  Future<String> uploadProfilePicture(int userId, String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await _apiService.uploadFile(
        '/users/$userId/upload-photo',
        formData,
      );

      return response.data['photo_url'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _apiService.post(
        '/users/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle DioException and return user-friendly error message
  String _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      switch (statusCode) {
        case 400:
          return data['detail'] ?? 'Invalid request';
        case 401:
          return 'Unauthorized. Please login again.';
        case 403:
          return 'You do not have permission to perform this action.';
        case 404:
          return 'User not found.';
        case 422:
          // Validation error
          if (data is Map && data.containsKey('detail')) {
            return data['detail'].toString();
          }
          return 'Validation error';
        default:
          return 'Server error. Please try again later.';
      }
    } else {
      return 'Network error. Please check your connection.';
    }
  }
}
