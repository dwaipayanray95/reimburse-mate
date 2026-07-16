import 'dart:io';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:reimburse_mate/models/ocr_result.dart';

class OcrService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<OcrResult> processImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      final rawText = recognizedText.text;

      double? parsedAmount;
      String? parsedCurrency;
      DateTime? parsedDate;
      String? parsedVendor;

      // Extract Amount & Currency
      // Matches formats like INR 1,500.00, ₹1500, $45.50, USD 120, EUR 12.00, SGD 5.00
      final amountRegex = RegExp(
        r'(?:(INR|USD|EUR|GBP|CAD|AUD|JPY|SGD|₹|\$|€|£|¥))\s*?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
        caseSensitive: false,
      );

      final matches = amountRegex.allMatches(rawText);
      double maxAmount = 0.0;

      for (final match in matches) {
        final currencySymbol = match.group(1);
        final amountStr = match.group(2)?.replaceAll(',', '') ?? '0';
        final val = double.tryParse(amountStr) ?? 0.0;

        // Take the highest amount found on invoice (often representing Total/Grand Total)
        if (val > maxAmount) {
          maxAmount = val;
          parsedAmount = val;
          
          if (currencySymbol == '₹' || currencySymbol?.toUpperCase() == 'INR') {
            parsedCurrency = 'INR';
          } else if (currencySymbol == '\$' || currencySymbol?.toUpperCase() == 'USD') {
            parsedCurrency = 'USD';
          } else if (currencySymbol == '€' || currencySymbol?.toUpperCase() == 'EUR') {
            parsedCurrency = 'EUR';
          } else if (currencySymbol == '£' || currencySymbol?.toUpperCase() == 'GBP') {
            parsedCurrency = 'GBP';
          } else {
            parsedCurrency = currencySymbol?.toUpperCase();
          }
        }
      }

      // Date parsing regex
      final dateRegex = RegExp(
        r'\b(\d{1,2})[-/.](\d{1,2}|\w{3})[-/.](\d{2,4})\b',
        caseSensitive: false,
      );

      final dateMatch = dateRegex.firstMatch(rawText);
      if (dateMatch != null) {
        final dayOrMonth = dateMatch.group(1);
        final monthOrDay = dateMatch.group(2);
        final yearStr = dateMatch.group(3);

        int? day = int.tryParse(dayOrMonth ?? '');
        int? month = int.tryParse(monthOrDay ?? '');
        int year = int.tryParse(yearStr ?? '') ?? DateTime.now().year;
        if (year < 100) year += 2000;

        if (day != null && month != null) {
          // Assume DD/MM/YYYY
          try {
            parsedDate = DateTime(year, month, day);
          } catch (_) {}
        }
      }

      // Simple heuristic for vendor: first non-empty lines
      final lines = rawText.split('\n').where((l) => l.trim().length > 3).toList();
      if (lines.isNotEmpty) {
        // filter out dates, invoice labels, etc.
        for (var line in lines) {
          final l = line.toLowerCase();
          if (!l.contains('invoice') && 
              !l.contains('date') && 
              !l.contains('bill') && 
              !l.contains('tax') && 
              !l.contains('total')) {
            parsedVendor = line.trim();
            break;
          }
        }
      }

      return OcrResult(
        amount: parsedAmount,
        currencyCode: parsedCurrency,
        date: parsedDate,
        vendor: parsedVendor,
        rawText: rawText,
      );
    } catch (e) {
      return OcrResult(rawText: '');
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
