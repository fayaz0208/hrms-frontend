import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../../core/config/app_config.dart';

/// Service for managing secure local storage
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Remove encryptedSharedPreferences for Android to fix compatibility issues
  // This prevents crashes on Android 6-8
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: false),
  );

  // Token Management
  Future<void> saveAccessToken(String token) async {
    try {
      await _secureStorage.write(key: AppConfig.accessTokenKey, value: token);
      debugPrint('✅ Access token saved successfully');
    } catch (e) {
      debugPrint('❌ Error saving access token: $e');
      rethrow;
    }
  }

  Future<String?> getAccessToken() async {
    try {
      final token = await _secureStorage.read(key: AppConfig.accessTokenKey);
      debugPrint(
        '🔑 Access token retrieved: ${token != null ? "exists" : "null"}',
      );
      return token;
    } catch (e) {
      debugPrint('❌ Error reading access token: $e');
      return null;
    }
  }

  Future<void> deleteAccessToken() async {
    try {
      await _secureStorage.delete(key: AppConfig.accessTokenKey);
      debugPrint('🗑️ Access token deleted');
    } catch (e) {
      debugPrint('❌ Error deleting access token: $e');
      // Don't rethrow - deletion failure is not critical
    }
  }

  // User Data
  Future<void> saveUserData(String userData) async {
    try {
      await _secureStorage.write(key: AppConfig.userDataKey, value: userData);
      debugPrint('✅ User data saved successfully');
    } catch (e) {
      debugPrint('❌ Error saving user data: $e');
      rethrow;
    }
  }

  Future<String?> getUserData() async {
    try {
      final data = await _secureStorage.read(key: AppConfig.userDataKey);
      debugPrint('👤 User data retrieved: ${data != null ? "exists" : "null"}');
      return data;
    } catch (e) {
      debugPrint('❌ Error reading user data: $e');
      return null;
    }
  }

  // Organization Data
  Future<void> saveOrgData(String orgData) async {
    try {
      await _secureStorage.write(key: AppConfig.orgDataKey, value: orgData);
      debugPrint('✅ Organization data saved successfully');
    } catch (e) {
      debugPrint('❌ Error saving organization data: $e');
      rethrow;
    }
  }

  Future<String?> getOrgData() async {
    try {
      final data = await _secureStorage.read(key: AppConfig.orgDataKey);
      debugPrint(
        '🏢 Organization data retrieved: ${data != null ? "exists" : "null"}',
      );
      return data;
    } catch (e) {
      debugPrint('❌ Error reading organization data: $e');
      return null;
    }
  }

  // Menus Data
  Future<void> saveMenusData(String menusData) async {
    try {
      await _secureStorage.write(key: AppConfig.menusDataKey, value: menusData);
      debugPrint('✅ Menus data saved successfully');
    } catch (e) {
      debugPrint('❌ Error saving menus data: $e');
      rethrow;
    }
  }

  Future<String?> getMenusData() async {
    try {
      final data = await _secureStorage.read(key: AppConfig.menusDataKey);
      debugPrint(
        '📋 Menus data retrieved: ${data != null ? "exists" : "null"}',
      );
      return data;
    } catch (e) {
      debugPrint('❌ Error reading menus data: $e');
      return null;
    }
  }

  // Permissions Data
  Future<void> savePermissionsData(String permissionsData) async {
    try {
      await _secureStorage.write(
        key: AppConfig.permissionsDataKey,
        value: permissionsData,
      );
      debugPrint('✅ Permissions data saved successfully');
    } catch (e) {
      debugPrint('❌ Error saving permissions data: $e');
      rethrow;
    }
  }

  Future<String?> getPermissionsData() async {
    try {
      final data = await _secureStorage.read(key: AppConfig.permissionsDataKey);
      debugPrint(
        '🔐 Permissions data retrieved: ${data != null ? "exists" : "null"}',
      );
      return data;
    } catch (e) {
      debugPrint('❌ Error reading permissions data: $e');
      return null;
    }
  }

  // Roles Data (new)
  Future<void> saveRolesData(String rolesData) async {
    try {
      await _secureStorage.write(key: 'roles_data', value: rolesData);
      debugPrint('✅ Roles data saved successfully');
    } catch (e) {
      debugPrint('❌ Error saving roles data: $e');
      rethrow;
    }
  }

  Future<String?> getRolesData() async {
    try {
      final data = await _secureStorage.read(key: 'roles_data');
      debugPrint(
        '👥 Roles data retrieved: ${data != null ? "exists" : "null"}',
      );
      return data;
    } catch (e) {
      debugPrint('❌ Error reading roles data: $e');
      return null;
    }
  }

  // Role Rights Data (new)
  Future<void> saveRoleRightsData(String roleRightsData) async {
    try {
      await _secureStorage.write(
        key: 'role_rights_data',
        value: roleRightsData,
      );
      debugPrint('✅ Role rights data saved successfully');
    } catch (e) {
      debugPrint('❌ Error saving role rights data: $e');
      rethrow;
    }
  }

  Future<String?> getRoleRightsData() async {
    try {
      final data = await _secureStorage.read(key: 'role_rights_data');
      debugPrint(
        '🔒 Role rights data retrieved: ${data != null ? "exists" : "null"}',
      );
      return data;
    } catch (e) {
      debugPrint('❌ Error reading role rights data: $e');
      return null;
    }
  }

  // Cache timestamp for roles/permissions
  Future<void> saveCacheTimestamp(String key, DateTime timestamp) async {
    try {
      await _secureStorage.write(
        key: '${key}_timestamp',
        value: timestamp.toIso8601String(),
      );
      debugPrint('✅ Cache timestamp saved for $key');
    } catch (e) {
      debugPrint('❌ Error saving cache timestamp: $e');
      // Don't rethrow - timestamp failure is not critical
    }
  }

  Future<DateTime?> getCacheTimestamp(String key) async {
    try {
      final timestamp = await _secureStorage.read(key: '${key}_timestamp');
      if (timestamp != null) {
        return DateTime.parse(timestamp);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error reading cache timestamp: $e');
      return null;
    }
  }

  // Clear All
  Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();
      debugPrint('🗑️ All storage cleared');
    } catch (e) {
      debugPrint('❌ Error clearing storage: $e');
      // Don't rethrow - continue with logout even if clear fails
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final token = await getAccessToken();
      final isLoggedIn = token != null && token.isNotEmpty;
      debugPrint('🔍 Login check: $isLoggedIn');
      return isLoggedIn;
    } catch (e) {
      debugPrint('❌ Error checking login status: $e');
      return false;
    }
  }
}
