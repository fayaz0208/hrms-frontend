/// Subscription Plan model for managing subscription plans
class SubscriptionPlan {
  final int id;
  final String name;
  final String? description;
  final double priceMonthly;
  final double? priceYearly;

  // Limits
  final int branchLimit;
  final int userLimit;
  final int storageLimitMb;

  // Features
  final bool hasAnalytics;
  final bool hasApiAccess;
  final bool hasPrioritySupport;
  final bool hasWhatsappNotifications;
  final bool hasCustomBranding;

  final bool isActive;
  final int displayOrder;

  SubscriptionPlan({
    required this.id,
    required this.name,
    this.description,
    required this.priceMonthly,
    this.priceYearly,
    required this.branchLimit,
    required this.userLimit,
    required this.storageLimitMb,
    required this.hasAnalytics,
    required this.hasApiAccess,
    required this.hasPrioritySupport,
    required this.hasWhatsappNotifications,
    required this.hasCustomBranding,
    required this.isActive,
    required this.displayOrder,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      priceMonthly: json['price_monthly'] is String
          ? double.parse(json['price_monthly'])
          : (json['price_monthly'] as num).toDouble(),
      priceYearly: json['price_yearly'] != null
          ? (json['price_yearly'] is String
                ? double.parse(json['price_yearly'])
                : (json['price_yearly'] as num).toDouble())
          : null,
      branchLimit: json['branch_limit'],
      userLimit: json['user_limit'],
      storageLimitMb: json['storage_limit_mb'],
      hasAnalytics: json['has_analytics'] ?? false,
      hasApiAccess: json['has_api_access'] ?? false,
      hasPrioritySupport: json['has_priority_support'] ?? false,
      hasWhatsappNotifications: json['has_whatsapp_notifications'] ?? false,
      hasCustomBranding: json['has_custom_branding'] ?? false,
      isActive: json['is_active'] ?? true,
      displayOrder: json['display_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price_monthly': priceMonthly,
      'price_yearly': priceYearly,
      'branch_limit': branchLimit,
      'user_limit': userLimit,
      'storage_limit_mb': storageLimitMb,
      'has_analytics': hasAnalytics,
      'has_api_access': hasApiAccess,
      'has_priority_support': hasPrioritySupport,
      'has_whatsapp_notifications': hasWhatsappNotifications,
      'has_custom_branding': hasCustomBranding,
      'is_active': isActive,
      'display_order': displayOrder,
    };
  }

  /// Get storage limit in GB for display
  double get storageLimitGb => storageLimitMb / 1024.0;
}
