import 'package:flutter/material.dart';

enum PaymentMethod {
  upi('UPI', Icons.qr_code_rounded, 'upi'),
  bankTransfer('Bank Transfer', Icons.account_balance_rounded, 'bank_transfer'),
  card('Card', Icons.credit_card_rounded, 'card'),
  cash('Cash', Icons.payments_rounded, 'cash');

  final String label;
  final IconData icon;
  final String dbKey;

  const PaymentMethod(this.label, this.icon, this.dbKey);

  bool get requiresPaymentProof => this != PaymentMethod.cash;

  factory PaymentMethod.fromDbKey(String key) {
    return PaymentMethod.values.firstWhere(
      (m) => m.dbKey == key,
      orElse: () => PaymentMethod.upi,
    );
  }
}
