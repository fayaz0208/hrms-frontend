import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/providers/user_provider.dart';
import '../../layouts/main_layout.dart';
import 'user_form_screen.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await Future.wait([
      userProvider.fetchUsers(),
      userProvider.fetchRoles(),
      userProvider.fetchBranches(),
    ]);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToUserForm({dynamic user}) async {
    final result = await showUserFormDialog(context: context, user: user);
    if (result == true && mounted) {
      _loadData();
    }
  }

  void _showDeleteConfirmation(dynamic user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to delete ${user.fullName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = Provider.of<UserProvider>(
                context,
                listen: false,
              );
              final success = await provider.deleteUser(user.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'User deleted successfully'
                          : provider.error ?? 'Failed to delete user',
                    ),
                    backgroundColor: success
                        ? AppColors.success
                        : AppColors.danger,
                  ),
                );
                if (success) {
                  _loadData();
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(String? dateStr) {
    if (dateStr == null) return 'Never';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()} years ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} months ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  Color _getRoleBadgeColor(String? roleName) {
    if (roleName == null) return Colors.grey;
    final role = roleName.toLowerCase();
    if (role.contains('admin')) return const Color(0xFFFF6B6B);
    if (role.contains('manager')) return const Color(0xFFFFA500);
    if (role.contains('employee')) return const Color(0xFF6C757D);
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'User Management',
      child: Consumer<UserProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = provider.users;
          final totalUsers = users.length;
          final activeUsers = users.where((u) => !u.inactive).length;
          final admins = users
              .where(
                (u) => u.roleName?.toLowerCase().contains('admin') ?? false,
              )
              .length;
          final managers = users
              .where(
                (u) => u.roleName?.toLowerCase().contains('manager') ?? false,
              )
              .length;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header with title and button
                Container(
                  padding: const EdgeInsets.all(24),
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'User Management',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Manage your team members and their roles',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey.shade400
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => _navigateToUserForm(),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text(
                              'Create User',
                              style: TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Stats Cards - Responsive
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // Use wrap for smaller screens, row for larger
                          if (constraints.maxWidth < 800) {
                            return ClipRect(
                              child: Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  _StatCard(
                                    icon: Icons.people,
                                    iconColor: const Color(0xFF5B8DEF),
                                    iconBgColor: const Color(0xFFE3EFFF),
                                    count: totalUsers.toString(),
                                    label: 'Total Users',
                                  ),
                                  _StatCard(
                                    icon: Icons.check_circle,
                                    iconColor: const Color(0xFF4CAF50),
                                    iconBgColor: const Color(0xFFE8F5E9),
                                    count: activeUsers.toString(),
                                    label: 'Active Users',
                                  ),
                                  _StatCard(
                                    icon: Icons.admin_panel_settings,
                                    iconColor: const Color(0xFF9C27B0),
                                    iconBgColor: const Color(0xFFF3E5F5),
                                    count: admins.toString(),
                                    label: 'Admins',
                                  ),
                                  _StatCard(
                                    icon: Icons.supervisor_account,
                                    iconColor: const Color(0xFFFFA500),
                                    iconBgColor: const Color(0xFFFFF3E0),
                                    count: managers.toString(),
                                    label: 'Managers',
                                  ),
                                ],
                              ),
                            );
                          }
                          return ClipRect(
                            child: Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.people,
                                    iconColor: const Color(0xFF5B8DEF),
                                    iconBgColor: const Color(0xFFE3EFFF),
                                    count: totalUsers.toString(),
                                    label: 'Total Users',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.check_circle,
                                    iconColor: const Color(0xFF4CAF50),
                                    iconBgColor: const Color(0xFFE8F5E9),
                                    count: activeUsers.toString(),
                                    label: 'Active Users',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.admin_panel_settings,
                                    iconColor: const Color(0xFF9C27B0),
                                    iconBgColor: const Color(0xFFF3E5F5),
                                    count: admins.toString(),
                                    label: 'Admins',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.supervisor_account,
                                    iconColor: const Color(0xFFFFA500),
                                    iconBgColor: const Color(0xFFFFF3E0),
                                    count: managers.toString(),
                                    label: 'Managers',
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      // Search Bar
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search users...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.textMuted,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                        ),
                        onChanged: (value) {
                          // Implement search
                        },
                      ),
                    ],
                  ),
                ),
                // Data Table
                users.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(48),
                        color: Theme.of(context).colorScheme.surface,
                        child: const Center(child: Text('No users found')),
                      )
                    : Container(
                        color: Theme.of(context).colorScheme.surface,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 24,
                        ),
                        child: kIsWeb
                            ? Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.border),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Table(
                                  columnWidths: const {
                                    0: FlexColumnWidth(3), // User column
                                    1: FlexColumnWidth(2), // Role column
                                    2: FlexColumnWidth(2), // Department column
                                    3: FlexColumnWidth(1.5), // Status column
                                    4: FlexColumnWidth(2), // Last Active column
                                    5: FlexColumnWidth(1.5), // Actions column
                                  },
                                  children: [
                                    // Header Row
                                    TableRow(
                                      decoration: BoxDecoration(
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? const Color(0xFF1E293B)
                                            : const Color(0xFFF8F9FA),
                                        border: const Border(
                                          bottom: BorderSide(
                                            color: AppColors.border,
                                          ),
                                        ),
                                      ),
                                      children: [
                                        _TableHeader('User', context),
                                        _TableHeader('Role', context),
                                        _TableHeader('Department', context),
                                        _TableHeader('Status', context),
                                        _TableHeader('Last Active', context),
                                        _TableHeader('Actions', context),
                                      ],
                                    ),
                                    // Data Rows
                                    ...users.map(
                                      (user) => TableRow(
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: AppColors.borderLight,
                                            ),
                                          ),
                                        ),
                                        children: [
                                          _UserCell(
                                            name: user.fullName,
                                            email: user.email,
                                          ),
                                          _RoleBadgeCell(
                                            role: user.roleName ?? 'No Role',
                                            color: _getRoleBadgeColor(
                                              user.roleName,
                                            ),
                                          ),
                                          _TextCell(
                                            user.departmentName ?? '-',
                                            context,
                                          ),
                                          _StatusCell(isActive: !user.inactive),
                                          _TextCell(
                                            _getTimeAgo(user.joiningDate),
                                            context,
                                          ),
                                          _ActionsCell(
                                            onEdit: () =>
                                                _navigateToUserForm(user: user),
                                            onDelete: () =>
                                                _showDeleteConfirmation(user),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Table(
                                    columnWidths: const {
                                      0: FixedColumnWidth(200), // User column
                                      1: FixedColumnWidth(120), // Role column
                                      2: FixedColumnWidth(
                                        150,
                                      ), // Department column
                                      3: FixedColumnWidth(100), // Status column
                                      4: FixedColumnWidth(
                                        120,
                                      ), // Last Active column
                                      5: FixedColumnWidth(
                                        100,
                                      ), // Actions column
                                    },
                                    children: [
                                      // Header Row
                                      TableRow(
                                        decoration: BoxDecoration(
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? const Color(0xFF1E293B)
                                              : const Color(0xFFF8F9FA),
                                          border: const Border(
                                            bottom: BorderSide(
                                              color: AppColors.border,
                                            ),
                                          ),
                                        ),
                                        children: [
                                          _TableHeader('User', context),
                                          _TableHeader('Role', context),
                                          _TableHeader('Department', context),
                                          _TableHeader('Status', context),
                                          _TableHeader('Last Active', context),
                                          _TableHeader('Actions', context),
                                        ],
                                      ),
                                      // Data Rows
                                      ...users.map(
                                        (user) => TableRow(
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: AppColors.borderLight,
                                              ),
                                            ),
                                          ),
                                          children: [
                                            _UserCell(
                                              name: user.fullName,
                                              email: user.email,
                                            ),
                                            _RoleBadgeCell(
                                              role: user.roleName ?? 'No Role',
                                              color: _getRoleBadgeColor(
                                                user.roleName,
                                              ),
                                            ),
                                            _TextCell(
                                              user.departmentName ?? '-',
                                              context,
                                            ),
                                            _StatusCell(
                                              isActive: !user.inactive,
                                            ),
                                            _TextCell(
                                              _getTimeAgo(user.joiningDate),
                                              context,
                                            ),
                                            _ActionsCell(
                                              onEdit: () => _navigateToUserForm(
                                                user: user,
                                              ),
                                              onDelete: () =>
                                                  _showDeleteConfirmation(user),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Stat Card Widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String count;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    count,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFFF1F5F9)
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF94A3B8)
                        : AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Table Widgets
Widget _TableHeader(String text, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF94A3B8)
            : AppColors.textSecondary,
      ),
    ),
  );
}

class _UserCell extends StatelessWidget {
  final String name;
  final String email;

  const _UserCell({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFFF1F5F9)
                        : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF94A3B8)
                        : AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleBadgeCell extends StatelessWidget {
  final String role;
  final Color color;

  const _RoleBadgeCell({required this.role, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          role,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

Widget _TextCell(String text, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 13,
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFFE2E8F0)
            : AppColors.textPrimary,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

class _StatusCell extends StatelessWidget {
  final bool isActive;

  const _StatusCell({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          isActive ? 'Active' : 'Inactive',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive ? const Color(0xFF4CAF50) : const Color(0xFF9E9E9E),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ActionsCell extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ActionsCell({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: !kIsWeb && Platform.isAndroid
          ? PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18),
              padding: EdgeInsets.zero,
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: AppColors.danger),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: AppColors.danger)),
                    ],
                  ),
                ),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 16),
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete, size: 16),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: AppColors.danger,
                ),
              ],
            ),
    );
  }
}
