import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The Placfy "P" speech-bubble mark, drawn as a vector so it stays crisp.
class PlacfyMark extends StatelessWidget {
  final double size;
  final Color color;

  const PlacfyMark({super.key, this.size = 48, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size * 0.86, size),
      painter: _MarkPainter(color),
    );
  }
}

class _MarkPainter extends CustomPainter {
  final Color color;
  _MarkPainter(this.color);

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;

    final head = Path()
      ..addRRect(RRect.fromLTRBAndCorners(
        0,
        0,
        w,
        h * 0.70,
        topLeft: Radius.circular(w * 0.2),
        topRight: Radius.circular(w * 0.4),
        bottomRight: Radius.circular(w * 0.4),
      ));

    final stem = Path()
      ..moveTo(0, h * 0.5)
      ..lineTo(0, h * 0.94)
      ..quadraticBezierTo(0, h, w * 0.05, h * 0.965)
      ..lineTo(w * 0.26, h * 0.80)
      ..quadraticBezierTo(w * 0.31, h * 0.76, w * 0.31, h * 0.69)
      ..lineTo(w * 0.31, h * 0.5)
      ..close();

    final hole = Path()
      ..addRRect(RRect.fromLTRBR(
        w * 0.31,
        h * 0.26,
        w * 0.73,
        h * 0.455,
        Radius.circular(h * 0.095),
      ));

    final shape = Path.combine(
      PathOperation.difference,
      Path.combine(PathOperation.union, head, stem),
      hole,
    );
    canvas.drawPath(shape, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.color != color;
}

/// Gradient rounded tile holding the mark.
class BrandTile extends StatelessWidget {
  final double size;
  final bool glow;

  const BrandTile({super.key, this.size = 44, this.glow = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.45),
                  blurRadius: size * 0.5,
                  offset: Offset(0, size * 0.15),
                ),
              ]
            : null,
      ),
      child: Center(child: PlacfyMark(size: size * 0.5)),
    );
  }
}
