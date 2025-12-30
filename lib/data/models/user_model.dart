/// User model matching backend User schema
class User {
  final int id;
  final String firstName;
  final String? lastName;
  final String fullName;
  final String email;
  final int? roleId;
  final String? roleName;
  final int? organizationId;
  final String? organizationName;
  final bool isOrgAdmin;
  final int? branchId;
  final String? branchName;
  final int? departmentId;
  final String? departmentName;
  final String? designation;
  final String? joiningDate;
  final bool inactive;
  final String? biometricId;

  User({
    required this.id,
    required this.firstName,
    this.lastName,
    required this.fullName,
    required this.email,
    this.roleId,
    this.roleName,
    this.organizationId,
    this.organizationName,
    required this.isOrgAdmin,
    this.branchId,
    this.branchName,
    this.departmentId,
    this.departmentName,
    this.designation,
    this.joiningDate,
    required this.inactive,
    this.biometricId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      fullName: json['full_name'] ?? '${json['first_name']} ${json['last_name'] ?? ''}'.trim(),
      email: json['email'],
      roleId: json['role_id'],
      roleName: json['role_name'],
      organizationId: json['organization_id'],
      organizationName: json['organization_name'],
      isOrgAdmin: json['is_org_admin'] ?? false,
      branchId: json['branch_id'],
      branchName: json['branch_name'],
      departmentId: json['department_id'],
      departmentName: json['department_name'],
      designation: json['designation'],
      joiningDate: json['joining_date'],
      inactive: json['inactive'] ?? false,
      biometricId: json['biometric_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'email': email,
      'role_id': roleId,
      'role_name': roleName,
      'organization_id': organizationId,
      'organization_name': organizationName,
      'is_org_admin': isOrgAdmin,
      'branch_id': branchId,
      'branch_name': branchName,
      'department_id': departmentId,
      'department_name': departmentName,
      'designation': designation,
      'joining_date': joiningDate,
      'inactive': inactive,
      'biometric_id': biometricId,
    };
  }
}
