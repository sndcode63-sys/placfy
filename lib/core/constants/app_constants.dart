class AppConstants {
  static const String appName = 'Placfy';
  static const String appTagline = 'Autonomous Payroll & AI Workforce Platform';

  // ==========================================
  // API BASE URLS & NETWORK CONFIGURATION
  // ==========================================
  static const String apiBaseUrl =
      'https://55c3-47-11-18-126.ngrok-free.app/api/v1';
  static const String apiLocalBaseUrl = 'http://127.0.0.1:8000/api/v1';
  static const String ngrokSkipHeader = 'ngrok-skip-browser-warning';
  static const String ngrokSkipHeaderValue = '69420';

  // Default Test Credentials
  static const String testEmail = 'employee@testing.com';
  static const String testPassword = 'Password123!';
  static const String testWorkspaceSlug = 'testing-workspace';
  static const int testEntityId = 5;

  // ==========================================
  // API ENDPOINTS
  // ==========================================

  // --- Auth Endpoints ---
  static const String authLogin = '/auth/login/';
  static const String authRefresh = '/auth/refresh/';
  static const String authLogout = '/auth/logout/';
  static const String authMe = '/auth/me/';
  static const String authProfile = '/profile/';

  // --- Workspace & Entity Endpoints ---
  static const String workspaces = '/workspaces/';
  static String workspaceDetail(String slug) => '/workspaces/$slug/';
  static String myEntities(String slug) => '/workspaces/$slug/my-entities/';
  static String entities(String slug) => '/workspaces/$slug/entities/';
  static String workspaceMembers(String slug) => '/workspaces/$slug/members/';
  static String workspaceBranches(String slug) => '/workspaces/$slug/branches/';

  // --- Attendance & Stop-Timer™ Endpoints ---
  static String attendanceToday(String slug) =>
      '/workspaces/$slug/attendance/employee/today/';
  static String attendanceLogs(String slug) =>
      '/workspaces/$slug/attendance/employee/logs/';
  static String attendanceSummary(String slug) =>
      '/workspaces/$slug/attendance/employee/summary/';
  static String attendanceCheckIn(String slug) =>
      '/workspaces/$slug/attendance/employee/check-in/';
  static String attendanceCheckOut(String slug) =>
      '/workspaces/$slug/attendance/employee/check-out/';
  static String attendanceBreakStart(String slug) =>
      '/workspaces/$slug/attendance/employee/break-start/';
  static String attendanceBreakEnd(String slug) =>
      '/workspaces/$slug/attendance/employee/break-end/';
  static String attendancePauseTimer(String slug) =>
      '/workspaces/$slug/attendance/employee/pause-timer/';
  static String attendanceResumeTimer(String slug) =>
      '/workspaces/$slug/attendance/employee/resume-timer/';
  static String attendanceRegularizations(String slug) =>
      '/workspaces/$slug/attendance/employee/regularizations/';
  static String attendanceRemoteWork(String slug) =>
      '/workspaces/$slug/attendance/employee/remote-work-requests/';

  // --- Leaves Endpoints ---
  static String leaveBalances(String slug) =>
      '/workspaces/$slug/leaves/employee/balances/';
  static String leaveRequests(String slug) =>
      '/workspaces/$slug/leaves/employee/requests/';
  static String leavePolicySummary(String slug) =>
      '/workspaces/$slug/leaves/employee/policy-summary/';
  static String leaveHolidays(String slug) =>
      '/workspaces/$slug/leaves/employee/holidays/';

  // --- Payroll Endpoints ---
  static String payrollRuns(String slug) => '/workspaces/$slug/payroll/runs/';
  static String payrollAdjustments(String slug) =>
      '/workspaces/$slug/payroll/adjustments/';
  static String payrollLoans(String slug) => '/workspaces/$slug/payroll/loans/';
  static String payrollWorkspace(String slug) =>
      '/workspaces/$slug/payroll-workspace/';

  // --- Dashboard & Reports Endpoints ---
  static const String workReportsToday =
      '/employee-dashboard/work-reports/today/';
  static const String workReportsHistory =
      '/employee-dashboard/work-reports/history/';
  static const String shiftPlanToday =
      '/employee-dashboard/shift-plan/today/';

  // --- Jobs & Recruitment Endpoints ---
  static String jobs(String slug) => '/workspaces/$slug/jobs/';
  static String customInterviews(String slug) =>
      '/workspaces/$slug/custom-interviews/';

  // Placfy Clouds info for Showcase
  static const List<Map<String, dynamic>> placfyClouds = [
    {
      'title': 'Autonomous Payroll Engine',
      'icon': 'payments',
      'color': 0xFF00D294,
      'badge': 'Gross-to-Net Rails',
      'description':
          'Instant journal entry synchronization, department expense allocation, statutory tax compliance (PF, ESI, TDS Sec 192), and direct banking rails.',
      'metrics': ['99.98% Accuracy', 'Zero Discrepancy', '1-Click Disbursement'],
    },
    {
      'title': 'Stop-Timer™ Biometrics',
      'icon': 'timer',
      'color': 0xFF00A5EF,
      'badge': '120m Geo-Fence',
      'description':
          'Sub-meter 120m office geo-fencing, anti-spoof biometric selfie check-in, real-time work session pause/resume, and tamper-proof audit trails.',
      'metrics': ['120m Precision', 'Face Hash ID', 'Auto Break Audit'],
    },
    {
      'title': 'AI Talent Screening & Video',
      'icon': 'psychology',
      'color': 0xFF8B5CF6,
      'badge': 'Proctored AI',
      'description':
          'Asynchronous video interviews with gaze tracking, candidate enrichment, automatic rubric evaluation, and automated multi-stage hiring pipelines.',
      'metrics': ['98.7% Proctor Score', '3x Faster Hiring', 'Rubric Calibrated'],
    },
    {
      'title': 'Core HR Master Directory',
      'icon': 'people_alt',
      'color': 0xFF3B82F6,
      'badge': 'Single DB Mesh',
      'description':
          'Unified relational schema for org hierarchies, leave workflows, appointment letters, digital NDA signing, and employee lifecycle management.',
      'metrics': ['Single Source of Truth', 'Zero API Lag', 'Role Governance'],
    },
    {
      'title': 'Smart Expense Management',
      'icon': 'receipt_long',
      'color': 0xFFF59E0B,
      'badge': 'OCR Extraction',
      'description':
          'AI-powered optical receipt reading, automated currency conversion, multi-tier manager approvals, and automatic payroll inclusion.',
      'metrics': ['Instant OCR', 'Auto-Matched GL', 'Policy Safeguard'],
    },
  ];

  // Integrations list from placfy.com
  static const List<Map<String, String>> integrations = [
    {'name': 'Oracle NetSuite', 'type': 'Bi-Directional GL Sync', 'tag': 'Certified'},
    {'name': 'Tally Prime / ERP 9', 'type': 'Indian Statutory XML', 'tag': 'Direct XML'},
    {'name': 'QuickBooks Online', 'type': 'OAuth 2.0 Expense Sync', 'tag': 'Daily Auto'},
    {'name': 'Okta Identity Cloud', 'type': 'SCIM 2.0 & SAML SSO', 'tag': 'Instant Sync'},
    {'name': 'Microsoft Entra ID', 'type': 'Active Directory Lifecycle', 'tag': 'SCIM 2.0'},
    {'name': 'HDFC / ICICI Bank', 'type': 'CMS Corporate Banking', 'tag': 'H2H SFTP'},
  ];
}
