import 'package:flutter/material.dart';
import 'package:reimburse_mate/core/widgets/glass_card.dart';
import 'package:reimburse_mate/core/widgets/animated_counter.dart';

class StatCard extends StatelessWidget {
  final String title;
  final double value;
  final String prefix;
  final String suffix;
  final IconData icon;
  final Color tintColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.prefix,
    this.suffix = '',
    required this.icon,
    required this.tintColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      opacity: 0.05,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, color: tintColor, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedCounter(
            value: value,
            prefix: prefix,
            suffix: suffix,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
