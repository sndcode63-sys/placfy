import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// White backdrop with slowly rising soft-blue bubbles.
class BubbleBackground extends StatefulWidget {
  final Widget child;
  final int bubbleCount;

  const BubbleBackground({
    super.key,
    required this.child,
    this.bubbleCount = 22,
  });

  @override
  State<BubbleBackground> createState() => _BubbleBackgroundState();
}

class _BubbleBackgroundState extends State<BubbleBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Bubble> _bubbles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
    final rnd = math.Random(7);
    _bubbles = List.generate(widget.bubbleCount, (_) {
      return _Bubble(
        x: rnd.nextDouble(),
        size: 10 + rnd.nextDouble() * 62,
        speed: 1 + rnd.nextInt(3),
        phase: rnd.nextDouble(),
        wobble: 1 + rnd.nextInt(3),
        drift: 6 + rnd.nextDouble() * 22,
        opacity: 0.35 + rnd.nextDouble() * 0.65,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Colors.white),
        RepaintBoundary(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _BubblePainter(_controller, _bubbles),
              size: Size.infinite,
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Bubble {
  final double x;
  final double size;
  final int speed;
  final double phase;
  final int wobble;
  final double drift;
  final double opacity;

  const _Bubble({
    required this.x,
    required this.size,
    required this.speed,
    required this.phase,
    required this.wobble,
    required this.drift,
    required this.opacity,
  });
}

class _BubblePainter extends CustomPainter {
  final Animation<double> animation;
  final List<_Bubble> bubbles;

  _BubblePainter(this.animation, this.bubbles) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    for (final b in bubbles) {
      final progress = (t * b.speed + b.phase) % 1.0;
      final r = b.size / 2;
      final y = size.height + b.size - progress * (size.height + b.size * 2);
      final x = b.x * size.width +
          math.sin((t * b.wobble + b.phase) * 2 * math.pi) * b.drift;
      final fade = math.sin(progress * math.pi).clamp(0.0, 1.0) * b.opacity;
      if (fade <= 0.01) continue;

      final center = Offset(x, y);
      final rect = Rect.fromCircle(center: center, radius: r);

      final fill = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.35),
          colors: [
            AppColors.primary.withValues(alpha: 0.10 * fade),
            AppColors.accent.withValues(alpha: 0.07 * fade),
            AppColors.primary.withValues(alpha: 0.03 * fade),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(rect);
      canvas.drawCircle(center, r, fill);

      canvas.drawCircle(
        center,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = AppColors.primary.withValues(alpha: 0.18 * fade),
      );

      canvas.drawCircle(
        center.translate(-r * 0.38, -r * 0.38),
        r * 0.16,
        Paint()..color = Colors.white.withValues(alpha: 0.9 * fade),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter old) => false;
}
