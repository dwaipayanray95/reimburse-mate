import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reimburse_mate/core/providers.dart';
import 'package:reimburse_mate/core/widgets/empty_state.dart';
import 'package:reimburse_mate/features/claims/presentation/claim_detail_screen.dart';
import 'widgets/stat_card.dart';
import 'widgets/spend_chart.dart';
import 'widgets/recent_activity_tile.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stats = ref.watch(dashboardProvider);
    final claimsAsync = ref.watch(claimsNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back 👋',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.textTheme.titleMedium?.color?.withOpacity(0.6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      ref.watch(settingsProvider).userName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Stat Cards Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                StatCard(
                  title: 'Pending',
                  value: stats.totalPending,
                  prefix: '₹',
                  icon: Icons.hourglass_empty_rounded,
                  tintColor: Colors.amber,
                ),
                StatCard(
                  title: 'This Month',
                  value: stats.thisMonthCount.toDouble(),
                  prefix: '',
                  suffix: ' claims',
                  icon: Icons.calendar_today_rounded,
                  tintColor: Colors.blue,
                ),
                StatCard(
                  title: 'Total Claimed',
                  value: stats.totalClaimed,
                  prefix: '₹',
                  icon: Icons.check_circle_outline_rounded,
                  tintColor: Colors.teal,
                ),
                StatCard(
                  title: 'Average Size',
                  value: stats.averageClaimSize,
                  prefix: '₹',
                  icon: Icons.analytics_rounded,
                  tintColor: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Spend Chart Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Spend',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SpendChart(monthlySpend: stats.monthlySpend),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Recent Activity Section
            Text(
              'Recent Activity',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            claimsAsync.when(
              data: (claims) {
                if (claims.isEmpty) {
                  return const EmptyState(
                    title: 'No recent activity',
                    subtitle: 'Tap the "+" button below to log your first reimbursement.',
                    icon: Icons.history_edu_rounded,
                  );
                }

                final recent = claims.take(5).toList();
                return Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: recent.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = recent[index];
                      return RecentActivityTile(
                        item: item,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClaimDetailScreen(claim: item),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ],
        ),
      ),
    );
  }
}
