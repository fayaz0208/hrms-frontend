/// Organization model for managing organizations
class Organization {
  final int id;
  final String name;
  final String? description;
  final String contactEmail;
  final String? contactPhone;
  final int? planId;
  final int? userLimit;
  final int? branchLimit;
  final int? storageLimit;
  final bool isActive;
  final String? subscriptionStatus;
  final String? subscriptionStart;
  final String? subscriptionEnd;
  final int? currentUserCount;
  final int? currentBranchCount;
  final int? currentStorageUsed;
  final String? createdAt;

  Organization({
    required this.id,
    required this.name,
    this.description,
    required this.contactEmail,
    this.contactPhone,
    this.planId,
    this.userLimit,
    this.branchLimit,
    this.storageLimit,
    required this.isActive,
    this.subscriptionStatus,
    this.subscriptionStart,
    this.subscriptionEnd,
    this.currentUserCount,
    this.currentBranchCount,
    this.currentStorageUsed,
    this.createdAt,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      contactEmail: json['contact_email'],
      contactPhone: json['contact_phone'],
      planId: json['plan_id'],
      userLimit: json['user_limit'],
      branchLimit: json['branch_limit'],
      storageLimit: json['storage_limit'],
      isActive: json['is_active'] ?? true,
      subscriptionStatus: json['subscription_status'],
      subscriptionStart: json['subscription_start'],
      subscriptionEnd: json['subscription_end'],
      currentUserCount: json['current_user_count'],
      currentBranchCount: json['current_branch_count'],
      currentStorageUsed: json['current_storage_used'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
      'plan_id': planId,
      'user_limit': userLimit,
      'branch_limit': branchLimit,
      'storage_limit': storageLimit,
      'is_active': isActive,
      'subscription_status': subscriptionStatus,
      'subscription_start': subscriptionStart,
      'subscription_end': subscriptionEnd,
      'current_user_count': currentUserCount,
      'current_branch_count': currentBranchCount,
      'current_storage_used': currentStorageUsed,
      'created_at': createdAt,
    };
  }
}
