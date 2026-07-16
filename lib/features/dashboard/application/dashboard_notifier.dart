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

  DashboardStats({
    required this.totalPending,
    required this.thisMonthCount,
    required this.totalClaimed,
    required this.averageClaimSize,
    required this.monthlySpend,
    required this.statusBreakdown,
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

      // Monthly aggregation (last 6 months)
      final monthName = _getMonthName(claim.date.month);
      monthlyDataMap[monthName] = (monthlyDataMap[monthName] ?? 0.0) + amt;
    }

    final avgSize = claims.isEmpty ? 0.0 : (claims.map((e) => e.amount ?? 0.0).reduce((a, b) => a + b) / claims.length);

    // Prepare monthly list sorted by calendar progression
    final monthsList = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final sortedMonthlySpend = monthlyDataMap.entries.toList()
      ..sort((a, b) => monthsList.indexOf(a.key).compareTo(monthsList.indexOf(b.key)));

    state = DashboardStats(
      totalPending: pendingSum,
      thisMonthCount: thisMonthClaims,
      totalClaimed: claimedSum,
      averageClaimSize: avgSize,
      monthlySpend: sortedMonthlySpend,
      statusBreakdown: statusMap,
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
