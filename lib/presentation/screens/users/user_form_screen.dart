import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/providers/user_provider.dart';
import '../../../state/providers/organization_provider.dart';
import '../../../state/providers/auth_provider.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/form_dialog.dart';

/// Show user form as a modal dialog
Future<bool?> showUserFormDialog({required BuildContext context, User? user}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _UserFormDialog(user: user),
  );
}

class _UserFormDialog extends StatefulWidget {
  final User? user;

  const _UserFormDialog({this.user});

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _designationController;
  late TextEditingController _salaryStructureController;
  late TextEditingController _joiningDateController;

  // Dropdown values
  int? _selectedRoleId;
  int? _selectedBranchId;
  int? _selectedDepartmentId;
  int? _selectedOrganizationId;
  DateTime? _joiningDate;

  bool _isEdit = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.user != null;

    _firstNameController = TextEditingController(
      text: widget.user?.firstName ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.user?.lastName ?? '',
    );
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController = TextEditingController();
    _designationController = TextEditingController(
      text: widget.user?.designation ?? '',
    );
    _salaryStructureController = TextEditingController();
    _joiningDateController = TextEditingController(
      text: widget.user?.joiningDate != null
          ? DateFormat(
              'yyyy-MM-dd',
            ).format(DateTime.parse(widget.user!.joiningDate!))
          : '',
    );

    _selectedRoleId = widget.user?.roleId;
    _selectedBranchId = widget.user?.branchId;
    _selectedDepartmentId = widget.user?.departmentId;
    _selectedOrganizationId = widget.user?.organizationId;

