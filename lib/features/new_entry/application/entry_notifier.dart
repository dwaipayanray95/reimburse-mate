import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reimburse_mate/core/database/app_database.dart';
import 'package:reimburse_mate/features/claims/data/claims_repository.dart';
import 'package:uuid/uuid.dart';

class EntryNotifier extends StateNotifier<bool> {
  final ClaimsRepository _repository;

  EntryNotifier(this._repository) : super(false);

  Future<bool> saveClaim({
    required DateTime date,
    required String projectCode,
    required String particulars,
    required String note,
    required String category,
    required double amount,
    required String currency,
    required String status,
    required String? invoicePath,
    required String? invoiceFileType,
    required String? paymentPath,
    required String? paymentFileType,
    required String paymentMethod,
    double? latitude,
    double? longitude,
    String? placeName,
  }) async {
    state = true;
    try {
      final now = DateTime.now();
      final claim = Reimbursement(
        id: const Uuid().v4(),
        date: date,
        projectCode: projectCode,
        particulars: particulars,
        note: note,
        category: category,
        status: status,
        amount: amount,
        currency: currency,
        invoicePath: invoicePath,
        invoiceFileType: invoiceFileType,
        paymentPath: paymentPath,
        paymentFileType: paymentFileType,
        paymentMethod: paymentMethod,
        latitude: latitude,
        longitude: longitude,
        placeName: placeName,
        createdAt: now,
        updatedAt: now,
      );

      await _repository.insertClaim(claim);
      state = false;
      return true;
    } catch (_) {
      state = false;
      return false;
    }
  }
}
