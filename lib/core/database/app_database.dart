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

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'reimbursements.db'));
    return NativeDatabase.createInBackground(file);
  });
}