    if (widget.user?.joiningDate != null) {
      _joiningDate = DateTime.parse(widget.user!.joiningDate!);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDropdownData();
    });
  }

  Future<void> _loadDropdownData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final orgProvider = Provider.of<OrganizationProvider>(
      context,
      listen: false,
    );
    await Future.wait([
      userProvider.fetchRoles(),
      userProvider.fetchBranches(),
      userProvider.fetchDepartments(),
      orgProvider.fetchOrganizations(),
    ]);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _designationController.dispose();
    _salaryStructureController.dispose();
    _joiningDateController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  Future<void> _pickJoiningDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _joiningDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        _joiningDate = date;
        _joiningDateController.text = DateFormat('yyyy-MM-dd').format(date);
      });
    }
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final userData = {
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'role_id': _selectedRoleId,
      'branch_id': _selectedBranchId,
      'department_id': _selectedDepartmentId,
      'organization_id': _selectedOrganizationId,
      'designation': _designationController.text.trim(),
      'joining_date': _joiningDateController.text,
    };

    // Add password for new users or if changed in edit
    if (!_isEdit || _passwordController.text.isNotEmpty) {
      userData['password'] = _passwordController.text;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    bool success;

    if (_isEdit) {
      success = await userProvider.updateUser(widget.user!.id, userData);
    } else {
      success = await userProvider.createUser(userData);
    }

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userProvider.error ?? 'Failed to save user'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormDialog(
      title: _isEdit ? 'Edit User' : 'Create User',
      isLoading: _isLoading,
      onSave: _saveUser,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personal Information Section
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFFF1F5F9)
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              // First Name and Last Name
              if (!kIsWeb && Platform.isAndroid) ...[
                // Android: Stack vertically
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: 'First Name',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFFF1F5F9)
                              : AppColors.textPrimary,
                        ),
                        children: const [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        hintText: 'First Name',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'First name is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: 'Last Name',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFFF1F5F9)
                              : AppColors.textPrimary,
                        ),
                        children: const [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        hintText: 'Last Name',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Last name is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ] else
                // Web/Other: Side by side
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'First Name',
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFFF1F5F9)
                                    : AppColors.textPrimary,
                              ),
                              children: const [
                                TextSpan(
                                  text: ' *',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              hintText: 'First Name',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'First name is required';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'Last Name',
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFFF1F5F9)
                                    : AppColors.textPrimary,
                              ),
                              children: const [
                                TextSpan(
                                  text: ' *',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              hintText: 'Last Name',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Last name is required';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Email',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFFF1F5F9)
                            : AppColors.textPrimary,
                      ),
                      children: const [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Password',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFFF1F5F9)
                            : AppColors.textPrimary,
                      ),
                      children: [
                        if (!_isEdit)
                          const TextSpan(
                            text: ' *',
                            style: TextStyle(color: Colors.red),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: _isEdit
                          ? 'Leave blank to keep current password'
                          : 'Password',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (!_isEdit && (value == null || value.isEmpty)) {
                        return 'Password is required';
                      }
                      if (value != null &&
                          value.isNotEmpty &&
                          value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Organization Information Section
              Text(
                'Organization Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFFF1F5F9)
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Role',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFFF1F5F9)
                                : AppColors.textPrimary,
                          ),
                          children: const [
                            TextSpan(
                              text: ' *',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        initialValue: _selectedRoleId,
                        decoration: const InputDecoration(
                          hintText: 'Select Role',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        items: userProvider.roles.map((role) {
                          return DropdownMenuItem(
                            value: role.id,
                            child: Text(role.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedRoleId = value);
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Role is required';
                          }
                          return null;
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              // Organization selector (for Super Admin only)
              Consumer2<OrganizationProvider, AuthProvider>(
                builder: (context, orgProvider, authProvider, _) {
                  // Check if current user is super admin
                  final currentUser = authProvider.user;
                  final isSuperAdmin =
                      currentUser?.roleName?.toLowerCase() == 'super_admin';

                  if (!isSuperAdmin) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Organization',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFFF1F5F9)
                                : AppColors.textPrimary,
                          ),
                          children: const [
                            TextSpan(
                              text: ' *',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        initialValue: _selectedOrganizationId,
                        decoration: const InputDecoration(
                          hintText: 'Select Organization',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        items: orgProvider.organizations.map((org) {
                          return DropdownMenuItem(
                            value: org.id,
                            child: Text(org.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedOrganizationId = value);
                        },
                        validator: (value) {
                          if (isSuperAdmin && value == null) {
                            return 'Organization is required for Super Admin';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
              // Branch and Department
              if (!kIsWeb && Platform.isAndroid) ...[
                Consumer<UserProvider>(
                  builder: (context, userProvider, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Branch',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFFF1F5F9)
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          initialValue: _selectedBranchId,
                          decoration: const InputDecoration(
                            hintText: 'Select Branch',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          items: userProvider.branches.map((branch) {
                            return DropdownMenuItem(
                              value: branch.id,
                              child: Text(branch.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedBranchId = value);
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                Consumer<UserProvider>(
                  builder: (context, userProvider, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Department',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFFF1F5F9)
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          initialValue: _selectedDepartmentId,
                          decoration: const InputDecoration(
                            hintText: 'Select Department',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          items: userProvider.departments.map((dept) {
                            return DropdownMenuItem(
                              value: dept.id,
                              child: Text(dept.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedDepartmentId = value);
                          },
                        ),
                      ],
                    );
                  },
                ),
              ] else
                Row(
                  children: [
                    Expanded(
                      child: Consumer<UserProvider>(
                        builder: (context, userProvider, _) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Branch',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFFF1F5F9)
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<int>(
                                initialValue: _selectedBranchId,
                                decoration: const InputDecoration(
                                  hintText: 'Select Branch',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                                items: userProvider.branches.map((branch) {
                                  return DropdownMenuItem(
                                    value: branch.id,
                                    child: Text(branch.name),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() => _selectedBranchId = value);
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Consumer<UserProvider>(
                        builder: (context, userProvider, _) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Department',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFFF1F5F9)
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<int>(
                                initialValue: _selectedDepartmentId,
                                decoration: const InputDecoration(
                                  hintText: 'Select Department',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                                items: userProvider.departments.map((dept) {
                                  return DropdownMenuItem(
                                    value: dept.id,
                                    child: Text(dept.name),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() => _selectedDepartmentId = value);
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              // Designation and Joining Date
              if (!kIsWeb && Platform.isAndroid) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Designation',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFFF1F5F9)
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _designationController,
                      decoration: const InputDecoration(
                        hintText: 'Designation',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Joining Date',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFFF1F5F9)
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _joiningDateController,
                      decoration: InputDecoration(
                        hintText: 'Select date',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: _pickJoiningDate,
                        ),
                      ),
                      readOnly: true,
                    ),
                  ],
                ),
              ] else
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Designation',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(0xFFF1F5F9)
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _designationController,
                            decoration: const InputDecoration(
                              hintText: 'Designation',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Joining Date',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(0xFFF1F5F9)
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _joiningDateController,
                            decoration: InputDecoration(
                              hintText: 'Select date',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_today),
                                onPressed: _pickJoiningDate,
                              ),
                            ),
                            readOnly: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Salary Structure',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFFF1F5F9)
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _salaryStructureController,
                    decoration: const InputDecoration(
                      hintText: 'Optional',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
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
