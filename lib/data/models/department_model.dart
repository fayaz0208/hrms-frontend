/// Department model with enhanced fields
class Department {
  final int id;
  final String name;
  final String? code;
  final int? branchId;
  final String? branchName;
  final int? managerId;
  final String? managerName;
  final String? description;
  final int? employeeCount;
  final String? createdAt;

  Department({
    required this.id,
    required this.name,
    this.code,
    this.branchId,
    this.branchName,
    this.managerId,
    this.managerName,
    this.description,
    this.employeeCount,
    this.createdAt,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      branchId: json['branch_id'],
      branchName: json['branch_name'],
      managerId: json['manager_id'],
      managerName: json['manager_name'],
      description: json['description'],
      employeeCount: json['employee_count'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'branch_id': branchId,
      'branch_name': branchName,
      'manager_id': managerId,
      'manager_name': managerName,
      'description': description,
      'employee_count': employeeCount,
      'created_at': createdAt,
    };
  }
}
