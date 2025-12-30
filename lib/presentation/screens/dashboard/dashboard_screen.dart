import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../layouts/main_layout.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;
        final org = authProvider.organization;

        return MainLayout(
          title: 'Dashboard',
          child: _ResponsiveDashboard(user: user, organization: org),
        );
      },
    );
  }
}

class _ResponsiveDashboard extends StatelessWidget {
  final dynamic user;
  final Map<String, dynamic>? organization;

  const _ResponsiveDashboard({this.user, this.organization});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine layout based on screen width
        final width = constraints.maxWidth;
        final isMobile = width < 600;
        final isTablet = width >= 600 && width < 1024;
        final isDesktop = width >= 1024;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(context, isMobile),
              SizedBox(height: isMobile ? 20 : 32),

              // Stats Cards
              _buildStatsSection(context, isMobile, isTablet, isDesktop),
              SizedBox(height: isMobile ? 20 : 32),

              // Quick Actions
              _buildQuickActionsSection(context, isMobile),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, ${user?.firstName ?? 'User'}!',
          style: isMobile
              ? Theme.of(context).textTheme.headlineSmall
              : Theme.of(context).textTheme.headlineMedium,
        ),
        if (organization != null) ...[
          const SizedBox(height: 4),
          Text(
            organization!['name'] ?? '',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsSection(
    BuildContext context,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    final stats = [
      _StatData(
        'Employees',
        organization?['usage']?['users']?['current']?.toString() ?? '0',
        Icons.people_outline,
        AppTheme.primaryColor,
      ),
      _StatData(
        'Branches',
        organization?['usage']?['branches']?['current']?.toString() ?? '0',
        Icons.business_outlined,
        AppTheme.secondaryColor,
      ),
      _StatData(
        'Attendance Today',
        '0',
        Icons.check_circle_outline,
        AppTheme.successColor,
      ),
      _StatData(
        'Leave Requests',
        '0',
        Icons.pending_outlined,
        AppTheme.warningColor,
      ),
    ];

    if (isMobile) {
      // Mobile: Vertical list
      return Column(
        children: stats
            .map(
              (stat) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildStatCardHorizontal(context, stat),
              ),
            )
            .toList(),
      );
    } else if (isTablet) {
      // Tablet: 2 columns
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: stats
            .map(
              (stat) => SizedBox(
                width: (MediaQuery.of(context).size.width - 64) / 2,
                child: _buildStatCardVertical(context, stat),
              ),
            )
            .toList(),
      );
    } else {
      // Desktop: 4 columns
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: stats
            .map(
              (stat) => SizedBox(
                width: (MediaQuery.of(context).size.width - 96) / 4,
                child: _buildStatCardVertical(context, stat),
              ),
            )
            .toList(),
      );
    }
  }

  Widget _buildStatCardHorizontal(BuildContext context, _StatData stat) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: stat.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(stat.icon, color: stat.color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat.value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: stat.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCardVertical(BuildContext context, _StatData stat) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: stat.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(stat.icon, color: stat.color, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              stat.value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: stat.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              stat.title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        if (isMobile)
          Column(
            children: [
              _buildQuickActionButton(
                context,
                'Add Employee',
                Icons.person_add,
              ),
              const SizedBox(height: 8),
              _buildQuickActionButton(context, 'Mark Attendance', Icons.check),
              const SizedBox(height: 8),
              _buildQuickActionButton(context, 'Apply Leave', Icons.event_busy),
              const SizedBox(height: 8),
              _buildQuickActionButton(context, 'View Payroll', Icons.payments),
            ],
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildQuickActionButton(
                context,
                'Add Employee',
                Icons.person_add,
              ),
              _buildQuickActionButton(context, 'Mark Attendance', Icons.check),
              _buildQuickActionButton(context, 'Apply Leave', Icons.event_busy),
              _buildQuickActionButton(context, 'View Payroll', Icons.payments),
            ],
          ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SizedBox(
      width: isMobile ? double.infinity : 200,
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title - Coming soon'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        icon: Icon(icon, size: 20),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          alignment: isMobile ? Alignment.centerLeft : Alignment.center,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class _StatData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  _StatData(this.title, this.value, this.icon, this.color);
}
