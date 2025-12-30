import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/providers/organization_provider.dart';
import '../../layouts/main_layout.dart';
import 'department_form_screen.dart';

class DepartmentsListScreen extends StatefulWidget {
  const DepartmentsListScreen({super.key});

  @override
  State<DepartmentsListScreen> createState() => _DepartmentsListScreenState();
}

class _DepartmentsListScreenState extends State<DepartmentsListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<OrganizationProvider>(
        context,
        listen: false,
      );
      provider.fetchDepartments();
      provider.fetchBranches();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToDepartmentForm({dynamic dept}) async {
    final result = await showDepartmentFormDialog(
      context: context,
      department: dept,
    );
    if (result == true && mounted) {
      Provider.of<OrganizationProvider>(
        context,
        listen: false,
      ).fetchDepartments();
    }
  }

  void _deleteDepartment(dynamic dept) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Department'),
        content: Text(
          'Are you sure you want to delete "${dept.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = Provider.of<OrganizationProvider>(
        context,
        listen: false,
      );
      final success = await provider.deleteDepartment(dept.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Department "${dept.name}" deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to delete department'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Departments',
      child: Consumer<OrganizationProvider>(
        builder: (context, provider, _) {
          if (provider.isDepartmentsLoading && provider.departments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.departments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.danger,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => provider.fetchDepartments(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final departments = provider.departments;

          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                color: Theme.of(context).colorScheme.surface,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Departments',
                          style: TextStyle(
                            fontSize: Platform.isAndroid ? 20 : 28,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFFF1F5F9)
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage all departments',
                          style: TextStyle(
                            fontSize: Platform.isAndroid ? 11 : 14,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF94A3B8)
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _navigateToDepartmentForm(),
                      icon: Icon(Icons.add, size: Platform.isAndroid ? 16 : 20),
                      label: Text(
                        'Add Department',
                        style: TextStyle(
                          fontSize: Platform.isAndroid ? 11 : 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: Platform.isAndroid ? 10 : 24,
                          vertical: Platform.isAndroid ? 8 : 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: departments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.business_center_outlined,
                              size: 64,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 16),
                            const Text('No departments found'),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => _navigateToDepartmentForm(),
                              icon: const Icon(Icons.add),
                              label: const Text('Add First Department'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: departments.length,
                        itemBuilder: (context, index) {
                          final dept = departments[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  dept.name[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                dept.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${dept.branchName ?? 'No branch'} • ${dept.employeeCount ?? 0} employees',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Platform.isAndroid
                                  ? PopupMenuButton<String>(
                                      icon: const Icon(
                                        Icons.more_vert,
                                        size: 20,
                                      ),
                                      padding: EdgeInsets.zero,
                                      onSelected: (value) async {
                                        switch (value) {
                                          case 'edit':
                                            _navigateToDepartmentForm(
                                              dept: dept,
                                            );
                                            break;
                                          case 'delete':
                                            _deleteDepartment(dept);
                                            break;
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit, size: 18),
                                              SizedBox(width: 8),
                                              Text('Edit'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete,
                                                size: 18,
                                                color: AppColors.danger,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: AppColors.danger,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : SizedBox(
                                      width: 136,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          if (dept.managerName != null)
                                            Flexible(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 2,
                                                ),
                                                child: Chip(
                                                  label: Text(
                                                    dept.managerName!,
                                                    style: const TextStyle(
                                                      fontSize: 9,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  avatar: const Icon(
                                                    Icons.person,
                                                    size: 10,
                                                  ),
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  padding: EdgeInsets.zero,
                                                ),
                                              ),
                                            ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              size: 14,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 28,
                                              minHeight: 28,
                                            ),
                                            onPressed: () =>
                                                _navigateToDepartmentForm(
                                                  dept: dept,
                                                ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              size: 14,
                                              color: AppColors.danger,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 28,
                                              minHeight: 28,
                                            ),
                                            onPressed: () =>
                                                _deleteDepartment(dept),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
