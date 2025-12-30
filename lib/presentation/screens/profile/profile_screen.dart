import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/providers/auth_provider.dart';
import '../../layouts/main_layout.dart';

/// User Profile Screen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Profile',
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.user;

          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // Generate initials from user's name
          String getInitials(String name) {
            final parts = name.trim().split(' ');
            if (parts.isEmpty) return 'U';
            if (parts.length == 1) {
              return parts[0][0].toUpperCase();
            }
            return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFFF1F5F9)
                            : AppColors.textPrimary,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Navigate to edit profile
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Profile Card
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1E293B)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF334155)
                          : AppColors.border,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Avatar and Basic Info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              getInitials(user.fullName),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.fullName,
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
                                Text(
                                  user.email,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFF94A3B8)
                                        : AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    user.roleName ?? 'No Role',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 24),

                      // Personal Information
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFFF1F5F9)
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Info Grid
                      _InfoRow(
                        label: 'First Name',
                        value: user.firstName ?? 'N/A',
                      ),
                      _InfoRow(
                        label: 'Last Name',
                        value: user.lastName ?? 'N/A',
                      ),
                      _InfoRow(label: 'Email', value: user.email),
                      _InfoRow(label: 'Role', value: user.roleName ?? 'N/A'),
                      _InfoRow(
                        label: 'Organization',
                        value: user.organizationName ?? 'N/A',
                      ),
                      _InfoRow(
                        label: 'Branch',
                        value: user.branchName ?? 'N/A',
                      ),
                      _InfoRow(
                        label: 'Department',
                        value: user.departmentName ?? 'N/A',
                      ),
                      if (user.designation != null)
                        _InfoRow(
                          label: 'Designation',
                          value: user.designation!,
                        ),
                      if (user.joiningDate != null)
                        _InfoRow(
                          label: 'Joining Date',
                          value: user.joiningDate!.split('T')[0],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await authProvider.logout();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login',
                              (route) => false,
                            );
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF94A3B8)
                    : AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFFF1F5F9)
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
