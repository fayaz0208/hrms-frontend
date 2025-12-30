import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/providers/recruitment_provider.dart';
import '../../../data/models/job_posting_model.dart';
import '../../widgets/form_dialog.dart';

/// Show job posting form as modal dialog
Future<bool?> showJobPostingFormDialog({
  required BuildContext context,
  JobPosting? jobPosting,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _JobPostingFormDialog(jobPosting: jobPosting),
  );
}

class _JobPostingFormDialog extends StatefulWidget {
  final JobPosting? jobPosting;

  const _JobPostingFormDialog({this.jobPosting});

  @override
  State<_JobPostingFormDialog> createState() => _JobPostingFormDialogState();
}

class _JobPostingFormDialogState extends State<_JobPostingFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _jobDescriptionIdController = TextEditingController();
  final _numberOfPositionsController = TextEditingController();
  final _employmentTypeController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();

  DateTime? _postingDate;
  DateTime? _closingDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.jobPosting != null) {
      _jobDescriptionIdController.text = widget.jobPosting!.jobDescriptionId
          .toString();
      _numberOfPositionsController.text = widget.jobPosting!.numberOfPositions
          .toString();
      _employmentTypeController.text = widget.jobPosting!.employmentType;
      _locationController.text = widget.jobPosting!.location;
      _salaryController.text = widget.jobPosting!.salary?.toString() ?? '';
      _postingDate = widget.jobPosting!.postingDate;
      _closingDate = widget.jobPosting!.closingDate;
    } else {
      _postingDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _jobDescriptionIdController.dispose();
    _numberOfPositionsController.dispose();
    _employmentTypeController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _pickPostingDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _postingDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() => _postingDate = date);
    }
  }

  Future<void> _pickClosingDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _closingDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() => _closingDate = date);
    }
  }

  Future<void> _saveJobPosting() async {
    if (!_formKey.currentState!.validate()) return;
    if (_postingDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a posting date'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final provider = Provider.of<RecruitmentProvider>(context, listen: false);

    // Validate and parse numeric fields
    int? jobDescriptionId;
    int? numberOfPositions;
    int? salary;

    try {
      jobDescriptionId = int.parse(_jobDescriptionIdController.text);
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job Description ID must be a valid number'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    try {
      numberOfPositions = int.parse(_numberOfPositionsController.text);
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Number of Positions must be a valid number'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (_salaryController.text.isNotEmpty) {
      try {
        salary = int.parse(_salaryController.text);
      } catch (e) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Salary must be a valid number'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }
    }

    final data = {
      'job_description_id': jobDescriptionId,
      'number_of_positions': numberOfPositions,
      'employment_type': _employmentTypeController.text.trim(),
      'location': _locationController.text.trim(),
      'salary': salary,
      'posting_date': _postingDate!.toIso8601String().split('T')[0],
      'closing_date': _closingDate?.toIso8601String().split('T')[0],
    };

    bool success;
    if (widget.jobPosting != null) {
      success = await provider.updateJobPosting(widget.jobPosting!.id, data);
    } else {
      success = await provider.createJobPosting(data);
    }

    setState(() => _isSaving = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.jobPosting != null
                  ? 'Job posting updated successfully'
                  : 'Job posting created successfully',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.jobPostingsError ?? 'Failed to save job posting',
            ),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormDialog(
      title: widget.jobPosting != null
          ? 'Edit Job Posting'
          : 'Create Job Posting',
      onSave: _saveJobPosting,
      isLoading: _isSaving,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _jobDescriptionIdController,
                decoration: const InputDecoration(
                  labelText: 'Job Description ID *',
                  border: OutlineInputBorder(),
                  hintText: 'Enter numeric ID',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Job description ID is required';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Must be a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _numberOfPositionsController,
                decoration: const InputDecoration(
                  labelText: 'Number of Positions *',
                  border: OutlineInputBorder(),
                  hintText: 'Enter number',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Number of positions is required';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Must be a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _employmentTypeController,
                decoration: const InputDecoration(
                  labelText: 'Employment Type *',
                  hintText: 'e.g., Full-time, Part-time, Contract',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Employment type is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Location is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _salaryController,
                decoration: const InputDecoration(
                  labelText: 'Salary (optional)',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickPostingDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Posting Date *',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _postingDate != null
                        ? DateFormat('yyyy-MM-dd').format(_postingDate!)
                        : 'Select date',
                    style: TextStyle(
                      color: _postingDate != null
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickClosingDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Closing Date (optional)',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _closingDate != null
                        ? DateFormat('yyyy-MM-dd').format(_closingDate!)
                        : 'Select date',
                    style: TextStyle(
                      color: _closingDate != null
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
