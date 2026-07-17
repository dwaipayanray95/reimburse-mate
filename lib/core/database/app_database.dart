import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class Reimbursements extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get projectCode => text()();
  TextColumn get particulars => text().withDefault(const Constant(''))();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get category => text().withDefault(const Constant('general'))();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  RealColumn get amount => real().nullable()();
  TextColumn get currency => text().withDefault(const Constant('INR'))();
  TextColumn get invoicePath => text().nullable()();
  TextColumn get invoiceFileType => text().nullable()(); // 'image' | 'pdf'
  TextColumn get paymentPath => text().nullable()();
  TextColumn get paymentFileType => text().nullable()(); // 'image' | 'pdf'
  TextColumn get paymentMethod => text().withDefault(const Constant('upi'))();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get placeName => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get submittedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Reimbursements])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Bumped from 1 -> 2 to force onUpgrade to run for installs whose local
  // reimbursements.db predates columns like `particulars` (schemaVersion
  // had stayed at 1 even as the table gained columns, so Drift never
  // reconciled the on-disk schema and every insert failed with
  // "table reimbursements has no column named ...").
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) => m.createAll(),
        onUpgrade: (Migrator m, int from, int to) => _reconcileColumns(m),
        // Defensive net: even if a future change forgets to bump
        // schemaVersion, this repairs any missing columns on every launch
        // so local data never silently fails to save again.
        beforeOpen: (details) => _reconcileColumns(Migrator(this)),
      );

  /// Adds any column defined on [reimbursements] that is missing from the
  /// on-disk table, without touching columns/data that already exist.
  Future<void> _reconcileColumns(Migrator m) async {
    final rows = await customSelect('PRAGMA table_info(reimbursements)').get();
    final existingColumns = rows.map((r) => r.data['name'] as String).toSet();
    for (final column in reimbursements.$columns) {
      if (!existingColumns.contains(column.name)) {
        await m.addColumn(reimbursements, column);
      }
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'reimbursements.db'));
    return NativeDatabase.createInBackground(file);
  });
}
