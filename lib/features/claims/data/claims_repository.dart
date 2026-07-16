import 'package:drift/drift.dart';
import 'package:reimburse_mate/core/database/app_database.dart';
import 'package:uuid/uuid.dart';

class ClaimsRepository {
  final AppDatabase _db;

  ClaimsRepository(this._db);

  Future<List<Reimbursement>> getAllClaims() {
    return (_db.select(_db.reimbursements)
          ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
        .get();
  }

  Future<void> insertClaim(Reimbursement claim) {
    return _db.into(_db.reimbursements).insert(claim);
  }

  Future<void> updateClaim(Reimbursement claim) {
    return _db.update(_db.reimbursements).replace(claim);
  }

  Future<void> deleteClaim(String id) {
    return (_db.delete(_db.reimbursements)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updateStatus(String id, String status, {DateTime? submittedAt}) {
    return (_db.update(_db.reimbursements)..where((t) => t.id.equals(id))).write(
      ReimbursementsCompanion(
        status: Value(status),
        submittedAt: Value(submittedAt),
      ),
    );
  }

  Future<void> batchUpdateStatus(List<String> ids, String status, {DateTime? submittedAt}) async {
    await _db.transaction(() async {
      for (final id in ids) {
        await (_db.update(_db.reimbursements)..where((t) => t.id.equals(id))).write(
          ReimbursementsCompanion(
            status: Value(status),
            submittedAt: Value(submittedAt),
          ),
        );
      }
    });
  }

  Future<void> batchDelete(List<String> ids) async {
    await _db.transaction(() async {
      for (final id in ids) {
        await (_db.delete(_db.reimbursements)..where((t) => t.id.equals(id))).go();
      }
    });
  }
}
