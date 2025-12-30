import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/providers/role_provider.dart';
import '../../../data/models/role_model.dart';
import '../../widgets/form_dialog.dart';

/// Show role form as a modal dialog
Future<bool?> showRoleFormDialog({required BuildContext context, Role? role}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _RoleFormDialog(role: role),
  );
}

class _RoleFormDialog extends StatefulWidget {
  final Role? role;

  const _RoleFormDialog({this.role});

  @override
  State<_RoleFormDialog> createState() => _RoleFormDialogState();
}

class _RoleFormDialogState extends State<_RoleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.role != null;
    _nameController = TextEditingController(text: widget.role?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.role?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveRole() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final roleData = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    };

    final roleProvider = Provider.of<RoleProvider>(context, listen: false);
    bool success;

    if (_isEdit) {
      success = await roleProvider.updateRole(widget.role!.id, roleData);
    } else {
      success = await roleProvider.createRole(roleData);
    }

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(roleProvider.rolesError ?? 'Failed to save role'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormDialog(
      title: _isEdit ? 'Edit Role' : 'Create Role',
      isLoading: _isLoading,
      onSave: _saveRole,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Field
            RichText(
              text: TextSpan(
                text: 'Role Name',
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
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'e.g., Manager, Supervisor',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Role name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description Field
            Text(
              'Description',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFFF1F5F9)
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Brief description of the role',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
