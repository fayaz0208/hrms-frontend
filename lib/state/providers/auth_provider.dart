import 'package:flutter/foundation.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/user_model.dart';
import '../../data/models/login_response_model.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

/// Provider for managing authentication state
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthState _state = AuthState.initial;
  User? _user;
  Map<String, dynamic>? _organization;
  List<dynamic>? _menus;
  Map<String, dynamic>? _permissions;
  String? _accessLevel;
  String? _errorMessage;

  // Getters
  AuthState get state => _state;
  User? get user => _user;
  Map<String, dynamic>? get organization => _organization;
  List<dynamic>? get menus => _menus;
  Map<String, dynamic>? get permissions => _permissions;
  String? get accessLevel => _accessLevel;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get hasFullAccess => _accessLevel == 'full';

  /// Check if user has permission for a menu
  bool hasPermission(int menuId, String action) {
    if (hasFullAccess) return true;
    if (_permissions == null) return false;
    
    final menuPermissions = _permissions![menuId.toString()];
    if (menuPermissions == null) return false;
    
    switch (action.toLowerCase()) {
      case 'view':
        return menuPermissions['can_view'] == true;
      case 'create':
        return menuPermissions['can_create'] == true;
      case 'edit':
        return menuPermissions['can_edit'] == true;
      case 'delete':
        return menuPermissions['can_delete'] == true;
      default:
        return false;
    }
  }

  /// Initialize - check if user is already logged in
  Future<void> initialize() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        _state = AuthState.loading;
        notifyListeners();
        
        final response = await _authService.getCurrentUser();
        _setAuthData(response);
        _state = AuthState.authenticated;
      } else {
        _state = AuthState.unauthenticated;
      }
    } catch (e) {
      _state = AuthState.unauthenticated;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  /// Login
  Future<bool> login(String email, String password) async {
    try {
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      final response = await _authService.login(
        email: email,
        password: password,
      );

      _setAuthData(response);
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Register
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? organizationName,
    String? contactPhone,
  }) async {
    try {
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      final response = await _authService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        organizationName: organizationName,
        contactPhone: contactPhone,
      );

      _setAuthData(response);
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _authService.logout();
    } finally {
      _clearAuthData();
      _state = AuthState.unauthenticated;
      notifyListeners();
    }
  }

  /// Set authentication data
  void _setAuthData(LoginResponse response) {
    print('📊 Setting auth data:');
    print('   - User: ${response.user}');
    print('   - AccessToken: ${response.accessToken?.substring(0, 20)}...');
    print('   - Organization: ${response.organization}');
    print('   - Menus: ${response.menus?.length ?? 0} items');
    print('   - Permissions: ${response.permissions?.keys.length ?? 0} items');
    print('   - AccessLevel: ${response.accessLevel}');
    
    _user = response.user;
    _organization = response.organization;
    _menus = response.menus;
    _permissions = response.permissions;
    _accessLevel = response.accessLevel;
  }

  /// Clear authentication data
  void _clearAuthData() {
    _user = null;
    _organization = null;
    _menus = null;
    _permissions = null;
    _accessLevel = null;
    _errorMessage = null;
  }
}
