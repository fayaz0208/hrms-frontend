import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/providers/recruitment_provider.dart';
import '../../../data/models/candidate_model.dart';
import '../../widgets/form_dialog.dart';

/// Show candidate form as modal dialog
Future<bool?> showCandidateFormDialog({
  required BuildContext context,
  Candidate? candidate,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _CandidateFormDialog(candidate: candidate),
  );
}

class _CandidateFormDialog extends StatefulWidget {
  final Candidate? candidate;

  const _CandidateFormDialog({this.candidate});

  @override
  State<_CandidateFormDialog> createState() => _CandidateFormDialogState();
}

class _CandidateFormDialogState extends State<_CandidateFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  String _phoneNumber = '';
  final _jobPostingIdController = TextEditingController();

  String _status = 'Pending';
  String? _selectedFilePath;
  String? _selectedFileName;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.candidate != null) {
      _firstNameController.text = widget.candidate!.firstName;
      _lastNameController.text = widget.candidate!.lastName;
      _emailController.text = widget.candidate!.email;
      _phoneNumber = widget.candidate!.phoneNumber;
      _jobPostingIdController.text = widget.candidate!.jobPostingId.toString();
      _status = widget.candidate!.status;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    // Phone number is now a string, no controller to dispose
    _jobPostingIdController.dispose();
    super.dispose();
  }

  Future<void> _pickResumeFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        setState(() {
          _selectedFilePath = result.files.single.path;
          _selectedFileName = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _saveCandidate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = Provider.of<RecruitmentProvider>(context, listen: false);
    final data = {
      'job_posting_id': int.parse(_jobPostingIdController.text),
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone_number': _phoneNumber,
      'status': _status,
    };

    bool success;
    int? candidateId;

    if (widget.candidate != null) {
      success = await provider.updateCandidate(widget.candidate!.id, data);
      candidateId = widget.candidate!.id;
    } else {
      success = await provider.createCandidate(data);
      // Get the newly created candidate ID from the provider
      if (success && provider.candidates.isNotEmpty) {
        candidateId = provider.candidates.last.id;
      }
    }

    // Upload resume if file was selected
    if (success && _selectedFilePath != null && candidateId != null) {
      final resumeUrl = await provider.uploadResume(
        candidateId,
        _selectedFilePath!,
      );
      if (resumeUrl == null) {
        success = false;
      }
    }

    setState(() => _isSaving = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.candidate != null
                  ? 'Candidate updated successfully'
                  : 'Candidate created successfully',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.candidatesError ?? 'Failed to save candidate',
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
      title: widget.candidate != null ? 'Edit Candidate' : 'Add Candidate',
      onSave: _saveCandidate,
      isLoading: _isSaving,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'First name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Last name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              IntlPhoneField(
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  border: OutlineInputBorder(),
                ),
                initialCountryCode: 'IN', // Default to India
                initialValue: widget.candidate != null ? _phoneNumber : null,
                onChanged: (phone) {
                  _phoneNumber = phone.completeNumber;
                },
                validator: (phone) {
                  if (phone == null || phone.number.isEmpty) {
                    return 'Phone number is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jobPostingIdController,
                decoration: const InputDecoration(
                  labelText: 'Job Posting ID *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Job posting ID is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items:
                    [
                          'Pending',
                          'Shortlisted',
                          'Interviewed',
                          'Hired',
                          'Rejected',
                        ]
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _status = value);
                  }
                },
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Resume Upload',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickResumeFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Select Resume File'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(double.infinity, 0),
                ),
              ),
              if (_selectedFileName != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Selected: $_selectedFileName',
                          style: const TextStyle(color: AppColors.success),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          setState(() {
                            _selectedFilePath = null;
                            _selectedFileName = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              const Text(
                'Allowed formats: PDF, DOC, DOCX',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              Consumer<RecruitmentProvider>(
                builder: (context, provider, _) {
                  if (provider.isUploading) {
                    return Column(
                      children: [
                        LinearProgressIndicator(value: provider.uploadProgress),
                        const SizedBox(height: 8),
                        Text(
                          'Uploading... ${(provider.uploadProgress * 100).toInt()}%',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
