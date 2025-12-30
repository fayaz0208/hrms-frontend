import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/providers/organization_provider.dart';

import '../../layouts/main_layout.dart';
import 'organization_detail_screen.dart';
import 'organization_form_screen.dart';

class OrganizationsListScreen extends StatefulWidget {
  const OrganizationsListScreen({super.key});
  @override
  State<OrganizationsListScreen> createState() =>
      _OrganizationsListScreenState();
}

class _OrganizationsListScreenState extends State<OrganizationsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrganizationProvider>(
        context,
        listen: false,
      ).fetchOrganizations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Organizations',
      child: Consumer<OrganizationProvider>(
        builder: (context, provider, _) {
          if (provider.isOrganizationsLoading &&
              provider.organizations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null && provider.organizations.isEmpty) {
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
                    onPressed: () => provider.fetchOrganizations(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          final orgs = provider.filteredOrganizations;
          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Organizations',
                            style: TextStyle(
                              fontSize: Platform.isAndroid ? 20 : 28,
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
                            'Manage all organizations',
                            style: TextStyle(
                              fontSize: Platform.isAndroid ? 11 : 14,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(0xFF94A3B8)
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await showOrganizationFormDialog(
                          context: context,
                        );
                        if (result == true && context.mounted) {
                          provider.fetchOrganizations();
                        }
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text(
                        'Add Organization',
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
              ),
              // Content
              Expanded(
                child: orgs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.business_outlined,
                              size: 64,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 16),
                            const Text('No organizations found'),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final result = await showOrganizationFormDialog(
                                  context: context,
                                );
                                if (result == true && context.mounted) {
                                  provider.fetchOrganizations();
                                }
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Create First Organization'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: orgs.length,
                        itemBuilder: (context, index) {
                          final org = orgs[index];
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
                                  org.name[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                org.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${org.currentUserCount ?? 0} users • ${org.currentBranchCount ?? 0} branches',
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
                                          case 'view':
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    OrganizationDetailScreen(
                                                      organizationId: org.id,
                                                    ),
                                              ),
                                            );
                                            break;
                                          case 'edit':
                                            final result =
                                                await showOrganizationFormDialog(
                                                  context: context,
                                                  organization: org,
                                                );
                                            if (result == true &&
                                                context.mounted) {
                                              provider.fetchOrganizations();
                                            }
                                            break;
                                          case 'delete':
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text(
                                                  'Delete Organization',
                                                ),
                                                content: Text(
                                                  'Are you sure you want to delete "${org.name}"?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          false,
                                                        ),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          true,
                                                        ),
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              AppColors.danger,
                                                        ),
                                                    child: const Text('Delete'),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirm == true &&
                                                context.mounted) {
                                              await provider.deleteOrganization(
                                                org.id,
                                              );
                                              if (context.mounted) {
                                                provider.fetchOrganizations();
                                              }
                                            }
                                            break;
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'view',
                                          child: Row(
                                            children: [
                                              Icon(Icons.visibility, size: 18),
                                              SizedBox(width: 8),
                                              Text('View Details'),
                                            ],
                                          ),
                                        ),
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
                                      width: 110,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.visibility,
                                              size: 14,
                                            ),
                                            tooltip: 'View Details',
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 28,
                                              minHeight: 28,
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrganizationDetailScreen(
                                                        organizationId: org.id,
                                                      ),
                                                ),
                                              );
                                            },
                                            color: AppColors.primary,
                                          ),
                                          // Edit Button
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              size: 14,
                                            ),
                                            tooltip: 'Edit',
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 28,
                                              minHeight: 28,
                                            ),
                                            onPressed: () async {
                                              final result =
                                                  await showOrganizationFormDialog(
                                                    context: context,
                                                    organization: org,
                                                  );
                                              if (result == true &&
                                                  context.mounted) {
                                                provider.fetchOrganizations();
                                              }
                                            },
                                            color: Colors.orange,
                                          ),
                                          // Delete Button
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              size: 14,
                                            ),
                                            tooltip: 'Delete',
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 28,
                                              minHeight: 28,
                                            ),
                                            onPressed: () async {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text(
                                                    'Delete Organization',
                                                  ),
                                                  content: Text(
                                                    'Are you sure you want to delete "${org.name}"?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            false,
                                                          ),
                                                      child: const Text(
                                                        'Cancel',
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            true,
                                                          ),
                                                      style:
                                                          ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                AppColors
                                                                    .danger,
                                                          ),
                                                      child: const Text(
                                                        'Delete',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (confirm == true &&
                                                  context.mounted) {
                                                await provider
                                                    .deleteOrganization(org.id);
                                                if (context.mounted) {
                                                  provider.fetchOrganizations();
                                                }
                                              }
                                            },
                                            color: AppColors.danger,
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
