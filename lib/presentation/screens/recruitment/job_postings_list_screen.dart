import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/providers/recruitment_provider.dart';
import '../../../data/models/job_posting_model.dart';
import '../../layouts/main_layout.dart';
import 'job_posting_form_screen.dart';

class JobPostingsListScreen extends StatefulWidget {
  const JobPostingsListScreen({super.key});

  @override
  State<JobPostingsListScreen> createState() => _JobPostingsListScreenState();
}

class _JobPostingsListScreenState extends State<JobPostingsListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecruitmentProvider>(
        context,
        listen: false,
      ).fetchJobPostings();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToJobPostingForm({JobPosting? jobPosting}) async {
    final result = await showJobPostingFormDialog(
      context: context,
      jobPosting: jobPosting,
    );
    if (result == true && mounted) {
      Provider.of<RecruitmentProvider>(
        context,
        listen: false,
      ).fetchJobPostings();
    }
  }

  void _showDeleteConfirmation(JobPosting jobPosting) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Job Posting'),
        content: Text(
          'Are you sure you want to delete the job posting for ${jobPosting.location}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = Provider.of<RecruitmentProvider>(
                context,
                listen: false,
              );
              final success = await provider.deleteJobPosting(jobPosting.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Job posting deleted successfully'
                          : provider.jobPostingsError ??
                                'Failed to delete job posting',
                    ),
                    backgroundColor: success
                        ? AppColors.success
                        : AppColors.danger,
                  ),
                );
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Job Postings',
      child: Consumer<RecruitmentProvider>(
        builder: (context, provider, _) {
          if (provider.isJobPostingsLoading && provider.jobPostings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final jobPostings = provider.jobPostings;
          final totalPostings = jobPostings.length;
          final activePostings = jobPostings.where((j) => j.isOpen).length;
          final pendingApproval = jobPostings
              .where((j) => j.approvalStatus == ApprovalStatus.pending)
              .length;
          final acceptedPostings = jobPostings
              .where((j) => j.approvalStatus == ApprovalStatus.accepted)
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Job Postings',
                                style: TextStyle(
                                  fontSize: Platform.isAndroid ? 20 : 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Manage job openings and recruitment',
                                style: TextStyle(
                                  fontSize: Platform.isAndroid ? 11 : 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _navigateToJobPostingForm(),
                            icon: Icon(
                              Icons.add,
                              size: Platform.isAndroid ? 16 : 20,
                            ),
                            label: Text(
                              'Add Job Posting',
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
                      const SizedBox(height: 24),
                      // Stats Cards
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 800) {
                            return Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                _StatCard(
                                  icon: Icons.work,
                                  iconColor: const Color(0xFF5B8DEF),
                                  iconBgColor: const Color(0xFFE3EFFF),
                                  count: totalPostings.toString(),
                                  label: 'Total Postings',
                                ),
                                _StatCard(
                                  icon: Icons.check_circle,
                                  iconColor: const Color(0xFF4CAF50),
                                  iconBgColor: const Color(0xFFE8F5E9),
                                  count: activePostings.toString(),
                                  label: 'Active',
                                ),
                                _StatCard(
                                  icon: Icons.pending,
                                  iconColor: const Color(0xFFFFA500),
                                  iconBgColor: const Color(0xFFFFF3E0),
                                  count: pendingApproval.toString(),
                                  label: 'Pending Approval',
                                ),
                                _StatCard(
                                  icon: Icons.verified,
                                  iconColor: const Color(0xFF9C27B0),
                                  iconBgColor: const Color(0xFFF3E5F5),
                                  count: acceptedPostings.toString(),
                                  label: 'Accepted',
                                ),
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.work,
                                  iconColor: const Color(0xFF5B8DEF),
                                  iconBgColor: const Color(0xFFE3EFFF),
                                  count: totalPostings.toString(),
                                  label: 'Total Postings',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.check_circle,
                                  iconColor: const Color(0xFF4CAF50),
                                  iconBgColor: const Color(0xFFE8F5E9),
                                  count: activePostings.toString(),
                                  label: 'Active',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.pending,
                                  iconColor: const Color(0xFFFFA500),
                                  iconBgColor: const Color(0xFFFFF3E0),
                                  count: pendingApproval.toString(),
                                  label: 'Pending Approval',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.verified,
                                  iconColor: const Color(0xFF9C27B0),
                                  iconBgColor: const Color(0xFFF3E5F5),
                                  count: acceptedPostings.toString(),
                                  label: 'Accepted',
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      // Search Bar
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search job postings...',
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
                jobPostings.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(48),
                        color: Theme.of(context).colorScheme.surface,
                        child: const Center(
                          child: Text('No job postings found'),
                        ),
                      )
                    : Container(
                        color: Theme.of(context).colorScheme.surface,
                        padding: const EdgeInsets.all(24),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Table(
                            columnWidths: const {
                              0: FlexColumnWidth(2.5),
                              1: FlexColumnWidth(1.5),
                              2: FlexColumnWidth(2),
                              3: FlexColumnWidth(1.5),
                              4: FlexColumnWidth(1.5),
                              5: FlexColumnWidth(1.5),
                              6: FlexColumnWidth(1.5),
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
                                    bottom: BorderSide(color: AppColors.border),
                                  ),
                                ),
                                children: [
                                  _TableHeader('Location', context),
                                  _TableHeader('Positions', context),
                                  _TableHeader('Employment Type', context),
                                  _TableHeader('Salary', context),
                                  _TableHeader('Posted', context),
                                  _TableHeader('Status', context),
                                  _TableHeader('Actions', context),
                                ],
                              ),
                              // Data Rows
                              ...jobPostings.map(
                                (jobPosting) => TableRow(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: AppColors.borderLight,
                                      ),
                                    ),
                                  ),
                                  children: [
                                    _TextCell(jobPosting.location, context),
                                    _TextCell(
                                      '${jobPosting.numberOfPositions}',
                                      context,
                                    ),
                                    _TextCell(
                                      jobPosting.employmentType,
                                      context,
                                    ),
                                    _TextCell(
                                      jobPosting.salary != null
                                          ? '\$${jobPosting.salary}'
                                          : 'N/A',
                                      context,
                                    ),
                                    _TextCell(
                                      _formatDate(jobPosting.postingDate),
                                      context,
                                    ),
                                    _StatusBadgeCell(
                                      status: jobPosting.approvalStatus.name,
                                      approvalStatus: jobPosting.approvalStatus,
                                    ),
                                    _ActionsCell(
                                      onEdit: () => _navigateToJobPostingForm(
                                        jobPosting: jobPosting,
                                      ),
                                      onDelete: () =>
                                          _showDeleteConfirmation(jobPosting),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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

class _StatusBadgeCell extends StatelessWidget {
  final String status;
  final ApprovalStatus approvalStatus;

  const _StatusBadgeCell({required this.status, required this.approvalStatus});

  Color _getStatusColor() {
    switch (approvalStatus) {
      case ApprovalStatus.accepted:
        return const Color(0xFF4CAF50);
      case ApprovalStatus.rejected:
        return const Color(0xFFFF5252);
      case ApprovalStatus.pending:
        return const Color(0xFFFFA500);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          status.toUpperCase(),
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

class _ActionsCell extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ActionsCell({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
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
