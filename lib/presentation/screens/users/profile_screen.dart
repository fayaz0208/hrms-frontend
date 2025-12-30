import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../state/providers/auth_provider.dart';
import '../../../state/providers/user_provider.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/status_badge.dart';

/// Screen for viewing and editing current user's profile
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditMode = false;
  bool _isChangingPassword = false;

  // Controllers
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentUser();
    });
  }

  Future<void> _loadCurrentUser() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.user;

    if (currentUser != null) {
      setState(() {
        _currentUser = currentUser;
        _firstNameController.text = currentUser.firstName;
        _lastNameController.text = currentUser.lastName ?? '';
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null && _currentUser != null) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final imageUrl = await userProvider.uploadProfilePicture(
        _currentUser!.id,
        image.path,
      );

      if (imageUrl != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadCurrentUser();
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_currentUser == null) return;

    final userData = {
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
    };

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.updateUser(_currentUser!.id, userData);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isEditMode = false);
        await _loadCurrentUser();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userProvider.error ?? 'Failed to update profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isChangingPassword = false;
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userProvider.error ?? 'Failed to change password'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditMode)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditMode = true),
              tooltip: 'Edit Profile',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          _currentUser!.fullName.isNotEmpty
                              ? _currentUser!.fullName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 48,
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: _pickProfileImage,
                            tooltip: 'Change Photo',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentUser!.fullName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentUser!.email,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  StatusBadge(isActive: !_currentUser!.inactive),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Edit Profile Section
            if (_isEditMode) ...[
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Edit Profile Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 24),
                        CustomTextField(
                          controller: _firstNameController,
                          label: 'First Name',
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _lastNameController,
                          label: 'Last Name',
                          isRequired: true,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _isEditMode = false;
                                  _firstNameController.text =
                                      _currentUser!.firstName;
                                  _lastNameController.text =
                                      _currentUser!.lastName ?? '';
                                });
                              },
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Save Changes'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Profile Information (Read-only)
            if (!_isEditMode) ...[
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Profile Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 24),
                      _buildInfoRow('First Name', _currentUser!.firstName),
                      _buildInfoRow('Last Name', _currentUser!.lastName),
                      _buildInfoRow('Email', _currentUser!.email),
                      _buildInfoRow('Role', _currentUser!.roleName),
                      _buildInfoRow('Department', _currentUser!.departmentName),
                      _buildInfoRow('Branch', _currentUser!.branchName),
                      _buildInfoRow('Designation', _currentUser!.designation),
                      _buildInfoRow('Joining Date', _currentUser!.joiningDate),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Change Password Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Change Password',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!_isChangingPassword)
                          TextButton(
                            onPressed: () =>
                                setState(() => _isChangingPassword = true),
                            child: const Text('Change'),
                          ),
                      ],
                    ),
                    if (_isChangingPassword) ...[
                      const Divider(height: 24),
                      Form(
                        key: _passwordFormKey,
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: _currentPasswordController,
                              label: 'Current Password',
                              isRequired: true,
                              obscureText: true,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _newPasswordController,
                              label: 'New Password',
                              isRequired: true,
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'New password is required';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirm Password',
                              isRequired: true,
                              obscureText: true,
                              validator: (value) {
                                if (value != _newPasswordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isChangingPassword = false;
                                      _currentPasswordController.clear();
                                      _newPasswordController.clear();
                                      _confirmPasswordController.clear();
                                    });
                                  },
                                  child: const Text('Cancel'),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: _changePassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Change Password'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
