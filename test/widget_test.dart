import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:placfy/blocs/auth/auth_bloc.dart';
import 'package:placfy/blocs/navigation/navigation_bloc.dart';
import 'package:placfy/blocs/preferences/preferences_bloc.dart';
import 'package:placfy/core/theme/app_theme.dart';
import 'package:placfy/models/auth_user_model.dart';
import 'package:placfy/models/legal_entity_model.dart';
import 'package:placfy/models/shift_info_model.dart';
import 'package:placfy/models/workspace_model.dart';
import 'package:placfy/models/employee_model.dart';
import 'package:placfy/models/leave_request_model.dart';
import 'package:placfy/models/workspace_member_model.dart';
import 'package:placfy/repositories/auth_repository.dart';
import 'package:placfy/views/auth/login_screen.dart';
import 'package:placfy/views/auth/workspace_select_screen.dart';
import 'package:placfy/views/profile/profile_view.dart';
import 'package:placfy/views/splash/splash_screen.dart';

void main() {
  test('Model Serialization Test: AuthUserModel', () {
    final json = {
      'id': 52,
      'username': 'employee',
      'email': 'employee@testing.com',
      'first_name': 'Alex',
      'last_name': 'Taylor',
      'roles': ['employee'],
      'access_context': {
        'has_workspace_access': true,
        'default_redirect': 'workspace'
      }
    };
    final user = AuthUserModel.fromJson(json);
    expect(user.id, 52);
    expect(user.fullName, 'Alex Taylor');
    expect(user.initials, 'AT');
    expect(user.primaryRole, 'employee');
  });

  test('Model Serialization Test: WorkspaceModel', () {
    final json = {
      'id': 5,
      'tenant_id': 'bb6d8f1f-8dd2-4d9a-9759-89a05010d7a9',
      'name': 'Testing Workspace',
      'slug': 'testing-workspace',
      'member_count': 9,
      'my_role': 'employee',
    };
    final ws = WorkspaceModel.fromJson(json);
    expect(ws.id, 5);
    expect(ws.slug, 'testing-workspace');
    expect(ws.myRole, 'employee');
  });

  test('Model Serialization Test: LegalEntityModel', () {
    final json = {
      'id': 5,
      'entity_id': '141cdf71-ab07-42a4-8b56-cb362b1513b4',
      'name': 'Placfy Testing India Pvt Ltd',
      'slug': 'placfy-testing-india-pvt-ltd',
      'entity_code': 'PLCFY-IND',
      'is_default': true,
      'is_active': true,
    };
    final entity = LegalEntityModel.fromJson(json);
    expect(entity.id, 5);
    expect(entity.entityCode, 'PLCFY-IND');
    expect(entity.isDefault, isTrue);
  });

  test('Model Serialization Test: ShiftInfoModel', () {
    final json = {
      'date': '2026-09-18',
      'shift_name': 'General Shift',
      'shift_start': '09:00:00',
      'shift_end': '18:00:00',
      'status': 'not_marked',
      'has_checked_in': false,
    };
    final shift = ShiftInfoModel.fromJson(json);
    expect(shift.shiftName, 'General Shift');
    expect(shift.formattedHours, '09:00 - 18:00');
    expect(shift.statusDisplay, 'Not Marked Yet');
  });

  testWidgets('SplashScreen renders Placfy branding', (WidgetTester tester) async {
    final authRepo = AuthRepository();
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => AuthBloc(authRepository: authRepo)),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const SplashScreen(),
        ),
      ),
    );

    // Initial pump
    await tester.pump();

    expect(find.text('Placfy'), findsOneWidget);
    expect(find.text('Autonomous HR & Payroll Cloud'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1500));
  });

  testWidgets('LoginScreen renders email, password and quick test fill button',
      (WidgetTester tester) async {
    final authRepo = AuthRepository();
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => AuthBloc(authRepository: authRepo)),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LoginScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Welcome to Placfy'), findsOneWidget);
    expect(find.text('Verified Test Account'), findsOneWidget);
    expect(find.text('Auto-Fill'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('WorkspaceSelectScreen renders workspace list items',
      (WidgetTester tester) async {
    final authRepo = AuthRepository();
    const testUser = AuthUserModel(
      id: 52,
      username: 'employee',
      email: 'employee@testing.com',
      firstName: 'Alex',
      lastName: 'Taylor',
      fullName: 'Alex Taylor',
      roles: ['employee'],
    );
    const testWorkspaces = [
      WorkspaceModel(
        id: 5,
        tenantId: 'tenant-123',
        name: 'Testing Workspace',
        slug: 'testing-workspace',
        myRole: 'employee',
      ),
    ];

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => AuthBloc(authRepository: authRepo)),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: WorkspaceSelectScreen(
            workspaces: testWorkspaces,
            user: testUser,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Select Workspace'), findsOneWidget);
    expect(find.text('Testing Workspace'), findsOneWidget);
    expect(find.text('EMPLOYEE'), findsOneWidget);
  });

  testWidgets('ProfileView renders user profile and logout option',
      (WidgetTester tester) async {
    final authRepo = AuthRepository();
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => AuthBloc(authRepository: authRepo)),
          BlocProvider<PreferencesBloc>(create: (_) => PreferencesBloc()),
          BlocProvider<NavigationBloc>(create: (_) => NavigationBloc()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: ProfileView()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('DIGITAL WORKFORCE ID'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
    expect(find.text('Workspace & Legal Entity'), findsOneWidget);
  });

  test('Model Serialization Test: AttendanceRecord fromJson', () {
    final json = {
      'id': 101,
      'date': '2026-09-18',
      'first_check_in': '2026-09-18T09:00:00Z',
      'last_check_out': '2026-09-18T18:00:00Z',
      'effective_hours': 9.0,
      'status': 'Present',
    };
    final record = AttendanceRecord.fromJson(json);
    expect(record.formattedDuration, '9h 0m');
    expect(record.status, 'PRESENT');
    expect(record.punchInTime.isNotEmpty, true);
    expect(record.punchOutTime?.isNotEmpty, true);
  });

  test('Model Serialization Test: LeaveBalanceModel & LeaveRequestModel fromJson', () {
    final balanceJson = {
      'leave_type_name': 'Casual Leave',
      'total_allocated': 12.0,
      'used': 3.0,
      'remaining': 9.0,
    };
    final balance = LeaveBalanceModel.fromJson(balanceJson);
    expect(balance.leaveType, 'Casual Leave');
    expect(balance.totalAllocated, 12.0);
    expect(balance.used, 3.0);
    expect(balance.remaining, 9.0);

    final requestJson = {
      'id': 7,
      'leave_type_name': 'Sick Leave',
      'start_date': '2026-09-20',
      'end_date': '2026-09-21',
      'days_count': 2.0,
      'reason': 'Health checkup',
      'status': 'Approved',
      'approved_by': 'Manager Jane',
    };
    final req = LeaveRequestModel.fromJson(requestJson);
    expect(req.id, '7');
    expect(req.leaveType, 'Sick Leave');
    expect(req.daysCount, 2.0);
    expect(req.approvedBy, 'Manager Jane');
    expect(req.status, LeaveStatus.approved);
  });

  test('Model Serialization Test: WorkspaceMemberModel fromJson', () {
    final memberJson = {
      'id': 12,
      'user_id': 52,
      'username': 'priya',
      'user_full_name': 'Priya Sharma',
      'user_email': 'priya@testing.com',
      'role': 'employee',
      'is_active': true,
      'joined_at': '2026-01-01',
    };
    final member = WorkspaceMemberModel.fromJson(memberJson);
    expect(member.id, 12);
    expect(member.userFullName, 'Priya Sharma');
    expect(member.role, 'employee');
    expect(member.userEmail, 'priya@testing.com');
  });
}
