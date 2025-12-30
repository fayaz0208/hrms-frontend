/// Centralized route definitions for the application
class AppRoutes {
  // Auth routes
  static const String login = '/login';
  static const String register = '/register';

  // Dashboard
  static const String dashboard = '/dashboard';

  // User Management
  static const String users = '/users';
  static const String userDetail = '/users/detail';
  static const String userForm = '/users/form';
  static const String userProfile = '/users/profile';
  static const String assignShift = '/users/assign-shift';
  static const String roles = '/roles';
  static const String permissions = '/permissions';

  // Organization Management
  static const String organizations = '/organizations';
  static const String organizationDetail = '/organizations/detail';
  static const String organizationForm = '/organizations/form';
  static const String branches = '/branches';
  static const String branchForm = '/branches/form';
  static const String departments = '/departments';
  static const String departmentForm = '/departments/form';

  // LMS Module
  static const String courses = '/courses';
  static const String courseDetail = '/courses/detail';
  static const String courseForm = '/courses/form';
  static const String videos = '/videos';
  static const String videoPlayer = '/videos/player';
  static const String videoForm = '/videos/form';
  static const String categories = '/categories';
  static const String categoryForm = '/categories/form';
  static const String enrollments = '/enrollments';
  static const String enrollmentDetail = '/enrollments/detail';
  static const String quizCheckpoints = '/quiz-checkpoints';
  static const String quizHistory = '/quiz-history';
  static const String quizTake = '/quiz/take';
  static const String progress = '/progress';

  // HRMS Module
  static const String shifts = '/shifts';
  static const String shiftForm = '/shifts/form';
  static const String userShifts = '/user-shifts';
  static const String shiftChangeRequests = '/shift-change-requests';
  static const String attendance = '/attendance';
  static const String attendanceMark = '/attendance/mark';
  static const String leaveMaster = '/leave-master';
  static const String leaveRequest = '/leave-request';
  static const String hrmsPermissions = '/hrms-permissions';
  static const String salaryStructure = '/salary-structure';
  static const String formulas = '/formulas';
  static const String payroll = '/payroll';
  static const String payrollDetail = '/payroll/detail';
  static const String payrollAttendance = '/payroll-attendance';
  static const String holidays = '/holidays';

  // Hiring Module
  static const String jobPostings = '/job-postings';
  static const String jobPostingForm = '/job-postings/form';
  static const String jobRoles = '/job-roles';
  static const String workflows = '/workflows';
  static const String candidates = '/candidates';
  static const String candidateDetail = '/candidates/detail';
  static const String candidateDocuments = '/candidate-documents';

  // Reports Module
  static const String reportsActiveUsers = '/reports/users/active';
  static const String reportsInactiveUsers = '/reports/users/inactive';
  static const String reportsDailyAttendance = '/reports/attendance/daily';
  static const String reportsMonthlyAttendance = '/reports/attendance/monthly';

  // Settings Module
  static const String settingsGeneral = '/settings/general';
  static const String settingsSystem = '/settings/system';

  // Menu Management
  static const String menus = '/menus';
  static const String roleRights = '/role-rights';

  // Common
  static const String comingSoon = '/coming-soon';
  static const String notFound = '/404';
}
