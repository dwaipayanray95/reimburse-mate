import 'package:flutter/material.dart';
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

    return Container(
      constraints: const BoxConstraints(minHeight: 96),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: tintColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: tintColor, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedCounter(
            value: value,
            prefix: prefix,
            suffix: suffix,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
