import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/providers/user_provider.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/custom_dropdown.dart';

/// Dialog for assigning shift to user or role
class AssignShiftScreen extends StatefulWidget {
  final User? user;

  const AssignShiftScreen({super.key, this.user});

  @override
  State<AssignShiftScreen> createState() => _AssignShiftScreenState();
}

class _AssignShiftScreenState extends State<AssignShiftScreen> {
  String _selectedMode = 'single'; // 'single' or 'bulk'
  int? _selectedUserId;
  int? _selectedRoleId;
  int? _selectedShiftId;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _selectedUserId = widget.user!.id;
    }
    _loadData();
  }

  Future<void> _loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await Future.wait([
      userProvider.fetchUsers(),
      userProvider.fetchRoles(),
      userProvider.fetchShifts(),
    ]);
  }

  Future<void> _assignShift() async {
    if (_selectedShiftId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a shift'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedMode == 'single' && _selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a user'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedMode == 'bulk' && _selectedRoleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a role'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    bool success;

    if (_selectedMode == 'single') {
      success = await userProvider.assignShiftToUser(
        _selectedUserId!,
        _selectedShiftId!,
      );
    } else {
      success = await userProvider.assignShiftToRole(
        _selectedRoleId!,
        _selectedShiftId!,
      );
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _selectedMode == 'single'
                  ? 'Shift assigned to user successfully'
                  : 'Shift assigned to all users in role successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userProvider.error ?? 'Failed to assign shift'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Shift'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode Selection
            Text(
              'Assignment Mode',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Single User'),
                    value: 'single',
                    groupValue: _selectedMode,
                    onChanged: widget.user != null
                        ? null
                        : (value) {
                            setState(() {
                              _selectedMode = value!;
                              _selectedUserId = null;
                              _selectedRoleId = null;
                            });
                          },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('All in Role'),
                    value: 'bulk',
                    groupValue: _selectedMode,
                    onChanged: widget.user != null
                        ? null
                        : (value) {
                            setState(() {
                              _selectedMode = value!;
                              _selectedUserId = null;
                              _selectedRoleId = null;
                            });
                          },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Selection based on mode
            if (_selectedMode == 'single') ...[
              Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  return CustomDropdown<int>(
                    label: 'Select User',
                    value: _selectedUserId,
                    isRequired: true,
                    enabled: widget.user == null,
                    items: userProvider.users.map((user) {
                      return DropdownMenuItem(
                        value: user.id,
                        child: Text('${user.fullName} (${user.email})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedUserId = value);
                    },
                  );
                },
              ),
            ] else ...[
              Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  return CustomDropdown<int>(
                    label: 'Select Role',
                    value: _selectedRoleId,
                    isRequired: true,
                    items: userProvider.roles.map((role) {
                      return DropdownMenuItem(
                        value: role.id,
                        child: Text(role.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedRoleId = value);
                    },
                  );
                },
              ),
            ],
            const SizedBox(height: 24),

            // Shift Selection
            Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                return CustomDropdown<int>(
                  label: 'Select Shift',
                  value: _selectedShiftId,
                  isRequired: true,
                  items: userProvider.shifts.map((shift) {
                    return DropdownMenuItem(
                      value: shift.id,
                      child: Text(
                        '${shift.name} (${shift.startTime ?? ''} - ${shift.endTime ?? ''})',
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedShiftId = value);
                  },
                );
              },
            ),
            const SizedBox(height: 32),

            // Info Message
            if (_selectedMode == 'bulk')
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'This will assign the selected shift to ALL users in the selected role.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                Consumer<UserProvider>(
                  builder: (context, userProvider, _) {
                    return ElevatedButton(
                      onPressed: userProvider.isLoading ? null : _assignShift,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: userProvider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Assign Shift'),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
