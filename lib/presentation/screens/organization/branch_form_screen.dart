import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/providers/organization_provider.dart';
import '../../../state/providers/auth_provider.dart';
import '../../../data/models/branch_model.dart';
import '../../widgets/form_dialog.dart';

/// Show branch form as modal dialog
Future<bool?> showBranchFormDialog({
  required BuildContext context,
  Branch? branch,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _BranchFormDialog(branch: branch),
  );
}

class _BranchFormDialog extends StatefulWidget {
  final Branch? branch;

  const _BranchFormDialog({this.branch});

  @override
  State<_BranchFormDialog> createState() => _BranchFormDialogState();
}

class _BranchFormDialogState extends State<_BranchFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _contactPersonController = TextEditingController();
  String _contactPhone = '';
  final _contactEmailController = TextEditingController();

  bool _isActive = true;
  int? _selectedOrganizationId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
    if (widget.branch != null) {
      _nameController.text = widget.branch!.name;
      _addressController.text = widget.branch!.address ?? '';
      _addressLine2Controller.text = widget.branch!.addressLine2 ?? '';
      _cityController.text = widget.branch!.city ?? '';
      _stateController.text = widget.branch!.state ?? '';
      _postalCodeController.text = widget.branch!.postalCode ?? '';
      _countryController.text = widget.branch!.country ?? '';
      _contactPersonController.text = widget.branch!.contactPerson ?? '';
      _contactPhone = widget.branch!.contactPhone ?? '';
      _contactEmailController.text = widget.branch!.contactEmail ?? '';
      _isActive = widget.branch!.isActive;
      _selectedOrganizationId = widget.branch!.organizationId;
    }
  }

  Future<void> _loadOrganizations() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orgProvider = Provider.of<OrganizationProvider>(
      context,
      listen: false,
    );

    await orgProvider.fetchOrganizations();

    // Auto-select organization for non-super-admin users
    if (authProvider.user?.organizationId != null && mounted) {
      setState(() {
        _selectedOrganizationId = authProvider.user!.organizationId;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _contactPersonController.dispose();
    // Phone is now a string
    _contactEmailController.dispose();
    super.dispose();
  }

  Future<void> _saveBranch() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedOrganizationId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an organization'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
      return;
    }

    setState(() => _isSaving = true);

    final data = {
      'name': _nameController.text,
      'organization_id': _selectedOrganizationId,
      'address': _addressController.text.isEmpty
          ? null
          : _addressController.text,
      'address_line2': _addressLine2Controller.text.isEmpty
          ? null
          : _addressLine2Controller.text,
      'city': _cityController.text.isEmpty ? null : _cityController.text,
      'state': _stateController.text.isEmpty ? null : _stateController.text,
      'postal_code': _postalCodeController.text.isEmpty
          ? null
          : _postalCodeController.text,
      'country': _countryController.text.isEmpty
          ? null
          : _countryController.text,
      'contact_person': _contactPersonController.text.isEmpty
          ? null
          : _contactPersonController.text,
      'contact_phone': _contactPhone.isEmpty ? null : _contactPhone,
      'contact_email': _contactEmailController.text.isEmpty
          ? null
          : _contactEmailController.text,
      'is_active': _isActive,
    };

    final provider = Provider.of<OrganizationProvider>(context, listen: false);
    bool success;

    if (widget.branch != null) {
      success = await provider.updateBranch(widget.branch!.id, data);
    } else {
      success = await provider.createBranch(data);
    }

    setState(() => _isSaving = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.branch != null
                  ? 'Branch updated successfully'
                  : 'Branch created successfully',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to save branch'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormDialog(
      title: widget.branch != null ? 'Edit Branch' : 'Create Branch',
      onSave: _saveBranch,
      isLoading: _isSaving,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Organization Dropdown (for super admin only)
              Consumer<OrganizationProvider>(
                builder: (context, orgProvider, _) {
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  final isSuperAdmin =
                      authProvider.user?.organizationId == null;

                  if (!isSuperAdmin) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DropdownButtonFormField<int>(
                      initialValue: _selectedOrganizationId,
                      decoration: const InputDecoration(
                        labelText: 'Organization *',
                        border: OutlineInputBorder(),
                      ),
                      items: orgProvider.organizations
                          .map(
                            (org) => DropdownMenuItem(
                              value: org.id,
                              child: Text(org.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedOrganizationId = value);
                      },
                      validator: (value) => value == null
                          ? 'Please select an organization'
                          : null,
                    ),
                  );
                },
              ),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Branch Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter branch name'
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address Line 1',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _addressLine2Controller,
                decoration: const InputDecoration(
                  labelText: 'Address Line 2',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(
                        labelText: 'State',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _postalCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Postal Code',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _countryController,
                      decoration: const InputDecoration(
                        labelText: 'Country',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _contactPersonController,
                decoration: const InputDecoration(
                  labelText: 'Contact Person',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              IntlPhoneField(
                decoration: const InputDecoration(
                  labelText: 'Contact Phone',
                  border: OutlineInputBorder(),
                ),
                initialCountryCode: 'IN',
                initialValue: widget.branch != null ? _contactPhone : null,
                onChanged: (phone) {
                  _contactPhone = phone.completeNumber;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _contactEmailController,
                decoration: const InputDecoration(
                  labelText: 'Contact Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              CheckboxListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value ?? true),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
