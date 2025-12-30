import '../models/subscription_plan_model.dart';
import 'api_service.dart';

/// Service for managing subscription plans
class SubscriptionPlanService {
  final ApiService _apiService = ApiService();

  /// Get all active subscription plans
  Future<List<SubscriptionPlan>> getSubscriptionPlans({
    bool includeInactive = false,
  }) async {
    try {
      final response = await _apiService.get(
        '/subscription-plans/',
        queryParameters: includeInactive ? {'include_inactive': true} : null,
      );
      final List<dynamic> data = response.data;
      return data.map((json) => SubscriptionPlan.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch subscription plans: $e');
    }
  }

  /// Get subscription plan by ID
  Future<SubscriptionPlan> getSubscriptionPlanById(int id) async {
    try {
      final response = await _apiService.get('/subscription-plans/$id');
      return SubscriptionPlan.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch subscription plan: $e');
    }
  }
}
