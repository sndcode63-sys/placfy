import 'package:flutter/material.dart';

/// Plain white screen background. Wrap every screen body with it.
class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SizedBox.expand(child: child),
    );
  }
}
