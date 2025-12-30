import 'dart:convert';
import 'package:dio/dio.dart';
import 'api_service.dart';
import 'storage_service.dart';
import '../models/login_response_model.dart';

/// Authentication service for handling login, register, and auth state
class AuthService {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  /// Register new user with organization
  Future<LoginResponse> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? organizationName,
    String? contactPhone,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/register',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'password': password,
          'organization_name': organizationName,
          'contact_phone': contactPhone,
        },
      );

      final loginResponse = LoginResponse.fromJson(response.data);
      
      // Save auth data
      await _saveAuthData(loginResponse);
      
      return loginResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Login user
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        data: FormData.fromMap({
          'username': email, // Backend expects 'username' field
          'password': password,
          'grant_type': 'password',
        }),
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
        ),
      );

      final loginResponse = LoginResponse.fromJson(response.data);
      
      // Save auth data
      await _saveAuthData(loginResponse);
      
      return loginResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get current user info
  Future<LoginResponse> getCurrentUser() async {
    try {
      final response = await _apiService.get('/auth/me');
      final loginResponse = LoginResponse.fromJson(response.data);
      
      // Update saved auth data
      await _saveAuthData(loginResponse);
      
      return loginResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Refresh access token
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final response = await _apiService.post('/auth/refresh');
      
      if (response.data['access_token'] != null) {
        await _storageService.saveAccessToken(response.data['access_token']);
      }
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _apiService.post('/auth/logout');
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      await _storageService.clearAll();
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _storageService.isLoggedIn();
  }

  /// Save authentication data to storage
  Future<void> _saveAuthData(LoginResponse loginResponse) async {
    if (loginResponse.accessToken != null) {
      await _storageService.saveAccessToken(loginResponse.accessToken!);
    }
    
    if (loginResponse.user != null) {
      await _storageService
          .saveUserData(jsonEncode(loginResponse.user!.toJson()));
    }
    
    if (loginResponse.organization != null) {
      await _storageService
          .saveOrgData(jsonEncode(loginResponse.organization));
    }
    
    if (loginResponse.menus != null) {
      await _storageService.saveMenusData(jsonEncode(loginResponse.menus));
    }
    
    if (loginResponse.permissions != null) {
      await _storageService
          .savePermissionsData(jsonEncode(loginResponse.permissions));
    }
  }

  /// Handle Dio errors
  String _handleError(DioException error) {
    if (error.response?.data != null) {
      if (error.response?.data is Map) {
        return error.response?.data['detail'] ?? 
               error.response?.data['message'] ?? 
               'An error occurred';
      }
    }
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        return 'Server error. Please try again later.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      default:
        return 'Network error. Please check your connection.';
    }
  }
}
