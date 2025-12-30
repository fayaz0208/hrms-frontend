import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/providers/organization_provider.dart';
import '../../../data/models/organization_model.dart';
import '../../../data/models/subscription_plan_model.dart';
import '../../../data/services/subscription_plan_service.dart';
import '../../widgets/form_dialog.dart';
import '../../widgets/form_components.dart';

/// Show organization form as modal dialog
Future<bool?> showOrganizationFormDialog({
  required BuildContext context,
  Organization? organization,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _OrganizationFormDialog(organization: organization),
  );
}

class _OrganizationFormDialog extends StatefulWidget {
  final Organization? organization;

  const _OrganizationFormDialog({this.organization});

  @override
  State<_OrganizationFormDialog> createState() =>
      _OrganizationFormDialogState();
}

class _OrganizationFormDialogState extends State<_OrganizationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactEmailController = TextEditingController();
  String _contactPhone = '';
  final _userLimitController = TextEditingController();
  final _branchLimitController = TextEditingController();
  final _storageLimitController = TextEditingController();

  final SubscriptionPlanService _planService = SubscriptionPlanService();

  int? _selectedPlanId;
  bool _isActive = true;
  bool _isLoadingPlans = true;
  bool _isSaving = false;
  List<SubscriptionPlan> _plans = [];
  SubscriptionPlan? _selectedPlan;

  @override
  void initState() {
    super.initState();
    _loadPlans();

    if (widget.organization != null) {
      _nameController.text = widget.organization!.name;
      _descriptionController.text = widget.organization!.description ?? '';
      _contactEmailController.text = widget.organization!.contactEmail;
      _contactPhone = widget.organization!.contactPhone ?? '';
      _selectedPlanId = widget.organization!.planId;
      _userLimitController.text =
          widget.organization!.userLimit?.toString() ?? '';
      _branchLimitController.text =
          widget.organization!.branchLimit?.toString() ?? '';
      _storageLimitController.text =
          widget.organization!.storageLimit?.toString() ?? '';
      _isActive = widget.organization!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _contactEmailController.dispose();
    // Phone is now a string, no controller to dispose
    _userLimitController.dispose();
    _branchLimitController.dispose();
    _storageLimitController.dispose();
    super.dispose();
  }

  Future<void> _loadPlans() async {
    try {
      final plans = await _planService.getSubscriptionPlans();
      if (mounted) {
        setState(() {
          _plans = plans;
          _isLoadingPlans = false;

          if (_selectedPlanId != null) {
            _selectedPlan = _plans.firstWhere(
              (p) => p.id == _selectedPlanId,
              orElse: () => _plans.first,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingPlans = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load plans: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _onPlanSelected(int? planId) {
    if (planId == null) return;

    final plan = _plans.firstWhere((p) => p.id == planId);
    setState(() {
      _selectedPlanId = planId;
      _selectedPlan = plan;

      _userLimitController.text = plan.userLimit.toString();
      _branchLimitController.text = plan.branchLimit.toString();
      _storageLimitController.text = (plan.storageLimitMb ~/ 1024).toString();
    });
  }

  Future<void> _saveOrganization() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final data = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'contact_email': _contactEmailController.text.trim(),
      'contact_phone': _contactPhone.isEmpty ? null : _contactPhone,
      'plan_id': _selectedPlanId,
      'user_limit': int.tryParse(_userLimitController.text),
      'branch_limit': int.tryParse(_branchLimitController.text),
      'storage_limit': int.tryParse(_storageLimitController.text),
      'is_active': _isActive,
    };

    final provider = Provider.of<OrganizationProvider>(context, listen: false);
    final success = widget.organization == null
        ? await provider.createOrganization(data)
        : await provider.updateOrganization(widget.organization!.id, data);

    if (mounted) {
      setState(() => _isSaving = false);

      if (success) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.organization == null
                  ? 'Organization created successfully'
                  : 'Organization updated successfully',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to save organization'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormDialog(
      title: widget.organization == null
          ? 'Add New Organization'
          : 'Edit Organization',
      isLoading: _isSaving,
      onSave: _saveOrganization,
      saveButtonText: widget.organization == null
          ? 'Create Organization'
          : 'Save Changes',
      child: _isLoadingPlans
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormFieldWithLabel(
                    label: 'Organization Name',
                    required: true,
                    child: StyledTextField(
                      controller: _nameController,
                      hintText: 'E.g., Acme Corporation',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Organization name is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormFieldWithLabel(
                    label: 'Description',
                    child: StyledTextField(
                      controller: _descriptionController,
                      hintText: 'Brief description',
                      maxLines: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormFieldWithLabel(
                    label: 'Contact Email',
                    required: true,
                    child: StyledTextField(
                      controller: _contactEmailController,
                      hintText: 'contact@example.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Contact email is required';
                        }
                        if (!value.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormFieldWithLabel(
                    label: 'Contact Phone',
                    child: IntlPhoneField(
                      decoration: const InputDecoration(
                        hintText: 'Phone number',
                        border: OutlineInputBorder(),
                      ),
                      initialCountryCode: 'IN',
                      initialValue: widget.organization != null
                          ? _contactPhone
                          : null,
                      onChanged: (phone) {
                        _contactPhone = phone.completeNumber;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  FormFieldWithLabel(
                    label: 'Subscription Plan',
                    required: true,
                    child: StyledDropdown<int>(
                      value: _selectedPlanId,
                      hintText: 'Select a plan',
                      items: _plans
                          .map(
                            (plan) => DropdownMenuItem(
                              value: plan.id,
                              child: Text(plan.name),
                            ),
                          )
                          .toList(),
                      onChanged: _onPlanSelected,
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a subscription plan';
                        }
                        return null;
                      },
                    ),
                  ),
                  if (_selectedPlan != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedPlan!.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedPlan!.description ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _PlanFeature(
                                'Users',
                                _selectedPlan!.userLimit.toString(),
                              ),
                              const SizedBox(width: 16),
                              _PlanFeature(
                                'Branches',
                                _selectedPlan!.branchLimit.toString(),
                              ),
                              const SizedBox(width: 16),
                              _PlanFeature(
                                'Storage',
                                '${_selectedPlan!.storageLimitMb ~/ 1024} GB',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    'Custom Limits (Optional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFFF1F5F9)
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FormFieldWithLabel(
                          label: 'User Limit',
                          child: StyledTextField(
                            controller: _userLimitController,
                            hintText: '100',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FormFieldWithLabel(
                          label: 'Branch Limit',
                          child: StyledTextField(
                            controller: _branchLimitController,
                            hintText: '20',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FormFieldWithLabel(
                    label: 'Storage Limit (GB)',
                    child: StyledTextField(
                      controller: _storageLimitController,
                      hintText: '10',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Checkbox(
                        value: _isActive,
                        onChanged: (value) {
                          setState(() => _isActive = value ?? true);
                        },
                        activeColor: AppColors.primary,
                      ),
                      const Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class _PlanFeature extends StatelessWidget {
  final String label;
  final String value;

  const _PlanFeature(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFFF1F5F9)
                : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
