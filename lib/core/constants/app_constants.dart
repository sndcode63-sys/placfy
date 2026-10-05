import '../../models/employee_model.dart';
import '../../models/leave_request_model.dart';
import '../../models/payslip_model.dart';
import '../../models/candidate_model.dart';

class AppConstants {
  static const String appName = 'Placfy';
  static const String appTagline = 'Autonomous Payroll & AI Workforce Platform';

  // ==========================================
  // API BASE URLS & NETWORK CONFIGURATION
  // ==========================================
  static const String apiBaseUrl =
      'https://885f-2409-40c2-11e-446c-b944-f7c6-dfd7-29aa.ngrok-free.app/api/v1';
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

  // Current Logged-in Employee (Default)
  static const EmployeeModel currentEmployee = EmployeeModel(
    id: 'EMP-9024',
    fullName: 'Aditya Sharma',
    role: 'Lead AI Engineer',
    department: 'Core Platform & AI Mesh',
    email: 'aditya.sharma@placfy.com',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    workspaceSlug: 'placfy-technologies',
    isInsideOfficeGeoFence: true,
    officeDistanceMeters: 28.5,
  );

  // Initial Attendance Records
  static const List<AttendanceRecord> initialAttendanceLogs = [
    AttendanceRecord(
      date: 'Today, Sep 17',
      punchInTime: '09:12 AM',
      punchOutTime: null,
      totalWorkSeconds: 20538, // 5h 42m
      status: 'Present',
      geoVerified: true,
    ),
    AttendanceRecord(
      date: 'Yesterday, Sep 16',
      punchInTime: '09:05 AM',
      punchOutTime: '06:34 PM',
      totalWorkSeconds: 31200, // 8h 40m
      status: 'Present',
      geoVerified: true,
    ),
    AttendanceRecord(
      date: 'Monday, Sep 15',
      punchInTime: '09:20 AM',
      punchOutTime: '06:15 PM',
      totalWorkSeconds: 29700, // 8h 15m
      status: 'Present',
      geoVerified: true,
    ),
    AttendanceRecord(
      date: 'Friday, Sep 12',
      punchInTime: '10:00 AM',
      punchOutTime: '07:10 PM',
      totalWorkSeconds: 30600, // 8h 30m
      status: 'Remote',
      geoVerified: false,
    ),
  ];

  // Initial Leave Balances
  static const List<LeaveBalanceModel> initialLeaveBalances = [
    LeaveBalanceModel(
      leaveType: 'Earned Leave',
      totalAllocated: 18.0,
      used: 6.0,
      remaining: 12.0,
    ),
    LeaveBalanceModel(
      leaveType: 'Casual Leave',
      totalAllocated: 12.0,
      used: 4.0,
      remaining: 8.0,
    ),
    LeaveBalanceModel(
      leaveType: 'Sick Leave',
      totalAllocated: 10.0,
      used: 2.0,
      remaining: 8.0,
    ),
  ];

  // Initial Leave Requests
  static final List<LeaveRequestModel> initialLeaveRequests = [
    LeaveRequestModel(
      id: 'LR-104',
      leaveType: 'Earned Leave',
      startDate: DateTime(2026, 9, 25),
      endDate: DateTime(2026, 9, 27),
      daysCount: 3.0,
      reason: 'Attending AI & Systems Engineering Summit',
      status: LeaveStatus.approved,
      approvedBy: 'Kunal Patel (VP Engineering)',
    ),
    LeaveRequestModel(
      id: 'LR-105',
      leaveType: 'Casual Leave',
      startDate: DateTime(2026, 10, 2),
      endDate: DateTime(2026, 10, 2),
      daysCount: 1.0,
      reason: 'Personal errands',
      status: LeaveStatus.pending,
    ),
  ];

  // Initial Payslips
  static const List<PayslipModel> initialPayslips = [
    PayslipModel(
      id: 'PAY-2026-08',
      monthYear: 'August 2026',
      basicSalary: 120000.0,
      hra: 48000.0,
      specialAllowance: 32000.0,
      performanceBonus: 15000.0,
      providentFund: 14400.0,
      esi: 1500.0,
      professionalTax: 200.0,
      incomeTaxTds: 18500.0,
      paymentDate: '31 Aug 2026',
      transactionId: 'TXN-94829104',
      currency: 'INR',
      status: 'Disbursed',
    ),
    PayslipModel(
      id: 'PAY-2026-07',
      monthYear: 'July 2026',
      basicSalary: 120000.0,
      hra: 48000.0,
      specialAllowance: 32000.0,
      performanceBonus: 0.0,
      providentFund: 14400.0,
      esi: 1500.0,
      professionalTax: 200.0,
      incomeTaxTds: 17200.0,
      paymentDate: '31 Jul 2026',
      transactionId: 'TXN-83719203',
      currency: 'INR',
      status: 'Disbursed',
    ),
  ];

  // Candidates Pipeline
  static const List<CandidateModel> initialCandidates = [
    CandidateModel(
      id: 'CAN-801',
      name: 'Rohan Deshmukh',
      appliedRole: 'Senior Backend Engineer (Go/Rust)',
      experienceYears: '6.5 Yrs',
      aiMatchScore: 94,
      stage: CandidateStage.round2,
      videoScreeningStatus: 'Completed',
      interviewDate: 'Tomorrow, 3:00 PM',
      proctorTrustScore: 99.2,
    ),
    CandidateModel(
      id: 'CAN-802',
      name: 'Sneha Chawla',
      appliedRole: 'Lead Product Designer (Design Systems)',
      experienceYears: '5.0 Yrs',
      aiMatchScore: 97,
      stage: CandidateStage.round1,
      videoScreeningStatus: 'Completed',
      interviewDate: 'Sep 19, 11:30 AM',
      proctorTrustScore: 98.6,
    ),
    CandidateModel(
      id: 'CAN-803',
      name: 'Vikramaditya Verma',
      appliedRole: 'Staff ML Infrastructure Engineer',
      experienceYears: '8.0 Yrs',
      aiMatchScore: 98,
      stage: CandidateStage.offerExtended,
      videoScreeningStatus: 'Completed',
      interviewDate: 'Sep 14, 4:00 PM',
      proctorTrustScore: 99.8,
    ),
    CandidateModel(
      id: 'CAN-804',
      name: 'Priya Sundaram',
      appliedRole: 'Frontend Architect (Flutter/React)',
      experienceYears: '4.2 Yrs',
      aiMatchScore: 91,
      stage: CandidateStage.screening,
      videoScreeningStatus: 'Scheduled',
      interviewDate: 'Sep 21, 2:00 PM',
      proctorTrustScore: 97.4,
    ),
  ];

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
