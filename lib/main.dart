import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/routing/app_routes.dart';
import 'state/providers/auth_provider.dart';
import 'state/providers/user_provider.dart';
import 'state/providers/organization_provider.dart';
import 'state/providers/role_provider.dart';
import 'state/providers/recruitment_provider.dart';
import 'state/providers/theme_provider.dart';

// Auth screens
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';

// Dashboard
import 'presentation/screens/dashboard/dashboard_screen.dart';

// User Management screens
import 'presentation/screens/users/users_list_screen.dart';
import 'presentation/screens/users/user_detail_screen.dart';
// import 'presentation/screens/users/user_form_screen.dart'; // Now uses modal dialog
import 'presentation/screens/profile/profile_screen.dart';
import 'presentation/screens/users/assign_shift_screen.dart';

// Organization screens
import 'presentation/screens/organization/organizations_list_screen.dart';
import 'presentation/screens/organization/organization_detail_screen.dart';
// import 'presentation/screens/organization/organization_form_screen.dart'; // Now uses modal dialog
import 'presentation/screens/organization/branches_list_screen.dart';
// import 'presentation/screens/organization/branch_form_screen.dart'; // Now uses modal dialog
import 'presentation/screens/organization/departments_list_screen.dart';
// import 'presentation/screens/organization/department_form_screen.dart'; // Now uses modal dialog

// Roles & Permissions screens
import 'presentation/screens/roles/roles_list_screen.dart';
import 'presentation/screens/roles/permissions_screen.dart';

// Recruitment screens
import 'presentation/screens/recruitment/job_postings_list_screen.dart';
import 'presentation/screens/recruitment/candidates_list_screen.dart';
import 'presentation/screens/recruitment/candidate_documents_screen.dart';

// Common screens
import 'presentation/screens/common/coming_soon_screen.dart';
import 'presentation/screens/common/not_found_screen.dart';

