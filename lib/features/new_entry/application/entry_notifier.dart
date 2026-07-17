import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reimburse_mate/core/database/app_database.dart';
import 'package:reimburse_mate/features/claims/data/claims_repository.dart';
import 'package:uuid/uuid.dart';

class EntrySaveState {
  final bool isSaving;
  final String? errorMessage;

  const EntrySaveState({this.isSaving = false, this.errorMessage});
}

class EntryNotifier extends StateNotifier<EntrySaveState> {
  final ClaimsRepository _repository;

  EntryNotifier(this._repository) : super(const EntrySaveState());

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
    state = const EntrySaveState(isSaving: true);
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
      state = const EntrySaveState(isSaving: false);
      return true;
    } catch (e) {
      state = EntrySaveState(isSaving: false, errorMessage: 'Could not save claim: $e');
      return false;
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = const EntrySaveState();
    }
  }
}
