import 'package:csv/csv.dart';
import 'package:reimburse_mate/core/database/app_database.dart';

class CsvService {
  String generateCsv(List<Reimbursement> items) {
    final headers = [
      'ID',
      'Date',
      'Project Code',
      'Particulars',
      'Notes',
      'Category',
      'Amount',
      'Currency',
      'Payment Method',
      'Status',
      'Location',
      'Submitted At'
    ];

    final rows = items.map((item) {
      return [
        item.id,
        item.date.toIso8601String(),
        item.projectCode,
        item.particulars,
        item.note,
        item.category,
        item.amount ?? 0.0,
        item.currency,
        item.paymentMethod,
        item.status,
        item.placeName ?? (item.latitude != null ? '${item.latitude}, ${item.longitude}' : ''),
        item.submittedAt?.toIso8601String() ?? '',
      ];
    }).toList();

    // Excel compatibility prefix (UTF-8 BOM)
    final csvString = const ListToCsvConverter().convert([headers, ...rows]);
    return '\uFEFF$csvString';
  }
}
