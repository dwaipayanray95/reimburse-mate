import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reimburse_mate/core/database/app_database.dart';
import 'package:reimburse_mate/features/claims/application/claims_notifier.dart';
import 'package:reimburse_mate/features/filing/data/csv_service.dart';
import 'package:reimburse_mate/features/filing/data/email_service.dart';
import 'package:reimburse_mate/features/filing/data/zip_export_service.dart';
import 'package:reimburse_mate/models/claim_status.dart';

enum FilingStateStatus { idle, generating, launching, completed, error }

class FilingState {
  final FilingStateStatus status;
  final String? errorMessage;
  final int missingAttachmentCount;

  FilingState({required this.status, this.errorMessage, this.missingAttachmentCount = 0});
}

class FilingNotifier extends StateNotifier<FilingState> {
  final ZipExportService _zipService;
  final EmailService _emailService;
  final ClaimsNotifier _claimsNotifier;

  FilingNotifier(this._zipService, this._emailService, this._claimsNotifier)
      : super(FilingState(status: FilingStateStatus.idle));

  Future<void> fileClaims({
    required List<Reimbursement> claims,
    required String recipient,
    required String body,
    required String subject,
    required bool attachZip,
    required bool exportOnly,
  }) async {
    state = FilingState(status: FilingStateStatus.generating);
    try {
      final zipResult = await _zipService.createReimbursementsZip(claims);
      if (zipResult == null) {
        state = FilingState(status: FilingStateStatus.error, errorMessage: 'Failed to create export archive.');
        return;
      }
      final zipFile = zipResult.zipFile;

      if (exportOnly) {
        state = FilingState(status: FilingStateStatus.launching);
        await _emailService.shareZipOnly(zipFile.path);
        // A local "Save ZIP" export is just a backup — it doesn't mean the
        // claim has actually been filed, so status is intentionally left
        // untouched here (unlike the "Send via Mail" path below).
      } else {
        state = FilingState(status: FilingStateStatus.launching);

        // Assemble attachments
        final List<String> attachments = [];
        if (attachZip) {
          attachments.add(zipFile.path);
        } else {
          // Generate CSV only as standalone attachment
          final csvStr = CsvService().generateCsv(claims);
          final tempDir = Directory.systemTemp;
          final csvFile = File('${tempDir.path}/claims_summary.csv');
          await csvFile.writeAsString(csvStr);
          attachments.add(csvFile.path);
        }

        await _emailService.sendEmailWithAttachments(
          recipients: [recipient],
          cc: [],
          subject: subject,
          body: body,
          attachmentPaths: attachments,
        );

        // Mark claims as submitted only for an actual filing send.
        final ids = claims.map((c) => c.id).toList();
        await _claimsNotifier.batchUpdateStatus(ids, ClaimStatus.submitted);
      }

      state = FilingState(
        status: FilingStateStatus.completed,
        missingAttachmentCount: zipResult.missingAttachmentCount,
      );
    } catch (e) {
      state = FilingState(status: FilingStateStatus.error, errorMessage: e.toString());
    }
  }

  void reset() {
    state = FilingState(status: FilingStateStatus.idle);
  }
}
