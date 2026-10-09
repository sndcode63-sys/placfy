import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_state.dart';
import 'blocs/navigation/navigation_bloc.dart';
import 'blocs/attendance/attendance_bloc.dart';
import 'blocs/leave/leave_bloc.dart';
import 'blocs/preferences/preferences_bloc.dart';
import 'repositories/auth_repository.dart';
import 'repositories/attendance_repository.dart';
import 'repositories/leave_repository.dart';
import 'views/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarContrastEnforced: false,
  ));
  runApp(const PlacfyApp());
}

class PlacfyApp extends StatefulWidget {
  const PlacfyApp({super.key});

  @override
  State<PlacfyApp> createState() => _PlacfyAppState();
}

class _PlacfyAppState extends State<PlacfyApp> {
  late final AuthRepository _authRepository;
  late final AttendanceRepository _attendanceRepository;
  late final LeaveRepository _leaveRepository;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepository();
    _attendanceRepository = AttendanceRepository(
      apiClient: _authRepository.apiClient,
      storage: _authRepository.storage,
    );
    _leaveRepository = LeaveRepository(
      apiClient: _authRepository.apiClient,
      storage: _authRepository.storage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(authRepository: _authRepository),
        ),
        BlocProvider<NavigationBloc>(create: (_) => NavigationBloc()),
        BlocProvider<AttendanceBloc>(
          create: (_) => AttendanceBloc(
            attendanceRepository: _attendanceRepository,
            storage: _authRepository.storage,
          ),
        ),
        BlocProvider<LeaveBloc>(
          create: (_) => LeaveBloc(
            leaveRepository: _leaveRepository,
            storage: _authRepository.storage,
          ),
        ),
        BlocProvider<PreferencesBloc>(create: (_) => PreferencesBloc()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          if (authState is Authenticated) {
            final slug = authState.activeWorkspace.slug;
            final entityId = authState.activeEntity?.id;
            context.read<AttendanceBloc>().add(LoadAttendanceEvent(
                  workspaceSlug: slug,
                  entityId: entityId,
                ));
            context.read<LeaveBloc>().add(LoadLeavesEvent(
                  workspaceSlug: slug,
                  entityId: entityId,
                ));
          }
        },
        child: MaterialApp(
          title: 'Placfy',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.lightTheme,
          themeMode: ThemeMode.light,
          builder: (context, child) => MediaQuery.withClampedTextScaling(
            minScaleFactor: 0.9,
            maxScaleFactor: 1.15,
            child: child ?? const SizedBox.shrink(),
          ),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
