import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../models/auth_user_model.dart';
import '../../models/workspace_model.dart';
import '../main_navigation_screen.dart';

class WorkspaceSelectScreen extends StatelessWidget {
  final List<WorkspaceModel> workspaces;
  final AuthUserModel user;

  const WorkspaceSelectScreen({
    super.key,
    required this.workspaces,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
            (route) => false,
          );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.statusError, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(state.error)),
                  ],
                ),
              ),
            );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgDeep,
        body: AppBackground(
          child: SafeArea(
            child: ResponsiveLayout(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 44,
                    child: canPop
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: Material(
                              color: AppColors.surfaceField,
                              shape: const CircleBorder(
                                side: BorderSide(color: AppColors.borderLight),
                              ),
                              child: IconButton(
                                tooltip: 'Back',
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 18,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select workspace',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.9,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Workspaces available for ${user.fullName}',
                    style: const TextStyle(
                      fontSize: 14.5,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Expanded(
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final loading = state is AuthLoading;
                        return Stack(
                          children: [
                            ListView.builder(
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: workspaces.length,
                              itemBuilder: (context, index) {
                                final workspace = workspaces[index];
                                return _WorkspaceTile(
                                  workspace: workspace,
                                  onTap: loading
                                      ? null
                                      : () => context
                                          .read<AuthBloc>()
                                          .add(SelectWorkspace(workspace)),
                                );
                              },
                            ),
                            if (loading)
                              const Positioned.fill(
                                child: ColoredBox(
                                  color: Color(0xB3FFFFFF),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkspaceTile extends StatelessWidget {
  final WorkspaceModel workspace;
  final VoidCallback? onTap;

  const _WorkspaceTile({required this.workspace, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = workspace.name.trim();
    final letter = name.isEmpty ? 'W' : name[0].toUpperCase();

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              letter,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Tap to open this workspace',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}
