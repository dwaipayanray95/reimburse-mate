import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reimburse_mate/core/database/app_database.dart';
import 'package:reimburse_mate/features/claims/data/claims_repository.dart';
import 'package:reimburse_mate/models/claim_status.dart';

class ClaimsNotifier extends StateNotifier<AsyncValue<List<Reimbursement>>> {
  final ClaimsRepository _repository;

  ClaimsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadClaims();
  }

  Future<void> loadClaims() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repository.getAllClaims();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addClaim(Reimbursement claim) async {
    await _repository.insertClaim(claim);
    await loadClaims();
  }

  Future<void> updateClaim(Reimbursement claim) async {
    await _repository.updateClaim(claim);
    await loadClaims();
  }

  Future<void> deleteClaim(String id) async {
    await _repository.deleteClaim(id);
    await loadClaims();
  }

  Future<void> updateStatus(String id, ClaimStatus status) async {
    final submittedAt = status == ClaimStatus.submitted ? DateTime.now() : null;
    await _repository.updateStatus(id, status.dbKey, submittedAt: submittedAt);
    await loadClaims();
  }

  Future<void> batchUpdateStatus(List<String> ids, ClaimStatus status) async {
    final submittedAt = status == ClaimStatus.submitted ? DateTime.now() : null;
    await _repository.batchUpdateStatus(ids, status.dbKey, submittedAt: submittedAt);
    await loadClaims();
  }

  Future<void> batchDelete(List<String> ids) async {
    await _repository.batchDelete(ids);
    await loadClaims();
  }
}
