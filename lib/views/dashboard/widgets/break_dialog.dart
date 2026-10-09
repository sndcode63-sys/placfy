import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../blocs/attendance/attendance_bloc.dart';
import '../../../blocs/navigation/navigation_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/error_snack.dart';
import '../../../models/shift_info_model.dart';

/// True while the break dialog is on screen (so the page-level snackbar
/// doesn't also fire behind it — the dialog shows the error inline).
bool breakDialogOpen = false;

Future<void> showBreakDialog(BuildContext context) async {
  breakDialogOpen = true;
  await showDialog<void>(
    context: context,
    builder: (_) => const BreakDialog(),
  );
  breakDialogOpen = false;
}

// Break palette (solid colours only).
const _amber = Color(0xFFD97706);
const _amberDeep = Color(0xFFB45309);
const _amberText = Color(0xFF92400E);
const _amberBg = Color(0xFFFFFBEB);
const _amberBorder = Color(0xFFFDE68A);

/// Floating break panel: header with live timer, current break card,
/// "End Break & Resume Work", workday progress and the list of all breaks.
class BreakDialog extends StatefulWidget {
  const BreakDialog({super.key});

  @override
  State<BreakDialog> createState() => _BreakDialogState();
}

class _BreakDialogState extends State<BreakDialog> {
  String? _errTitle;
  String? _errMessage;
  int? _startingRuleId;
  late int _seenErrSeq;

  @override
  void initState() {
    super.initState();
    _seenErrSeq = context.read<AttendanceBloc>().state.errorSeq;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AttendanceBloc, AttendanceState>(
      listenWhen: (p, c) => p.errorSeq != c.errorSeq || p.onBreak != c.onBreak,
      listener: (context, state) {
        setState(() {
          if (state.errorSeq != _seenErrSeq) {
            // New error → show it inside the dialog.
            _seenErrSeq = state.errorSeq;
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              _errTitle = state.errorTitle;
              _errMessage = state.errorMessage;
            }
          } else {
            // Break actually started / ended → clear any old error.
            _errMessage = null;
          }
          _startingRuleId = null;
        });
      },
      builder: (context, state) {
        final shift = state.shiftInfo;
        final rules = shift?.breakRules ?? const <BreakRuleInfo>[];
        final onBreak = state.onBreak;

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _amberBorder),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33D97706),
                    blurRadius: 40,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Header(state: state, onBreak: onBreak),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_errMessage != null) ...[
                            ErrorBanner(
                              title: _errTitle,
                              message: _errMessage!,
                              onClose: () =>
                                  setState(() => _errMessage = null),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (onBreak) ...[
                            _ActiveBreakCard(state: state),
                            const SizedBox(height: 12),
                            _EndBreakButton(state: state),
                            const SizedBox(height: 12),
                          ],
                          _WorkdayCard(state: state),
                          const SizedBox(height: 12),
                          _AllBreaksCard(
                            rules: rules,
                            state: state,
                            startingRuleId: _startingRuleId,
                            onStart: (rule) {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _errMessage = null;
                                _startingRuleId = rule.id;
                              });
                              context.read<AttendanceBloc>().add(
                                    BreakStartEvent(
                                      breakRuleId: rule.id,
                                      breakName: rule.name,
                                      allowedMinutes: rule.durationMinutes,
                                    ),
                                  );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            context
                                .read<NavigationBloc>()
                                .add(const ChangeTabEvent(1));
                          },
                          child: const Text(
                            'Open Attendance',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Close',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Helpers ─────────────────────────────────────────────────────────────────
String _clock(int seconds) {
  final s = seconds < 0 ? 0 : seconds;
  final h = s ~/ 3600;
  final m = (s % 3600) ~/ 60;
  final sec = s % 60;
  String two(int v) => v.toString().padLeft(2, '0');
  return h > 0 ? '${two(h)}:${two(m)}:${two(sec)}' : '${two(m)}:${two(sec)}';
}

/// Seconds left in the running break (negative → over time). Null if the
/// break has no time limit.
int? _remaining(AttendanceState s) {
  final allowed = s.activeBreakMinutes;
  if (allowed == null) return null;
  return allowed * 60 - s.breakElapsedSeconds;
}

int _shiftSeconds(ShiftInfoModel? shift) {
  int parse(String v) {
    final p = v.split(':');
    if (p.length < 2) return 0;
    return (int.tryParse(p[0]) ?? 0) * 3600 + (int.tryParse(p[1]) ?? 0) * 60;
  }

  if (shift == null) return 9 * 3600;
  final diff = parse(shift.shiftEnd) - parse(shift.shiftStart);
  final total = diff <= 0 ? diff + 24 * 3600 : diff;
  return total <= 0 ? 9 * 3600 : total;
}

TextStyle _caps(Color c) => TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.1,
      color: c,
    );

const _mono = TextStyle(
  fontFeatures: [FontFeature.tabularFigures()],
  fontWeight: FontWeight.w800,
);

class _Pill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  final Color border;
  const _Pill({
    required this.text,
    required this.bg,
    required this.fg,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: fg,
        ),
      ),
    );
  }
}

