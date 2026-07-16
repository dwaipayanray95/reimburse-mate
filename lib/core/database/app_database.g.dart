// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ReimbursementsTable extends Reimbursements
    with TableInfo<$ReimbursementsTable, Reimbursement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReimbursementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _projectCodeMeta =
      const VerificationMeta('projectCode');
  @override
  late final GeneratedColumn<String> projectCode = GeneratedColumn<String>(
      'project_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _particularsMeta =
      const VerificationMeta('particulars');
  @override
  late final GeneratedColumn<String> particulars = GeneratedColumn<String>(
      'particulars', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('general'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('draft'));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('INR'));
  static const VerificationMeta _invoicePathMeta =
      const VerificationMeta('invoicePath');
  @override
  late final GeneratedColumn<String> invoicePath = GeneratedColumn<String>(
      'invoice_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _invoiceFileTypeMeta =
      const VerificationMeta('invoiceFileType');
  @override
  late final GeneratedColumn<String> invoiceFileType = GeneratedColumn<String>(
      'invoice_file_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _paymentPathMeta =
      const VerificationMeta('paymentPath');
  @override
  late final GeneratedColumn<String> paymentPath = GeneratedColumn<String>(
      'payment_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _paymentFileTypeMeta =
      const VerificationMeta('paymentFileType');
  @override
  late final GeneratedColumn<String> paymentFileType = GeneratedColumn<String>(
      'payment_file_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _paymentMethodMeta =
      const VerificationMeta('paymentMethod');
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
      'payment_method', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('upi'));
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _placeNameMeta =
      const VerificationMeta('placeName');
  @override
  late final GeneratedColumn<String> placeName = GeneratedColumn<String>(
      'place_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _submittedAtMeta =
      const VerificationMeta('submittedAt');
  @override
  late final GeneratedColumn<DateTime> submittedAt = GeneratedColumn<DateTime>(
      'submitted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        date,
        projectCode,
        particulars,
        note,
        category,
        status,
        amount,
        currency,
        invoicePath,
        invoiceFileType,
        paymentPath,
        paymentFileType,
        paymentMethod,
        latitude,
        longitude,
        placeName,
        createdAt,
        updatedAt,
        submittedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reimbursements';
  @override
  VerificationContext validateIntegrity(Insertable<Reimbursement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('project_code')) {
      context.handle(
          _projectCodeMeta,
          projectCode.isAcceptableOrUnknown(
              data['project_code']!, _projectCodeMeta));
    } else if (isInserting) {
      context.missing(_projectCodeMeta);
    }
    if (data.containsKey('particulars')) {
      context.handle(
          _particularsMeta,
          particulars.isAcceptableOrUnknown(
              data['particulars']!, _particularsMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('invoice_path')) {
      context.handle(
          _invoicePathMeta,
          invoicePath.isAcceptableOrUnknown(
              data['invoice_path']!, _invoicePathMeta));
    }
    if (data.containsKey('invoice_file_type')) {
      context.handle(
          _invoiceFileTypeMeta,
          invoiceFileType.isAcceptableOrUnknown(
              data['invoice_file_type']!, _invoiceFileTypeMeta));
    }
    if (data.containsKey('payment_path')) {
      context.handle(
          _paymentPathMeta,
          paymentPath.isAcceptableOrUnknown(
              data['payment_path']!, _paymentPathMeta));
    }
    if (data.containsKey('payment_file_type')) {
      context.handle(
          _paymentFileTypeMeta,
          paymentFileType.isAcceptableOrUnknown(
              data['payment_file_type']!, _paymentFileTypeMeta));
    }
    if (data.containsKey('payment_method')) {
      context.handle(
          _paymentMethodMeta,
          paymentMethod.isAcceptableOrUnknown(
              data['payment_method']!, _paymentMethodMeta));
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    }
    if (data.containsKey('place_name')) {
      context.handle(_placeNameMeta,
          placeName.isAcceptableOrUnknown(data['place_name']!, _placeNameMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('submitted_at')) {
      context.handle(
          _submittedAtMeta,
          submittedAt.isAcceptableOrUnknown(
              data['submitted_at']!, _submittedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reimbursement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reimbursement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      projectCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_code'])!,
      particulars: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}particulars'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount']),
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      invoicePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_path']),
      invoiceFileType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}invoice_file_type']),
      paymentPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_path']),
      paymentFileType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}payment_file_type']),
      paymentMethod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_method'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
      placeName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}place_name']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      submittedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}submitted_at']),
    );
  }

  @override
  $ReimbursementsTable createAlias(String alias) {
    return $ReimbursementsTable(attachedDatabase, alias);
  }
}

class Reimbursement extends DataClass implements Insertable<Reimbursement> {
  final String id;
  final DateTime date;
  final String projectCode;
  final String particulars;
  final String note;
  final String category;
  final String status;
  final double? amount;
  final String currency;
  final String? invoicePath;
  final String? invoiceFileType;
  final String? paymentPath;
  final String? paymentFileType;
  final String paymentMethod;
  final double? latitude;
  final double? longitude;
  final String? placeName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? submittedAt;
  const Reimbursement(
      {required this.id,
      required this.date,
      required this.projectCode,
      required this.particulars,
      required this.note,
      required this.category,
      required this.status,
      this.amount,
      required this.currency,
      this.invoicePath,
      this.invoiceFileType,
      this.paymentPath,
      this.paymentFileType,
      required this.paymentMethod,
      this.latitude,
      this.longitude,
      this.placeName,
      required this.createdAt,
      required this.updatedAt,
      this.submittedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    map['project_code'] = Variable<String>(projectCode);
    map['particulars'] = Variable<String>(particulars);
    map['note'] = Variable<String>(note);
    map['category'] = Variable<String>(category);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<double>(amount);
    }
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || invoicePath != null) {
      map['invoice_path'] = Variable<String>(invoicePath);
    }
    if (!nullToAbsent || invoiceFileType != null) {
      map['invoice_file_type'] = Variable<String>(invoiceFileType);
    }
    if (!nullToAbsent || paymentPath != null) {
      map['payment_path'] = Variable<String>(paymentPath);
    }
    if (!nullToAbsent || paymentFileType != null) {
      map['payment_file_type'] = Variable<String>(paymentFileType);
    }
    map['payment_method'] = Variable<String>(paymentMethod);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || placeName != null) {
      map['place_name'] = Variable<String>(placeName);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || submittedAt != null) {
      map['submitted_at'] = Variable<DateTime>(submittedAt);
    }
    return map;
  }

  ReimbursementsCompanion toCompanion(bool nullToAbsent) {
    return ReimbursementsCompanion(
      id: Value(id),
      date: Value(date),
      projectCode: Value(projectCode),
      particulars: Value(particulars),
      note: Value(note),
      category: Value(category),
      status: Value(status),
      amount:
          amount == null && nullToAbsent ? const Value.absent() : Value(amount),
      currency: Value(currency),
      invoicePath: invoicePath == null && nullToAbsent
          ? const Value.absent()
          : Value(invoicePath),
      invoiceFileType: invoiceFileType == null && nullToAbsent
          ? const Value.absent()
          : Value(invoiceFileType),
      paymentPath: paymentPath == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentPath),
      paymentFileType: paymentFileType == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentFileType),
      paymentMethod: Value(paymentMethod),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      placeName: placeName == null && nullToAbsent
          ? const Value.absent()
          : Value(placeName),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      submittedAt: submittedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(submittedAt),
    );
  }

  factory Reimbursement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reimbursement(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      projectCode: serializer.fromJson<String>(json['projectCode']),
      particulars: serializer.fromJson<String>(json['particulars']),
      note: serializer.fromJson<String>(json['note']),
      category: serializer.fromJson<String>(json['category']),
      status: serializer.fromJson<String>(json['status']),
      amount: serializer.fromJson<double?>(json['amount']),
      currency: serializer.fromJson<String>(json['currency']),
      invoicePath: serializer.fromJson<String?>(json['invoicePath']),
      invoiceFileType: serializer.fromJson<String?>(json['invoiceFileType']),
      paymentPath: serializer.fromJson<String?>(json['paymentPath']),
      paymentFileType: serializer.fromJson<String?>(json['paymentFileType']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      placeName: serializer.fromJson<String?>(json['placeName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      submittedAt: serializer.fromJson<DateTime?>(json['submittedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'projectCode': serializer.toJson<String>(projectCode),
      'particulars': serializer.toJson<String>(particulars),
      'note': serializer.toJson<String>(note),
      'category': serializer.toJson<String>(category),
      'status': serializer.toJson<String>(status),
      'amount': serializer.toJson<double?>(amount),
      'currency': serializer.toJson<String>(currency),
      'invoicePath': serializer.toJson<String?>(invoicePath),
      'invoiceFileType': serializer.toJson<String?>(invoiceFileType),
      'paymentPath': serializer.toJson<String?>(paymentPath),
      'paymentFileType': serializer.toJson<String?>(paymentFileType),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'placeName': serializer.toJson<String?>(placeName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'submittedAt': serializer.toJson<DateTime?>(submittedAt),
    };
  }

  Reimbursement copyWith(
          {String? id,
          DateTime? date,
          String? projectCode,
          String? particulars,
          String? note,
          String? category,
          String? status,
          Value<double?> amount = const Value.absent(),
          String? currency,
          Value<String?> invoicePath = const Value.absent(),
          Value<String?> invoiceFileType = const Value.absent(),
          Value<String?> paymentPath = const Value.absent(),
          Value<String?> paymentFileType = const Value.absent(),
          String? paymentMethod,
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent(),
          Value<String?> placeName = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> submittedAt = const Value.absent()}) =>
      Reimbursement(
        id: id ?? this.id,
        date: date ?? this.date,
        projectCode: projectCode ?? this.projectCode,
        particulars: particulars ?? this.particulars,
        note: note ?? this.note,
        category: category ?? this.category,
        status: status ?? this.status,
        amount: amount.present ? amount.value : this.amount,
        currency: currency ?? this.currency,
        invoicePath: invoicePath.present ? invoicePath.value : this.invoicePath,
        invoiceFileType: invoiceFileType.present
            ? invoiceFileType.value
            : this.invoiceFileType,
        paymentPath: paymentPath.present ? paymentPath.value : this.paymentPath,
        paymentFileType: paymentFileType.present
            ? paymentFileType.value
            : this.paymentFileType,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
        placeName: placeName.present ? placeName.value : this.placeName,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        submittedAt: submittedAt.present ? submittedAt.value : this.submittedAt,
      );
  Reimbursement copyWithCompanion(ReimbursementsCompanion data) {
    return Reimbursement(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      projectCode:
          data.projectCode.present ? data.projectCode.value : this.projectCode,
      particulars:
          data.particulars.present ? data.particulars.value : this.particulars,
      note: data.note.present ? data.note.value : this.note,
      category: data.category.present ? data.category.value : this.category,
      status: data.status.present ? data.status.value : this.status,
      amount: data.amount.present ? data.amount.value : this.amount,
      currency: data.currency.present ? data.currency.value : this.currency,
      invoicePath:
          data.invoicePath.present ? data.invoicePath.value : this.invoicePath,
      invoiceFileType: data.invoiceFileType.present
          ? data.invoiceFileType.value
          : this.invoiceFileType,
      paymentPath:
          data.paymentPath.present ? data.paymentPath.value : this.paymentPath,
      paymentFileType: data.paymentFileType.present
          ? data.paymentFileType.value
          : this.paymentFileType,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      placeName: data.placeName.present ? data.placeName.value : this.placeName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      submittedAt:
          data.submittedAt.present ? data.submittedAt.value : this.submittedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reimbursement(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('projectCode: $projectCode, ')
          ..write('particulars: $particulars, ')
          ..write('note: $note, ')
          ..write('category: $category, ')
          ..write('status: $status, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('invoicePath: $invoicePath, ')
          ..write('invoiceFileType: $invoiceFileType, ')
          ..write('paymentPath: $paymentPath, ')
          ..write('paymentFileType: $paymentFileType, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('placeName: $placeName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('submittedAt: $submittedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      date,
      projectCode,
      particulars,
      note,
      category,
      status,
      amount,
      currency,
      invoicePath,
      invoiceFileType,
      paymentPath,
      paymentFileType,
      paymentMethod,
      latitude,
      longitude,
      placeName,
      createdAt,
      updatedAt,
      submittedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reimbursement &&
          other.id == this.id &&
          other.date == this.date &&
          other.projectCode == this.projectCode &&
          other.particulars == this.particulars &&
          other.note == this.note &&
          other.category == this.category &&
          other.status == this.status &&
          other.amount == this.amount &&
          other.currency == this.currency &&
          other.invoicePath == this.invoicePath &&
          other.invoiceFileType == this.invoiceFileType &&
          other.paymentPath == this.paymentPath &&
          other.paymentFileType == this.paymentFileType &&
          other.paymentMethod == this.paymentMethod &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.placeName == this.placeName &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.submittedAt == this.submittedAt);
}

class ReimbursementsCompanion extends UpdateCompanion<Reimbursement> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<String> projectCode;
  final Value<String> particulars;
  final Value<String> note;
  final Value<String> category;
  final Value<String> status;
  final Value<double?> amount;
  final Value<String> currency;
  final Value<String?> invoicePath;
  final Value<String?> invoiceFileType;
  final Value<String?> paymentPath;
  final Value<String?> paymentFileType;
  final Value<String> paymentMethod;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> placeName;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> submittedAt;
  final Value<int> rowid;
  const ReimbursementsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.projectCode = const Value.absent(),
    this.particulars = const Value.absent(),
    this.note = const Value.absent(),
    this.category = const Value.absent(),
    this.status = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.invoicePath = const Value.absent(),
    this.invoiceFileType = const Value.absent(),
    this.paymentPath = const Value.absent(),
    this.paymentFileType = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.placeName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReimbursementsCompanion.insert({
    required String id,
    required DateTime date,
    required String projectCode,
    this.particulars = const Value.absent(),
    this.note = const Value.absent(),
    this.category = const Value.absent(),
    this.status = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.invoicePath = const Value.absent(),
    this.invoiceFileType = const Value.absent(),
    this.paymentPath = const Value.absent(),
    this.paymentFileType = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.placeName = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.submittedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        date = Value(date),
        projectCode = Value(projectCode),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Reimbursement> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<String>? projectCode,
    Expression<String>? particulars,
    Expression<String>? note,
    Expression<String>? category,
    Expression<String>? status,
    Expression<double>? amount,
    Expression<String>? currency,
    Expression<String>? invoicePath,
    Expression<String>? invoiceFileType,
    Expression<String>? paymentPath,
    Expression<String>? paymentFileType,
    Expression<String>? paymentMethod,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? placeName,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? submittedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (projectCode != null) 'project_code': projectCode,
      if (particulars != null) 'particulars': particulars,
      if (note != null) 'note': note,
      if (category != null) 'category': category,
      if (status != null) 'status': status,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (invoicePath != null) 'invoice_path': invoicePath,
      if (invoiceFileType != null) 'invoice_file_type': invoiceFileType,
      if (paymentPath != null) 'payment_path': paymentPath,
      if (paymentFileType != null) 'payment_file_type': paymentFileType,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (placeName != null) 'place_name': placeName,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (submittedAt != null) 'submitted_at': submittedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReimbursementsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? date,
      Value<String>? projectCode,
      Value<String>? particulars,
      Value<String>? note,
      Value<String>? category,
      Value<String>? status,
      Value<double?>? amount,
      Value<String>? currency,
      Value<String?>? invoicePath,
      Value<String?>? invoiceFileType,
      Value<String?>? paymentPath,
      Value<String?>? paymentFileType,
      Value<String>? paymentMethod,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<String?>? placeName,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? submittedAt,
      Value<int>? rowid}) {
    return ReimbursementsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      projectCode: projectCode ?? this.projectCode,
      particulars: particulars ?? this.particulars,
      note: note ?? this.note,
      category: category ?? this.category,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      invoicePath: invoicePath ?? this.invoicePath,
      invoiceFileType: invoiceFileType ?? this.invoiceFileType,
      paymentPath: paymentPath ?? this.paymentPath,
      paymentFileType: paymentFileType ?? this.paymentFileType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeName: placeName ?? this.placeName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (projectCode.present) {
      map['project_code'] = Variable<String>(projectCode.value);
    }
    if (particulars.present) {
      map['particulars'] = Variable<String>(particulars.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (invoicePath.present) {
      map['invoice_path'] = Variable<String>(invoicePath.value);
    }
    if (invoiceFileType.present) {
      map['invoice_file_type'] = Variable<String>(invoiceFileType.value);
    }
    if (paymentPath.present) {
      map['payment_path'] = Variable<String>(paymentPath.value);
    }
    if (paymentFileType.present) {
      map['payment_file_type'] = Variable<String>(paymentFileType.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (placeName.present) {
      map['place_name'] = Variable<String>(placeName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (submittedAt.present) {
      map['submitted_at'] = Variable<DateTime>(submittedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReimbursementsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('projectCode: $projectCode, ')
          ..write('particulars: $particulars, ')
          ..write('note: $note, ')
          ..write('category: $category, ')
          ..write('status: $status, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('invoicePath: $invoicePath, ')
          ..write('invoiceFileType: $invoiceFileType, ')
          ..write('paymentPath: $paymentPath, ')
          ..write('paymentFileType: $paymentFileType, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('placeName: $placeName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ReimbursementsTable reimbursements = $ReimbursementsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [reimbursements];
}

typedef $$ReimbursementsTableCreateCompanionBuilder = ReimbursementsCompanion
    Function({
  required String id,
  required DateTime date,
  required String projectCode,
  Value<String> particulars,
  Value<String> note,
  Value<String> category,
  Value<String> status,
  Value<double?> amount,
  Value<String> currency,
  Value<String?> invoicePath,
  Value<String?> invoiceFileType,
  Value<String?> paymentPath,
  Value<String?> paymentFileType,
  Value<String> paymentMethod,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String?> placeName,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> submittedAt,
  Value<int> rowid,
});
typedef $$ReimbursementsTableUpdateCompanionBuilder = ReimbursementsCompanion
    Function({
  Value<String> id,
  Value<DateTime> date,
  Value<String> projectCode,
  Value<String> particulars,
  Value<String> note,
  Value<String> category,
  Value<String> status,
  Value<double?> amount,
  Value<String> currency,
  Value<String?> invoicePath,
  Value<String?> invoiceFileType,
  Value<String?> paymentPath,
  Value<String?> paymentFileType,
  Value<String> paymentMethod,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String?> placeName,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> submittedAt,
  Value<int> rowid,
});

class $$ReimbursementsTableFilterComposer
    extends Composer<_$AppDatabase, $ReimbursementsTable> {
  $$ReimbursementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectCode => $composableBuilder(
      column: $table.projectCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get particulars => $composableBuilder(
      column: $table.particulars, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get invoicePath => $composableBuilder(
      column: $table.invoicePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get invoiceFileType => $composableBuilder(
      column: $table.invoiceFileType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentPath => $composableBuilder(
      column: $table.paymentPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentFileType => $composableBuilder(
      column: $table.paymentFileType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get placeName => $composableBuilder(
      column: $table.placeName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get submittedAt => $composableBuilder(
      column: $table.submittedAt, builder: (column) => ColumnFilters(column));
}

class $$ReimbursementsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReimbursementsTable> {
  $$ReimbursementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectCode => $composableBuilder(
      column: $table.projectCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get particulars => $composableBuilder(
      column: $table.particulars, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get invoicePath => $composableBuilder(
      column: $table.invoicePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get invoiceFileType => $composableBuilder(
      column: $table.invoiceFileType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentPath => $composableBuilder(
      column: $table.paymentPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentFileType => $composableBuilder(
      column: $table.paymentFileType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get placeName => $composableBuilder(
      column: $table.placeName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get submittedAt => $composableBuilder(
      column: $table.submittedAt, builder: (column) => ColumnOrderings(column));
}

class $$ReimbursementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReimbursementsTable> {
  $$ReimbursementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get projectCode => $composableBuilder(
      column: $table.projectCode, builder: (column) => column);

  GeneratedColumn<String> get particulars => $composableBuilder(
      column: $table.particulars, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get invoicePath => $composableBuilder(
      column: $table.invoicePath, builder: (column) => column);

  GeneratedColumn<String> get invoiceFileType => $composableBuilder(
      column: $table.invoiceFileType, builder: (column) => column);

  GeneratedColumn<String> get paymentPath => $composableBuilder(
      column: $table.paymentPath, builder: (column) => column);

  GeneratedColumn<String> get paymentFileType => $composableBuilder(
      column: $table.paymentFileType, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get placeName =>
      $composableBuilder(column: $table.placeName, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get submittedAt => $composableBuilder(
      column: $table.submittedAt, builder: (column) => column);
}

class $$ReimbursementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReimbursementsTable,
    Reimbursement,
    $$ReimbursementsTableFilterComposer,
    $$ReimbursementsTableOrderingComposer,
    $$ReimbursementsTableAnnotationComposer,
    $$ReimbursementsTableCreateCompanionBuilder,
    $$ReimbursementsTableUpdateCompanionBuilder,
    (
      Reimbursement,
      BaseReferences<_$AppDatabase, $ReimbursementsTable, Reimbursement>
    ),
    Reimbursement,
    PrefetchHooks Function()> {
  $$ReimbursementsTableTableManager(
      _$AppDatabase db, $ReimbursementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReimbursementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReimbursementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReimbursementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> projectCode = const Value.absent(),
            Value<String> particulars = const Value.absent(),
            Value<String> note = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<double?> amount = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<String?> invoicePath = const Value.absent(),
            Value<String?> invoiceFileType = const Value.absent(),
            Value<String?> paymentPath = const Value.absent(),
            Value<String?> paymentFileType = const Value.absent(),
            Value<String> paymentMethod = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String?> placeName = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> submittedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReimbursementsCompanion(
            id: id,
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
            createdAt: createdAt,
            updatedAt: updatedAt,
            submittedAt: submittedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime date,
            required String projectCode,
            Value<String> particulars = const Value.absent(),
            Value<String> note = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<double?> amount = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<String?> invoicePath = const Value.absent(),
            Value<String?> invoiceFileType = const Value.absent(),
            Value<String?> paymentPath = const Value.absent(),
            Value<String?> paymentFileType = const Value.absent(),
            Value<String> paymentMethod = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String?> placeName = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> submittedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReimbursementsCompanion.insert(
            id: id,
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
            createdAt: createdAt,
            updatedAt: updatedAt,
            submittedAt: submittedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReimbursementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReimbursementsTable,
    Reimbursement,
    $$ReimbursementsTableFilterComposer,
    $$ReimbursementsTableOrderingComposer,
    $$ReimbursementsTableAnnotationComposer,
    $$ReimbursementsTableCreateCompanionBuilder,
    $$ReimbursementsTableUpdateCompanionBuilder,
    (
      Reimbursement,
      BaseReferences<_$AppDatabase, $ReimbursementsTable, Reimbursement>
    ),
    Reimbursement,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ReimbursementsTableTableManager get reimbursements =>
      $$ReimbursementsTableTableManager(_db, _db.reimbursements);
}
