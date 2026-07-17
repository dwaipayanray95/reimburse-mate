import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reimburse_mate/core/database/app_database.dart';
import 'package:reimburse_mate/models/claim_status.dart';

class DashboardStats {
  final double totalPending;
  final int thisMonthCount;
  final double totalClaimed;
  final double averageClaimSize;
  final List<MapEntry<String, double>> monthlySpend;
  final Map<ClaimStatus, int> statusBreakdown;
  final Map<String, double> projectSpend; // NEW

  DashboardStats({
    required this.totalPending,
    required this.thisMonthCount,
    required this.totalClaimed,
    required this.averageClaimSize,
    required this.monthlySpend,
    required this.statusBreakdown,
    required this.projectSpend,
  });
}

class DashboardNotifier extends StateNotifier<DashboardStats> {
  DashboardNotifier()
      : super(DashboardStats(
          totalPending: 0.0,
          thisMonthCount: 0,
          totalClaimed: 0.0,
          averageClaimSize: 0.0,
          monthlySpend: [],
          statusBreakdown: {},
          projectSpend: {},
        ));

  void updateStats(List<Reimbursement> claims) {
    double pendingSum = 0.0;
    double claimedSum = 0.0;
    int thisMonthClaims = 0;
    final now = DateTime.now();

    final statusMap = <ClaimStatus, int>{};
    for (var status in ClaimStatus.values) {
      statusMap[status] = 0;
    }

    final monthlyDataMap = <String, double>{};
    final projectDataMap = <String, double>{}; // NEW

    for (final claim in claims) {
      final amt = claim.amount ?? 0.0;
      final status = ClaimStatus.fromDbKey(claim.status);
      statusMap[status] = (statusMap[status] ?? 0) + 1;

      // Pending (draft or yet to claim)
      if (status == ClaimStatus.yetToClaim || status == ClaimStatus.draft) {
        pendingSum += amt;
      }

      // Claimed/Submitted/Paid
      if (status == ClaimStatus.submitted || status == ClaimStatus.paid) {
        claimedSum += amt;
      }

      // Current month count
      if (claim.date.year == now.year && claim.date.month == now.month) {
        thisMonthClaims++;
      }

      // Monthly aggregation (last 6 months) — keyed by year+month so
      // different years never collapse into the same bucket.
      final monthKey = '${claim.date.year}-${claim.date.month.toString().padLeft(2, '0')}';
      monthlyDataMap[monthKey] = (monthlyDataMap[monthKey] ?? 0.0) + amt;

      // Project code aggregation
      final projCode = claim.projectCode.trim().toUpperCase();
      if (projCode.isNotEmpty) {
        projectDataMap[projCode] = (projectDataMap[projCode] ?? 0.0) + amt;
      }
    }

    final avgSize = claims.isEmpty
        ? 0.0
        : claims.fold<double>(0.0, (sum, e) => sum + (e.amount ?? 0.0)) / claims.length;

    // Sort chronologically by the "YYYY-MM" key, keep the most recent 6
    // months, then relabel for display as "MMM 'yy" so different years
    // are still visually distinguishable.
    final sortedEntries = monthlyDataMap.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final recentEntries = sortedEntries.length > 6
        ? sortedEntries.sublist(sortedEntries.length - 6)
        : sortedEntries;
    final sortedMonthlySpend = recentEntries.map((entry) {
      final parts = entry.key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final label = '${_getMonthName(month)} \'${(year % 100).toString().padLeft(2, '0')}';
      return MapEntry(label, entry.value);
    }).toList();

    state = DashboardStats(
      totalPending: pendingSum,
      thisMonthCount: thisMonthClaims,
      totalClaimed: claimedSum,
      averageClaimSize: avgSize,
      monthlySpend: sortedMonthlySpend,
      statusBreakdown: statusMap,
      projectSpend: projectDataMap,
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
