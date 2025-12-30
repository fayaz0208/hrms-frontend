import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/providers/organization_provider.dart';

import '../../layouts/main_layout.dart';
import 'branch_form_screen.dart';

class BranchesListScreen extends StatefulWidget {
  const BranchesListScreen({super.key});

  @override
  State<BranchesListScreen> createState() => _BranchesListScreenState();
}

class _BranchesListScreenState extends State<BranchesListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrganizationProvider>(context, listen: false).fetchBranches();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToBranchForm({dynamic branch}) async {
    final result = await showBranchFormDialog(context: context, branch: branch);
    if (result == true && mounted) {
      Provider.of<OrganizationProvider>(context, listen: false).fetchBranches();
    }
  }

  void _deleteBranch(dynamic branch) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Branch'),
        content: Text(
          'Are you sure you want to delete "${branch.name}"? This action cannot be undone.',
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
      final success = await provider.deleteBranch(branch.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Branch "${branch.name}" deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to delete branch'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Branches',
      child: Consumer<OrganizationProvider>(
        builder: (context, provider, _) {
          if (provider.isBranchesLoading && provider.branches.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.branches.isEmpty) {
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
                    onPressed: () => provider.fetchBranches(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final branches = provider.branches;

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
                          'Branches',
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
                          'Manage all branches',
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
                      onPressed: () => _navigateToBranchForm(),
                      icon: Icon(Icons.add, size: Platform.isAndroid ? 16 : 20),
                      label: Text(
                        'Add Branch',
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
                child: branches.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.account_balance_outlined,
                              size: 64,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 16),
                            const Text('No branches found'),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => _navigateToBranchForm(),
                              icon: const Icon(Icons.add),
                              label: const Text('Add First Branch'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: branches.length,
                        itemBuilder: (context, index) {
                          final branch = branches[index];
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
                                  branch.name[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                branch.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${branch.organizationName ?? 'No organization'}${branch.city != null ? ' • ${branch.city}' : ''}',
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
                                            _navigateToBranchForm(
                                              branch: branch,
                                            );
                                            break;
                                          case 'delete':
                                            _deleteBranch(branch);
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
                                      width: 96,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
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
                                                _navigateToBranchForm(
                                                  branch: branch,
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
                                                _deleteBranch(branch),
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
