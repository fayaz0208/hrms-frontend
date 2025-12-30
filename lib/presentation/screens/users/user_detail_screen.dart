import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/providers/user_provider.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/status_badge.dart';
import 'user_form_screen.dart';
import 'assign_shift_screen.dart';

/// Screen for viewing complete user information
class UserDetailScreen extends StatefulWidget {
  final int userId;

  const UserDetailScreen({super.key, required this.userId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = await userProvider.getUserById(widget.userId);

    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteUser() async {
    if (_user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${_user!.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final success = await userProvider.deleteUser(widget.userId);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(userProvider.error ?? 'Failed to delete user'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _navigateToEdit() async {
    if (_user != null) {
      final result = await showUserFormDialog(context: context, user: _user);
      if (result == true && mounted) {
        _loadUser();
      }
    }
  }

  void _navigateToAssignShift() {
    if (_user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AssignShiftScreen(user: _user)),
      ).then((_) => _loadUser());
    }
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEdit,
            tooltip: 'Edit User',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteUser,
            tooltip: 'Delete User',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('User not found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadUser,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              _user!.fullName.isNotEmpty
                                  ? _user!.fullName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 48,
                                color: Colors.blue.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _user!.fullName,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _user!.email,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          StatusBadge(isActive: !_user!.inactive),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Basic Information
                    _buildSection('Basic Information', [
                      _buildInfoRow('First Name', _user!.firstName),
                      _buildInfoRow('Last Name', _user!.lastName),
                      _buildInfoRow('Email', _user!.email),
                      _buildInfoRow('Role', _user!.roleName),
                      _buildInfoRow('Designation', _user!.designation),
                      _buildInfoRow('Joining Date', _user!.joiningDate),
                    ]),

                    // Organization Information
                    _buildSection('Organization Information', [
                      _buildInfoRow('Organization', _user!.organizationName),
                      _buildInfoRow('Branch', _user!.branchName),
                      _buildInfoRow('Department', _user!.departmentName),
                      _buildInfoRow(
                        'Is Org Admin',
                        _user!.isOrgAdmin ? 'Yes' : 'No',
                      ),
                    ]),

                    // Additional Information
                    _buildSection('Additional Information', [
                      _buildInfoRow('Biometric ID', _user!.biometricId),
                      _buildInfoRow(
                        'Status',
                        _user!.inactive ? 'Inactive' : 'Active',
                      ),
                    ]),

                    // Action Buttons
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _navigateToEdit,
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit User'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _navigateToAssignShift,
                          icon: const Icon(Icons.schedule),
                          label: const Text('Assign Shift'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: _deleteUser,
                          icon: const Icon(Icons.delete),
                          label: const Text('Delete'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
