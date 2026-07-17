import 'package:flutter/material.dart';

/// A flat, filled tonal surface container used throughout the app.
/// Despite the legacy name, this is no longer a "glass" blur effect —
/// the redesign uses flat Material 3 surface-container fills with no border.
class GlassCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final BorderRadius? borderRadius;
  final Border? border;
  final EdgeInsetsGeometry? padding;

  const GlassCard({
    super.key,
    required this.child,
    this.color,
    this.borderRadius,
    this.border,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.colorScheme.surfaceContainer;
    final finalRadius = borderRadius ?? BorderRadius.circular(20);

    return Material(
      color: cardColor,
      borderRadius: finalRadius,
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(border: border, borderRadius: finalRadius),
        child: child,
      ),
    );
  }
}
