import 'package:flutter/material.dart';

enum ExpenseCategory {
  travel,
  food,
  accommodation,
  transport,
  office,
  software,
  communication,
  medical,
  general;

  String get label {
    switch (this) {
      case ExpenseCategory.travel:
        return 'Travel';
      case ExpenseCategory.food:
        return 'Food & Dining';
      case ExpenseCategory.accommodation:
        return 'Accommodation';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.office:
        return 'Office Supplies';
      case ExpenseCategory.software:
        return 'Software & Tools';
      case ExpenseCategory.communication:
        return 'Communication';
      case ExpenseCategory.medical:
        return 'Medical';
      case ExpenseCategory.general:
        return 'General';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.travel:
        return Icons.flight_rounded;
      case ExpenseCategory.food:
        return Icons.restaurant_rounded;
      case ExpenseCategory.accommodation:
        return Icons.hotel_rounded;
      case ExpenseCategory.transport:
        return Icons.directions_car_rounded;
      case ExpenseCategory.office:
        return Icons.business_center_rounded;
      case ExpenseCategory.software:
        return Icons.computer_rounded;
      case ExpenseCategory.communication:
        return Icons.phone_rounded;
      case ExpenseCategory.medical:
        return Icons.local_hospital_rounded;
      case ExpenseCategory.general:
        return Icons.receipt_long_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.travel:
        return const Color(0xFF3B82F6);
      case ExpenseCategory.food:
        return const Color(0xFFF59E0B);
      case ExpenseCategory.accommodation:
        return const Color(0xFF8B5CF6);
      case ExpenseCategory.transport:
        return const Color(0xFF06B6D4);
      case ExpenseCategory.office:
        return const Color(0xFF6366F1);
      case ExpenseCategory.software:
        return const Color(0xFF14B8A6);
      case ExpenseCategory.communication:
        return const Color(0xFFEC4899);
      case ExpenseCategory.medical:
        return const Color(0xFFEF4444);
      case ExpenseCategory.general:
        return const Color(0xFF64748B);
    }
  }

  String get dbKey => name;

  factory ExpenseCategory.fromDbKey(String key) {
    return ExpenseCategory.values.firstWhere(
      (c) => c.name == key,
      orElse: () => ExpenseCategory.general,
    );
  }
}
