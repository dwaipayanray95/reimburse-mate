import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:reimburse_mate/core/database/app_database.dart';
import 'csv_service.dart';

class ZipExportService {
  final CsvService _csvService = CsvService();

  Future<File?> createReimbursementsZip(List<Reimbursement> items) async {
    if (items.isEmpty) return null;

    try {
      final archive = Archive();

      // 1. Add CSV
      final csvString = _csvService.generateCsv(items);
      final csvData = utf8.encode(csvString);
      archive.addFile(ArchiveFile('reimbursements.csv', csvData.length, csvData));

      // 2. Add individual invoice and payment receipt files
      for (final item in items) {
        final dateStr = item.date.toIso8601String().split('T').first;
        final cleanProj = item.projectCode.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
        final prefix = '${cleanProj}_${dateStr}_${item.id.substring(0, 6)}';

        // Add invoice file
        if (item.invoicePath != null) {
          final file = File(item.invoicePath!);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            final isPdf = item.invoiceFileType == 'pdf';
            archive.addFile(ArchiveFile('$prefix-invoice.${isPdf ? 'pdf' : 'jpg'}', bytes.length, bytes));
          }
        }

        // Add payment receipt file
        if (item.paymentPath != null) {
          final file = File(item.paymentPath!);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            final isPdf = item.paymentFileType == 'pdf';
            archive.addFile(ArchiveFile('$prefix-payment.${isPdf ? 'pdf' : 'jpg'}', bytes.length, bytes));
          }
        }
      }

      // Encode archive to zip format
      final zipEncoder = ZipEncoder();
      final zipBytes = zipEncoder.encode(archive);
      if (zipBytes == null) return null;

      final tempDir = await getTemporaryDirectory();
      final zipFile = File(p.join(tempDir.path, 'claims_export_${DateTime.now().millisecondsSinceEpoch}.zip'));
      await zipFile.writeAsBytes(zipBytes);

      return zipFile;
    } catch (_) {
      return null;
    }
  }
}
