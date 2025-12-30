import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/providers/organization_provider.dart';
import '../../../state/providers/user_provider.dart';
import '../../../data/models/department_model.dart';
import '../../widgets/form_dialog.dart';

/// Show department form as modal dialog
Future<bool?> showDepartmentFormDialog({
  required BuildContext context,
  Department? department,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _DepartmentFormDialog(department: department),
  );
}

class _DepartmentFormDialog extends StatefulWidget {
  final Department? department;

  const _DepartmentFormDialog({this.department});

  @override
  State<_DepartmentFormDialog> createState() => _DepartmentFormDialogState();
}

class _DepartmentFormDialogState extends State<_DepartmentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();

  int? _selectedBranchId;
  int? _selectedManagerId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.department != null) {
      _nameController.text = widget.department!.name;
      _codeController.text = widget.department!.code ?? '';
      _descriptionController.text = widget.department!.description ?? '';
      _selectedBranchId = widget.department!.branchId;
      _selectedManagerId = widget.department!.managerId;
    }
  }

  Future<void> _loadData() async {
    final orgProvider = Provider.of<OrganizationProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    await Future.wait([orgProvider.fetchBranches(), userProvider.fetchUsers()]);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveDepartment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final data = {
      'name': _nameController.text,
      'code': _codeController.text.isEmpty ? null : _codeController.text,
      'branch_id': _selectedBranchId,
      'manager_id': _selectedManagerId,
      'description': _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
    };

    final provider = Provider.of<OrganizationProvider>(context, listen: false);
    bool success;

    if (widget.department != null) {
      success = await provider.updateDepartment(widget.department!.id, data);
    } else {
      success = await provider.createDepartment(data);
    }

    setState(() => _isSaving = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.department != null
                  ? 'Department updated successfully'
                  : 'Department created successfully',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to save department'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormDialog(
      title: widget.department != null
          ? 'Edit Department'
          : 'Create Department',
      onSave: _saveDepartment,
      isLoading: _isSaving,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Department Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter department name'
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Department Code',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              Consumer<OrganizationProvider>(
                builder: (context, orgProvider, _) {
                  return DropdownButtonFormField<int>(
                    initialValue: _selectedBranchId,
                    decoration: const InputDecoration(
                      labelText: 'Branch *',
                      border: OutlineInputBorder(),
                    ),
                    items: orgProvider.branches
                        .map(
                          (branch) => DropdownMenuItem(
                            value: branch.id,
                            child: Text(branch.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedBranchId = value);
                    },
                    validator: (value) =>
                        value == null ? 'Please select a branch' : null,
                  );
                },
              ),
              const SizedBox(height: 16),

              Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  return DropdownButtonFormField<int>(
                    initialValue: _selectedManagerId,
                    decoration: const InputDecoration(
                      labelText: 'Manager',
                      border: OutlineInputBorder(),
                    ),
                    items: userProvider.users
                        .map(
                          (user) => DropdownMenuItem(
                            value: user.id,
                            child: Text(user.fullName),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedManagerId = value);
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