// ── Header ──────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final AttendanceState state;
  final bool onBreak;
  const _Header({required this.state, required this.onBreak});

  @override
  Widget build(BuildContext context) {
    final remaining = _remaining(state);
    final over = onBreak && remaining != null && remaining < 0;

    final String big;
    if (!onBreak) {
      big = state.formattedTimer;
    } else if (remaining == null) {
      big = _clock(state.breakElapsedSeconds);
    } else if (over) {
      big = '+${_clock(-remaining)}';
    } else {
      big = _clock(remaining);
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_amber, _amberDeep],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE08A1E),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFF3B766)),
                    ),
                    child: const Icon(Icons.free_breakfast_outlined,
                        color: Colors.white, size: 24),
                  ),
                  if (onBreak)
                    Positioned(
                      top: -3,
                      right: -3,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFACC15),
                          shape: BoxShape.circle,
                          border: Border.all(color: _amberDeep, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      onBreak ? 'ON BREAK' : 'TAKE A BREAK',
                      style: _caps(const Color(0xFFFDE7C0)),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        big,
                        style: _mono.copyWith(
                          fontSize: 28,
                          letterSpacing: 0.5,
                          color: over ? const Color(0xFFFEE2E2) : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                onBreak ? Icons.hourglass_bottom_rounded : Icons.timer_outlined,
                color: Colors.white.withValues(alpha: 0.9),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  onBreak
                      ? 'Work timer is paused'
                      : 'Your work timer pauses during a break',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFDE7C0),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _Pill(
                text: onBreak ? 'ACTIVE' : 'WORKING',
                bg: const Color(0xFFFFF3D6),
                fg: _amberText,
                border: const Color(0xFFFCD28A),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Current break ───────────────────────────────────────────────────────────
class _ActiveBreakCard extends StatelessWidget {
  final AttendanceState state;
  const _ActiveBreakCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final remaining = _remaining(state);
    final over = remaining != null && remaining < 0;
    final started = state.breakStartedAt;

    final String label = remaining == null
        ? 'TIME ON BREAK'
        : (over ? 'OVER BY' : 'TIME REMAINING');
    final String value = remaining == null
        ? _clock(state.breakElapsedSeconds)
        : _clock(over ? -remaining : remaining);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: over ? AppColors.statusErrorBg : _amberBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: over ? AppColors.statusErrorBorder : _amberBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  (state.activeBreakName ?? 'Break').toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _caps(AppColors.textMuted),
                ),
              ),
              const _Pill(
                text: 'ACTIVE',
                bg: Color(0xFFFEF3C7),
                fg: _amberText,
                border: Color(0xFFFCD34D),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Break in progress',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: over ? AppColors.statusError : _amberText,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(label, style: _caps(AppColors.textMuted)),
              ),
              Text(
                value,
                style: _mono.copyWith(
                  fontSize: 26,
                  color: over ? AppColors.statusError : _amberDeep,
                ),
              ),
            ],
          ),
          if (started != null) ...[
            const SizedBox(height: 6),
            Text(
              'Started at ${DateFormat('hh:mm a').format(started).toLowerCase()}',
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EndBreakButton extends StatelessWidget {
  final AttendanceState state;
  const _EndBreakButton({required this.state});

  @override
  Widget build(BuildContext context) {
    final busy = state.isProcessing;
    return SizedBox(
      height: 48,
      child: Material(
        color: busy ? const Color(0xFFE9A653) : _amber,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: busy
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  context.read<AttendanceBloc>().add(BreakEndEvent());
                },
          child: Center(
            child: busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'End Break & Resume Work',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Workday progress ────────────────────────────────────────────────────────
class _WorkdayCard extends StatelessWidget {
  final AttendanceState state;
  const _WorkdayCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final total = _shiftSeconds(state.shiftInfo);
    final ratio = (state.elapsedSeconds / total).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceField,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('WORKDAY ELAPSED', style: _caps(AppColors.textMuted)),
              ),
              Text(
                state.formattedTimer,
                style: _mono.copyWith(
                  fontSize: 13.5,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: AppColors.borderLight,
              valueColor: const AlwaysStoppedAnimation<Color>(_amber),
            ),
          ),
        ],
      ),
    );
  }
}

// ── All breaks ──────────────────────────────────────────────────────────────
class _AllBreaksCard extends StatelessWidget {
  final List<BreakRuleInfo> rules;
  final AttendanceState state;
  final int? startingRuleId;
  final ValueChanged<BreakRuleInfo> onStart;

  const _AllBreaksCard({
    required this.rules,
    required this.state,
    required this.startingRuleId,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ALL BREAKS', style: _caps(AppColors.textMuted)),
          const SizedBox(height: 6),
          if (rules.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'No breaks are set up for your shift. Please contact your HR administrator.',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            for (final rule in rules) _row(context, rule),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, BreakRuleInfo rule) {
    final active = state.onBreak && state.activeBreakName == rule.name;
    final starting = startingRuleId == rule.id && state.isProcessing;
    final canStart = !state.onBreak && !state.isProcessing;

    final sub = <String>[
      if (rule.durationMinutes != null) '${rule.durationMinutes} min',
      rule.isPaid ? 'Paid' : 'Unpaid',
    ].join('  •  ');

    final Widget trailing;
    if (active) {
      trailing = const _Pill(
        text: 'ACTIVE',
        bg: Color(0xFFFEF3C7),
        fg: _amberText,
        border: Color(0xFFFCD34D),
      );
    } else if (starting) {
      trailing = const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2.2, color: _amber),
      );
    } else if (canStart) {
      trailing = Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: _amber,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'START',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: Colors.white,
          ),
        ),
      );
    } else {
      trailing = const _Pill(
        text: 'PENDING',
        bg: AppColors.surfaceField,
        fg: AppColors.textMuted,
        border: AppColors.borderLight,
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: canStart ? () => onStart(rule) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rule.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: active ? _amberText : AppColors.textPrimary,
                    ),
                  ),
                  if (sub.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            trailing,
          ],
        ),
      ),
    );
  }
}
