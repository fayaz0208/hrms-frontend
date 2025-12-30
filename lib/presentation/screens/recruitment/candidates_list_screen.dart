import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/providers/recruitment_provider.dart';
import '../../../data/models/candidate_model.dart';
import '../../layouts/main_layout.dart';
import 'candidate_form_screen.dart';

class CandidatesListScreen extends StatefulWidget {
  const CandidatesListScreen({super.key});

  @override
  State<CandidatesListScreen> createState() => _CandidatesListScreenState();
}

class _CandidatesListScreenState extends State<CandidatesListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecruitmentProvider>(
        context,
        listen: false,
      ).fetchCandidates();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToCandidateForm({Candidate? candidate}) async {
    final result = await showCandidateFormDialog(
      context: context,
      candidate: candidate,
    );
    if (result == true && mounted) {
      Provider.of<RecruitmentProvider>(
        context,
        listen: false,
      ).fetchCandidates();
    }
  }

  void _showDeleteConfirmation(Candidate candidate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Candidate'),
        content: Text('Are you sure you want to delete ${candidate.fullName}?'),
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
              final success = await provider.deleteCandidate(candidate.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Candidate deleted successfully'
                          : provider.candidatesError ??
                                'Failed to delete candidate',
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'shortlisted':
        return const Color(0xFF2196F3);
      case 'interviewed':
        return const Color(0xFFFFA500);
      case 'hired':
        return const Color(0xFF4CAF50);
      case 'rejected':
        return const Color(0xFFFF5252);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Candidates',
      child: Consumer<RecruitmentProvider>(
        builder: (context, provider, _) {
          if (provider.isCandidatesLoading && provider.candidates.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final candidates = provider.candidates;
          final totalCandidates = candidates.length;
          final shortlisted = candidates
              .where((c) => c.status.toLowerCase() == 'shortlisted')
              .length;
          final interviewed = candidates
              .where((c) => c.status.toLowerCase() == 'interviewed')
              .length;
          final hired = candidates
              .where((c) => c.status.toLowerCase() == 'hired')
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
                                'Candidates',
                                style: TextStyle(
                                  fontSize: Platform.isAndroid ? 20 : 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Manage job applicants and candidates',
                                style: TextStyle(
                                  fontSize: Platform.isAndroid ? 11 : 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _navigateToCandidateForm(),
                            icon: Icon(
                              Icons.add,
                              size: Platform.isAndroid ? 16 : 20,
                            ),
                            label: Text(
                              'Add Candidate',
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
                                  icon: Icons.people,
                                  iconColor: const Color(0xFF5B8DEF),
                                  iconBgColor: const Color(0xFFE3EFFF),
                                  count: totalCandidates.toString(),
                                  label: 'Total Candidates',
                                ),
                                _StatCard(
                                  icon: Icons.star,
                                  iconColor: const Color(0xFF2196F3),
                                  iconBgColor: const Color(0xFFE3F2FD),
                                  count: shortlisted.toString(),
                                  label: 'Shortlisted',
                                ),
                                _StatCard(
                                  icon: Icons.event,
                                  iconColor: const Color(0xFFFFA500),
                                  iconBgColor: const Color(0xFFFFF3E0),
                                  count: interviewed.toString(),
                                  label: 'Interviewed',
                                ),
                                _StatCard(
                                  icon: Icons.check_circle,
                                  iconColor: const Color(0xFF4CAF50),
                                  iconBgColor: const Color(0xFFE8F5E9),
                                  count: hired.toString(),
                                  label: 'Hired',
                                ),
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.people,
                                  iconColor: const Color(0xFF5B8DEF),
                                  iconBgColor: const Color(0xFFE3EFFF),
                                  count: totalCandidates.toString(),
                                  label: 'Total Candidates',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.star,
                                  iconColor: const Color(0xFF2196F3),
                                  iconBgColor: const Color(0xFFE3F2FD),
                                  count: shortlisted.toString(),
                                  label: 'Shortlisted',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.event,
                                  iconColor: const Color(0xFFFFA500),
                                  iconBgColor: const Color(0xFFFFF3E0),
                                  count: interviewed.toString(),
                                  label: 'Interviewed',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.check_circle,
                                  iconColor: const Color(0xFF4CAF50),
                                  iconBgColor: const Color(0xFFE8F5E9),
                                  count: hired.toString(),
                                  label: 'Hired',
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
                          hintText: 'Search candidates...',
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
                candidates.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(48),
                        color: Theme.of(context).colorScheme.surface,
                        child: const Center(child: Text('No candidates found')),
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
                              1: FlexColumnWidth(2),
                              2: FlexColumnWidth(2),
                              3: FlexColumnWidth(1.5),
                              4: FlexColumnWidth(1.5),
                              5: FlexColumnWidth(1.5),
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
                                  _TableHeader('Candidate', context),
                                  _TableHeader('Email', context),
                                  _TableHeader('Phone', context),
                                  _TableHeader('Applied Date', context),
                                  _TableHeader('Status', context),
                                  _TableHeader('Actions', context),
                                ],
                              ),
                              // Data Rows
                              ...candidates.map(
                                (candidate) => TableRow(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: AppColors.borderLight,
                                      ),
                                    ),
                                  ),
                                  children: [
                                    _CandidateCell(
                                      name: candidate.fullName,
                                      hasResume: candidate.hasResume,
                                    ),
                                    _TextCell(candidate.email, context),
                                    _TextCell(candidate.phoneNumber, context),
                                    _TextCell(
                                      _formatDate(candidate.appliedDate),
                                      context,
                                    ),
                                    _StatusBadgeCell(
                                      status: candidate.status,
                                      color: _getStatusColor(candidate.status),
                                    ),
                                    _ActionsCell(
                                      onEdit: () => _navigateToCandidateForm(
                                        candidate: candidate,
                                      ),
                                      onDelete: () =>
                                          _showDeleteConfirmation(candidate),
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

class _CandidateCell extends StatelessWidget {
  final String name;
  final bool hasResume;

  const _CandidateCell({required this.name, required this.hasResume});

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
                if (hasResume)
                  Row(
                    children: [
                      Icon(
                        Icons.attach_file,
                        size: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF94A3B8)
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Resume attached',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF94A3B8)
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
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

class _StatusBadgeCell extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusBadgeCell({required this.status, required this.color});

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
          status,
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
