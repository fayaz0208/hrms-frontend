import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../state/providers/theme_provider.dart';
import '../../state/providers/auth_provider.dart';

/// Main layout with persistent sidebar
class MainLayout extends StatefulWidget {
  final Widget child;
  final String title;

  const MainLayout({super.key, required this.child, this.title = 'Dashboard'});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final Map<String, bool> _expandedSections = {
    'Users': false,
    'Organization': false,
    'Recruitment': false,
    'HRMS': false,
    'Payroll': false,
    'Learning': false,
  };

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      key: _scaffoldKey,
      // Drawer for mobile
      drawer: isMobile ? _buildDrawer(context) : null,
      body: SafeArea(
        child: Row(
          children: [
            // Persistent Sidebar for web/desktop
            if (!isMobile) _buildSidebar(context),

            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  // Top Bar
                  Container(
                    height: 64,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : 24,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E293B)
                          : Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF334155)
                              : AppColors.border,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Hamburger menu for mobile
                        if (isMobile)
                          IconButton(
                            icon: const Icon(Icons.menu),
                            onPressed: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                          ),
                        if (isMobile) const SizedBox(width: 8),

                        // Search Bar
                        Expanded(
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(0xFF0F172A)
                                  : AppColors.bgLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  size: 20,
                                  color: AppColors.textMuted,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Search anything...',
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Theme Toggle Icon
                        Consumer<ThemeProvider>(
                          builder: (context, themeProvider, _) {
                            return IconButton(
                              icon: Icon(
                                themeProvider.isDarkMode
                                    ? Icons.light_mode_outlined
                                    : Icons.dark_mode_outlined,
                              ),
                              onPressed: () => themeProvider.toggleTheme(),
                              tooltip: themeProvider.isDarkMode
                                  ? 'Switch to Light Mode'
                                  : 'Switch to Dark Mode',
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                            );
                          },
                        ),
                        if (!isMobile) ...[
                          IconButton(
                            icon: const Icon(Icons.help_outline),
                            onPressed: () {},
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                          ),
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_outlined),
                                onPressed: () {},
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(),
                              ),
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.danger,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(width: 4),
                        // User Profile with Dropdown
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            final user = authProvider.user;
                            final userName = user?.fullName ?? 'User';
                            final userRole = user?.roleName ?? 'Role';

                            return PopupMenuButton<String>(
                              offset: const Offset(0, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFF0F172A)
                                      : AppColors.bgLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: AppColors.primary,
                                      child: Text(
                                        getInitials(userName),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (!isMobile) ...[
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              userName,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            Text(
                                              userRole,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color:
                                                    Theme.of(
                                                          context,
                                                        ).brightness ==
                                                        Brightness.dark
                                                    ? const Color(0xFF94A3B8)
                                                    : AppColors.textMuted,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 18,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? const Color(0xFF94A3B8)
                                            : AppColors.textMuted,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              itemBuilder: (context) => [
                                PopupMenuItem<String>(
                                  value: 'profile',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.person_outline,
                                        size: 20,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? const Color(0xFFE2E8F0)
                                            : AppColors.textPrimary,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Profile',
                                        style: TextStyle(
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? const Color(0xFFE2E8F0)
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem<String>(
                                  value: 'settings',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.settings_outlined,
                                        size: 20,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? const Color(0xFFE2E8F0)
                                            : AppColors.textPrimary,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Settings',
                                        style: TextStyle(
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? const Color(0xFFE2E8F0)
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const PopupMenuDivider(),
                                PopupMenuItem<String>(
                                  value: 'logout',
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.logout,
                                        size: 20,
                                        color: AppColors.danger,
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Logout',
                                        style: TextStyle(
                                          color: AppColors.danger,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) async {
                                switch (value) {
                                  case 'profile':
                                    Navigator.pushNamed(context, '/profile');
                                    break;
                                  case 'settings':
                                    Navigator.pushNamed(context, '/settings');
                                    break;
                                  case 'logout':
                                    await authProvider.logout();
                                    if (context.mounted) {
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        '/login',
                                        (route) => false,
                                      );
                                    }
                                    break;
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: Container(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF0F172A)
                          : AppColors.bgLight,
                      child: widget.child,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E293B)
            : Colors.white,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF334155)
                : AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: _buildMenuContent(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E293B)
            : Colors.white,
        child: _buildMenuContent(context),
      ),
    );
  }

  Widget _buildMenuContent(BuildContext context) {
    return Column(
      children: [
        // HRMS Logo and Text
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.business_center,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'HRMS',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFFF1F5F9)
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Menu Items
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _MenuItem(
                icon: Icons.dashboard,
                label: 'Dashboard',
                isActive: widget.title == 'Dashboard',
                onTap: () => Navigator.pushNamed(context, '/dashboard'),
              ),
              _MenuSection(
                icon: Icons.people,
                label: 'Users',
                isExpanded: _expandedSections['Users']!,
                onToggle: () {
                  setState(() {
                    _expandedSections['Users'] = !_expandedSections['Users']!;
                  });
                },
                children: [
                  _SubMenuItem(
                    label: 'User Management',
                    onTap: () => Navigator.pushNamed(context, '/users'),
                  ),
                  _SubMenuItem(
                    label: 'Roles & Permissions',
                    onTap: () => Navigator.pushNamed(context, '/roles'),
                  ),
                ],
              ),
              _MenuSection(
                icon: Icons.business,
                label: 'Organization',
                isExpanded: _expandedSections['Organization']!,
                onToggle: () {
                  setState(() {
                    _expandedSections['Organization'] =
                        !_expandedSections['Organization']!;
                  });
                },
                children: [
                  _SubMenuItem(
                    label: 'Organizations',
                    onTap: () => Navigator.pushNamed(context, '/organizations'),
                  ),
                  _SubMenuItem(
                    label: 'Departments',
                    onTap: () => Navigator.pushNamed(context, '/departments'),
                  ),
                  _SubMenuItem(
                    label: 'Branches',
                    onTap: () => Navigator.pushNamed(context, '/branches'),
                  ),
                ],
              ),
              _MenuSection(
                icon: Icons.work_outline,
                label: 'Recruitment',
                isExpanded: _expandedSections['Recruitment']!,
                onToggle: () {
                  setState(() {
                    _expandedSections['Recruitment'] =
                        !_expandedSections['Recruitment']!;
                  });
                },
                children: [
                  _SubMenuItem(
                    label: 'Job Postings',
                    onTap: () => Navigator.pushNamed(context, '/job-postings'),
                  ),
                  _SubMenuItem(
                    label: 'Candidates',
                    onTap: () => Navigator.pushNamed(context, '/candidates'),
                  ),
                ],
              ),
              _MenuSection(
                icon: Icons.work,
                label: 'HRMS',
                isExpanded: _expandedSections['HRMS']!,
                onToggle: () {
                  setState(() {
                    _expandedSections['HRMS'] = !_expandedSections['HRMS']!;
                  });
                },
                children: [
                  _SubMenuItem(label: 'Attendance', onTap: () {}),
                  _SubMenuItem(label: 'Leave Management', onTap: () {}),
                  _SubMenuItem(label: 'Shift Management', onTap: () {}),
                ],
              ),
              _MenuSection(
                icon: Icons.attach_money,
                label: 'Payroll',
                isExpanded: _expandedSections['Payroll']!,
                onToggle: () {
                  setState(() {
                    _expandedSections['Payroll'] =
                        !_expandedSections['Payroll']!;
                  });
                },
                children: [
                  _SubMenuItem(label: 'Salary Structure', onTap: () {}),
                  _SubMenuItem(label: 'Payslips', onTap: () {}),
                  _SubMenuItem(label: 'Payroll Dashboard', onTap: () {}),
                ],
              ),
              _MenuSection(
                icon: Icons.school,
                label: 'Learning',
                isExpanded: _expandedSections['Learning']!,
                onToggle: () {
                  setState(() {
                    _expandedSections['Learning'] =
                        !_expandedSections['Learning']!;
                  });
                },
                children: [
                  _SubMenuItem(label: 'Courses', onTap: () {}),
                  _SubMenuItem(label: 'Enrollment', onTap: () {}),
                  _SubMenuItem(label: 'Quizzes', onTap: () {}),
                ],
              ),
              _MenuItem(
                icon: Icons.build,
                label: 'Workflow Builder',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.notifications,
                label: 'Notifications',
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isActive ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive
                      ? Colors.white
                      : isDark
                      ? const Color(0xFF94A3B8)
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isActive
                          ? Colors.white
                          : isDark
                          ? const Color(0xFFE2E8F0)
                          : AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<Widget> children;

  const _MenuSection({
    required this.icon,
    required this.label,
    required this.isExpanded,
    required this.onToggle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? const Color(0xFFE2E8F0)
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: isDark
                        ? const Color(0xFF64748B)
                        : AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isExpanded) ...children,
      ],
    );
  }
}

class _SubMenuItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SubMenuItem({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 24,
            right: 12,
            top: 8,
            bottom: 8,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}
