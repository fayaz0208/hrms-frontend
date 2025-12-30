import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/providers/organization_provider.dart';
import '../../../data/models/organization_model.dart';
import '../../layouts/main_layout.dart';

class OrganizationDetailScreen extends StatefulWidget {
  final int organizationId;

  const OrganizationDetailScreen({super.key, required this.organizationId});

  @override
  State<OrganizationDetailScreen> createState() =>
      _OrganizationDetailScreenState();
}

class _OrganizationDetailScreenState extends State<OrganizationDetailScreen> {
  Organization? _organization;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrganization();
  }

  Future<void> _loadOrganization() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<OrganizationProvider>(context, listen: false);
    await provider.fetchOrganizations();

    if (mounted) {
      setState(() {
        try {
          _organization = provider.organizations.firstWhere(
            (org) => org.id == widget.organizationId,
          );
        } catch (e) {
          _organization = null;
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Organization Details',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _organization == null
          ? const Center(child: Text('Organization not found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Organization Header Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E293B)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.business,
                            size: 32,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _organization!.name,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFFF1F5F9)
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Basic',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade900,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          _organization!.subscriptionStatus ==
                                              'trial'
                                          ? Colors.orange.shade100
                                          : Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _organization!.subscriptionStatus ??
                                          'trial',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            _organization!.subscriptionStatus ==
                                                'trial'
                                            ? Colors.orange.shade900
                                            : Colors.green.shade900,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Three Column Layout -> Mobile Stacked Layout
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Basic Information
                      _InfoCard(
                        title: 'Basic Information',
                        icon: Icons.info_outline,
                        children: [
                          _InfoRow(
                            icon: Icons.business,
                            label: 'Name',
                            value: _organization!.name,
                          ),
                          _InfoRow(
                            icon: Icons.description,
                            label: 'Description',
                            value: _organization!.description ?? '-',
                          ),
                          _InfoRow(
                            icon: Icons.email,
                            label: 'Contact Email',
                            value: _organization!.contactEmail ?? '-',
                          ),
                          _InfoRow(
                            icon: Icons.phone,
                            label: 'Contact Phone',
                            value: _organization!.contactPhone ?? '-',
                          ),
                          _InfoRow(
                            icon: Icons.calendar_today,
                            label: 'Created',
                            value: _organization!.subscriptionStart != null
                                ? _formatDate(_organization!.subscriptionStart!)
                                : '-',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Subscription
                      _InfoCard(
                        title: 'Subscription',
                        icon: Icons.card_membership,
                        children: [
                          _InfoRow(
                            icon: Icons.workspace_premium,
                            label: 'Plan',
                            value: 'Basic',
                          ),
                          _InfoRow(
                            icon: Icons.check_circle,
                            label: 'Status',
                            value: _organization!.subscriptionStatus ?? 'trial',
                            valueWidget: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    _organization!.subscriptionStatus == 'trial'
                                    ? Colors.orange.shade100
                                    : Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _organization!.subscriptionStatus ?? 'trial',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      _organization!.subscriptionStatus ==
                                          'trial'
                                      ? Colors.orange.shade900
                                      : Colors.green.shade900,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          _InfoRow(
                            icon: Icons.event,
                            label: 'Start Date',
                            value: _organization!.subscriptionStart != null
                                ? _formatDate(_organization!.subscriptionStart!)
                                : '-',
                          ),
                          _InfoRow(
                            icon: Icons.event_busy,
                            label: 'End Date',
                            value: _organization!.subscriptionEnd != null
                                ? _formatDate(_organization!.subscriptionEnd!)
                                : '-',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Quick Stats
                      _InfoCard(
                        title: 'Quick Stats',
                        icon: Icons.bar_chart,
                        children: [
                          _InfoRow(
                            icon: Icons.account_tree,
                            label: 'Total Branches',
                            value: '${_organization!.currentBranchCount ?? 0}',
                          ),
                          _InfoRow(
                            icon: Icons.people,
                            label: 'Total Users',
                            value: '${_organization!.currentUserCount ?? 0}',
                          ),
                          _InfoRow(
                            icon: Icons.storage,
                            label: 'Storage Used',
                            value:
                                '${(_organization!.currentStorageUsed ?? 0) / 1024 / 1024 / 1024} GB',
                          ),
                          _InfoRow(
                            icon: Icons.power_settings_new,
                            label: 'Active Status',
                            valueWidget: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _organization!.isActive
                                    ? Colors.green.shade100
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _organization!.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _organization!.isActive
                                      ? Colors.green.shade900
                                      : Colors.grey.shade900,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Usage Statistics
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E293B)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.bar_chart,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Usage Statistics',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFFF1F5F9)
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        _UsageBar(
                          label: 'Users',
                          current: _organization!.currentUserCount ?? 0,
                          limit: _organization!.userLimit ?? 10,
                        ),
                        const SizedBox(height: 16),
                        _UsageBar(
                          label: 'Branches',
                          current: _organization!.currentBranchCount ?? 0,
                          limit: _organization!.branchLimit ?? 1,
                        ),
                        const SizedBox(height: 16),
                        _UsageBar(
                          label: 'Storage (GB)',
                          current:
                              (_organization!.currentStorageUsed ?? 0) ~/
                              (1024 * 1024 * 1024),
                          limit:
                              (_organization!.storageLimit ?? 1073741824) ~/
                              (1024 * 1024 * 1024),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}

// Info Card Widget
class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E293B)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFFF1F5F9)
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }
}

// Info Row Widget
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _InfoRow({
    required this.icon,
    required this.label,
    this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF94A3B8)
                        : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                valueWidget ??
                    Text(
                      value ?? '-',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFFE2E8F0)
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Usage Bar Widget
class _UsageBar extends StatelessWidget {
  final String label;
  final int current;
  final int limit;

  const _UsageBar({
    required this.label,
    required this.current,
    required this.limit,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = limit > 0 ? (current / limit * 100).clamp(0, 100) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFFE2E8F0)
                    : AppColors.textPrimary,
              ),
            ),
            Text(
              '$current / $limit (${percentage.toStringAsFixed(0)}%)',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF94A3B8)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage > 80
                  ? Colors.red
                  : percentage > 60
                  ? Colors.orange
                  : Colors.green,
            ),
          ),
        ),
      ],
    );
  }
}