void main() {
  // Disable overflow visual indicators in debug mode
  debugPaintSizeEnabled = false;

  // Suppress overflow error widgets
  ErrorWidget.builder = (FlutterErrorDetails details) {
    // Return an empty container instead of the error widget
    return Container();
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => OrganizationProvider()),
        ChangeNotifierProvider(create: (_) => RoleProvider()),
        ChangeNotifierProvider(create: (_) => RecruitmentProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'LMS & HRMS Platform',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AppInitializer(),
            routes: _buildRoutes(),
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const NotFoundScreen(),
              );
            },
          );
        },
      ),
    );
  }

  /// Build all application routes
  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      // Auth routes
      AppRoutes.login: (context) => const LoginScreen(),
      AppRoutes.register: (context) => const RegisterScreen(),

      // Dashboard
      AppRoutes.dashboard: (context) => const DashboardScreen(),

      // User Management
      AppRoutes.users: (context) => const UsersListScreen(),
      AppRoutes.userDetail: (context) {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final userId = args?['userId'] as int? ?? 0;
        return UserDetailScreen(userId: userId);
      },
      // AppRoutes.userForm: (context) => const UserFormScreen(), // Now uses modal dialog
      AppRoutes.userProfile: (context) => const ProfileScreen(),
      '/profile': (context) =>
          const ProfileScreen(), // Direct route for navigation
      AppRoutes.assignShift: (context) => const AssignShiftScreen(),
      AppRoutes.roles: (context) => const RolesListScreen(),
      AppRoutes.permissions: (context) => const PermissionsScreen(),

      // Organization Management
      AppRoutes.organizations: (context) => const OrganizationsListScreen(),
      AppRoutes.organizationDetail: (context) {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final organizationId = args?['organizationId'] as int? ?? 0;
        return OrganizationDetailScreen(organizationId: organizationId);
      },
      // AppRoutes.organizationForm: (context) => const OrganizationFormScreen(), // Now uses modal dialog
      AppRoutes.branches: (context) => const BranchesListScreen(),
      // AppRoutes.branchForm: (context) => const BranchFormScreen(), // Now uses modal dialog
      AppRoutes.departments: (context) => const DepartmentsListScreen(),
      // AppRoutes.departmentForm: (context) => const DepartmentFormScreen(), // Now uses modal dialog

      // LMS Module (Coming Soon)
      AppRoutes.courses: (context) =>
          const ComingSoonScreen(moduleName: 'Courses'),
      AppRoutes.courseDetail: (context) =>
          const ComingSoonScreen(moduleName: 'Course Details'),
      AppRoutes.courseForm: (context) =>
          const ComingSoonScreen(moduleName: 'Course Form'),
      AppRoutes.videos: (context) =>
          const ComingSoonScreen(moduleName: 'Videos'),
      AppRoutes.videoPlayer: (context) =>
          const ComingSoonScreen(moduleName: 'Video Player'),
      AppRoutes.videoForm: (context) =>
          const ComingSoonScreen(moduleName: 'Video Form'),
      AppRoutes.categories: (context) =>
          const ComingSoonScreen(moduleName: 'Categories'),
      AppRoutes.categoryForm: (context) =>
          const ComingSoonScreen(moduleName: 'Category Form'),
      AppRoutes.enrollments: (context) =>
          const ComingSoonScreen(moduleName: 'Enrollments'),
      AppRoutes.enrollmentDetail: (context) =>
          const ComingSoonScreen(moduleName: 'Enrollment Details'),
      AppRoutes.quizCheckpoints: (context) =>
          const ComingSoonScreen(moduleName: 'Quiz Checkpoints'),
      AppRoutes.quizHistory: (context) =>
          const ComingSoonScreen(moduleName: 'Quiz History'),
      AppRoutes.quizTake: (context) =>
          const ComingSoonScreen(moduleName: 'Take Quiz'),
      AppRoutes.progress: (context) =>
          const ComingSoonScreen(moduleName: 'Progress Tracking'),

      // HRMS Module (Coming Soon)
      AppRoutes.shifts: (context) =>
          const ComingSoonScreen(moduleName: 'Shifts'),
      AppRoutes.shiftForm: (context) =>
          const ComingSoonScreen(moduleName: 'Shift Form'),
      AppRoutes.userShifts: (context) =>
          const ComingSoonScreen(moduleName: 'User Shifts'),
      AppRoutes.shiftChangeRequests: (context) =>
          const ComingSoonScreen(moduleName: 'Shift Change Requests'),
      AppRoutes.attendance: (context) =>
          const ComingSoonScreen(moduleName: 'Attendance'),
      AppRoutes.attendanceMark: (context) =>
          const ComingSoonScreen(moduleName: 'Mark Attendance'),
      AppRoutes.leaveMaster: (context) =>
          const ComingSoonScreen(moduleName: 'Leave Master'),
      AppRoutes.leaveRequest: (context) =>
          const ComingSoonScreen(moduleName: 'Leave Request'),
      AppRoutes.hrmsPermissions: (context) =>
          const ComingSoonScreen(moduleName: 'HRMS Permissions'),
      AppRoutes.salaryStructure: (context) =>
          const ComingSoonScreen(moduleName: 'Salary Structure'),
      AppRoutes.formulas: (context) =>
          const ComingSoonScreen(moduleName: 'Formulas'),
      AppRoutes.payroll: (context) =>
          const ComingSoonScreen(moduleName: 'Payroll'),
      AppRoutes.payrollDetail: (context) =>
          const ComingSoonScreen(moduleName: 'Payroll Details'),
      AppRoutes.payrollAttendance: (context) =>
          const ComingSoonScreen(moduleName: 'Payroll Attendance'),
      AppRoutes.holidays: (context) =>
          const ComingSoonScreen(moduleName: 'Holidays'),

      // Hiring Module
      AppRoutes.jobPostings: (context) => const JobPostingsListScreen(),
      AppRoutes.jobPostingForm: (context) =>
          const ComingSoonScreen(moduleName: 'Job Posting Form'),
      AppRoutes.jobRoles: (context) =>
          const ComingSoonScreen(moduleName: 'Job Roles'),
      AppRoutes.workflows: (context) =>
          const ComingSoonScreen(moduleName: 'Workflows'),
      AppRoutes.candidates: (context) => const CandidatesListScreen(),
      AppRoutes.candidateDetail: (context) =>
          const ComingSoonScreen(moduleName: 'Candidate Details'),
      AppRoutes.candidateDocuments: (context) =>
          const CandidateDocumentsScreen(candidateId: 0, candidateName: ''),

      // Reports Module (Coming Soon)
      AppRoutes.reportsActiveUsers: (context) =>
          const ComingSoonScreen(moduleName: 'Active Users Report'),
      AppRoutes.reportsInactiveUsers: (context) =>
          const ComingSoonScreen(moduleName: 'Inactive Users Report'),
      AppRoutes.reportsDailyAttendance: (context) =>
          const ComingSoonScreen(moduleName: 'Daily Attendance Report'),
      AppRoutes.reportsMonthlyAttendance: (context) =>
          const ComingSoonScreen(moduleName: 'Monthly Attendance Report'),

      // Settings Module (Coming Soon)
      AppRoutes.settingsGeneral: (context) =>
          const ComingSoonScreen(moduleName: 'General Settings'),
      AppRoutes.settingsSystem: (context) =>
          const ComingSoonScreen(moduleName: 'System Settings'),

      // Menu Management (Coming Soon)
      AppRoutes.menus: (context) =>
          const ComingSoonScreen(moduleName: 'Menu Management'),
      AppRoutes.roleRights: (context) =>
          const ComingSoonScreen(moduleName: 'Role Rights'),

      // Common
      AppRoutes.comingSoon: (context) => const ComingSoonScreen(),
      AppRoutes.notFound: (context) => const NotFoundScreen(),
    };
  }
}

/// Initializes the app and handles authentication state
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    // Initialize auth state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthProvider>().initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        print(
          '🔍 Auth State: ${authProvider.state}, Authenticated: ${authProvider.isAuthenticated}',
        );

        // Show loading while initializing
        if (authProvider.state == AuthState.initial ||
            authProvider.state == AuthState.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Navigate based on auth state - check both state and isAuthenticated
        if (authProvider.isAuthenticated &&
            authProvider.state == AuthState.authenticated) {
          print('✅ User authenticated, showing Dashboard');
          return const DashboardScreen();
        } else {
          print('❌ User not authenticated, showing Login');
          return const LoginScreen();
        }
      },
    );
  }
}
