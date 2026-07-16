import 'package:flutter/material.dart';

/// The 5 possible states a reimbursement claim can be in.
enum ClaimStatus {
  draft('Draft', 'draft'),
  yetToClaim('Yet to Claim', 'yet_to_claim'),
  submitted('Submitted', 'submitted'),
  paid('Paid', 'paid'),
  rejected('Rejected', 'rejected');

  final String label;
  final String dbKey;
  const ClaimStatus(this.label, this.dbKey);

  factory ClaimStatus.fromDbKey(String key) {
    return ClaimStatus.values.firstWhere(
      (s) => s.dbKey == key,
      orElse: () => ClaimStatus.draft,
    );
  }

  Color get color {
    switch (this) {
      case ClaimStatus.draft:
        return const Color(0xFF94A3B8); // slate
      case ClaimStatus.yetToClaim:
        return const Color(0xFFF59E0B); // amber
      case ClaimStatus.submitted:
        return const Color(0xFF3B82F6); // blue
      case ClaimStatus.paid:
        return const Color(0xFF10B981); // emerald
      case ClaimStatus.rejected:
        return const Color(0xFFEF4444); // red
    }
  }

  Color get backgroundColor {
    return color.withOpacity(0.12);
  }

  IconData get icon {
    switch (this) {
      case ClaimStatus.draft:
        return Icons.edit_outlined;
      case ClaimStatus.yetToClaim:
        return Icons.schedule_rounded;
      case ClaimStatus.submitted:
        return Icons.send_rounded;
      case ClaimStatus.paid:
        return Icons.check_circle_rounded;
      case ClaimStatus.rejected:
        return Icons.cancel_rounded;
    }
  }

  String get emoji {
    switch (this) {
      case ClaimStatus.draft:
        return '📝';
      case ClaimStatus.yetToClaim:
        return '⏳';
      case ClaimStatus.submitted:
        return '📤';
      case ClaimStatus.paid:
        return '💰';
      case ClaimStatus.rejected:
        return '❌';
    }
  }

  /// Returns the next logical status in the workflow.
  ClaimStatus? get nextStatus {
    switch (this) {
      case ClaimStatus.draft:
        return ClaimStatus.yetToClaim;
      case ClaimStatus.yetToClaim:
        return ClaimStatus.submitted;
      case ClaimStatus.submitted:
        return ClaimStatus.paid;
      case ClaimStatus.paid:
        return null;
      case ClaimStatus.rejected:
        return ClaimStatus.yetToClaim; // re-file
    }
  }
}
