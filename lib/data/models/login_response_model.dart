import 'user_model.dart';

/// Login response model matching backend /auth/login response
class LoginResponse {
  final String? accessToken;
  final String? tokenType;
  final User? user;
  final Map<String, dynamic>? organization;
  final List<dynamic>? menus;
  final Map<String, dynamic>? permissions;
  final String? accessLevel;
  final bool? authenticated;

  LoginResponse({
    this.accessToken,
    this.tokenType,
    this.user,
    this.organization,
    this.menus,
    this.permissions,
    this.accessLevel,
    this.authenticated,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      organization: json['organization'],
      menus: json['menus'],
      permissions: json['permissions'],
      accessLevel: json['access_level'],
      authenticated: json['authenticated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'user': user?.toJson(),
      'organization': organization,
      'menus': menus,
      'permissions': permissions,
      'access_level': accessLevel,
      'authenticated': authenticated,
    };
  }
}
