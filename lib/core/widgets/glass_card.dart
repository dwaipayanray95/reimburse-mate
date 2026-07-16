import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color? color;
  final BorderRadius? borderRadius;
  final Border? border;
  final EdgeInsetsGeometry? padding;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 12.0,
    this.opacity = 0.1,
    this.color,
    this.borderRadius,
    this.border,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? (theme.brightness == Brightness.light ? Colors.white : const Color(0xFF0F172A));
    final finalRadius = borderRadius ?? BorderRadius.circular(16);

    return ClipRRect(
      borderRadius: finalRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor.withOpacity(opacity),
            borderRadius: finalRadius,
            border: border ?? Border.all(
              color: (theme.brightness == Brightness.light ? Colors.white : const Color(0xFF1E293B)).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
