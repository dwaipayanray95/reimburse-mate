import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:reimburse_mate/core/database/app_database.dart';
import 'csv_service.dart';

class ZipExportResult {
  final File zipFile;
  final int missingAttachmentCount;
  ZipExportResult({required this.zipFile, required this.missingAttachmentCount});
}

class ZipExportService {
  final CsvService _csvService = CsvService();

  Future<ZipExportResult?> createReimbursementsZip(List<Reimbursement> items) async {
    if (items.isEmpty) return null;

    final archive = Archive();
    int missingCount = 0;

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
        } else {
          missingCount++;
        }
      }

      // Add payment receipt file
      if (item.paymentPath != null) {
        final file = File(item.paymentPath!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final isPdf = item.paymentFileType == 'pdf';
          archive.addFile(ArchiveFile('$prefix-payment.${isPdf ? 'pdf' : 'jpg'}', bytes.length, bytes));
        } else {
          missingCount++;
        }
      }
    }

    // Encode archive to zip format
    final zipEncoder = ZipEncoder();
    final zipBytes = zipEncoder.encode(archive);
    if (zipBytes == null) {
      throw Exception('Failed to encode the export archive.');
    }

    final tempDir = await getTemporaryDirectory();
    final zipFile = File(p.join(tempDir.path, 'claims_export_${DateTime.now().millisecondsSinceEpoch}.zip'));
    await zipFile.writeAsBytes(zipBytes);

    return ZipExportResult(zipFile: zipFile, missingAttachmentCount: missingCount);
  }
}
