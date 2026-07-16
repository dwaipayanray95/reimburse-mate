import 'dart:io';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:share_plus/share_plus.dart';

class EmailService {
  Future<bool> sendEmailWithAttachments({
    required List<String> recipients,
    required List<String> cc,
    required String subject,
    required String body,
    required List<String> attachmentPaths,
  }) async {
    try {
      final email = Email(
        body: body,
        subject: subject,
        recipients: recipients,
        cc: cc,
        attachmentPaths: attachmentPaths,
        isHTML: false,
      );

      await FlutterEmailSender.send(email);
      return true;
    } catch (_) {
      // Fallback to share sheet if native email compose fails
      if (attachmentPaths.isNotEmpty) {
        final xFiles = attachmentPaths.map((path) => XFile(path)).toList();
        await Share.shareXFiles(xFiles, text: subject);
        return true;
      }
      return false;
    }
  }

  Future<void> shareZipOnly(String zipPath) async {
    await Share.shareXFiles([XFile(zipPath)], text: 'Reimbursement Claims Export');
  }
}
