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
      String? parsedCurrency = 'INR'; // default fallback
      DateTime? parsedDate;
      String? parsedVendor;

      // Split the text into lines and clean them up
      final lines = rawText.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

      // 1. Context-Aware Vendor Parsing (Heuristics)
      // The vendor name is almost always in the first few lines of text
      for (final line in lines.take(5)) {
        final lowerLine = line.toLowerCase();
        // Skip common meta-information headers
        if (lowerLine.contains('invoice') ||
            lowerLine.contains('receipt') ||
            lowerLine.contains('date') ||
            lowerLine.contains('tax') ||
            lowerLine.contains('bill') ||
            lowerLine.contains('phone') ||
            lowerLine.contains('tel:') ||
            lowerLine.contains('cashier') ||
            RegExp(r'^\d+$').hasMatch(line)) {
          continue;
        }
        parsedVendor = line;
        break;
      }

      // 2. Context-Aware Amount Parsing
      // Look for total/grand total keywords, then inspect subsequent or same lines
      final totalKeywords = RegExp(r'(total|grand\s*total|net\s*amount|amount\s*due|paid|sum|total\s*due)', caseSensitive: false);
      double? bestAmount;

      // First pass: look for monetary symbols (₹, $, €, £, etc.)
      final currencyRegex = RegExp(r'(?:(INR|USD|EUR|GBP|CAD|AUD|JPY|SGD|₹|\$|€|£|¥))\s*?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)', caseSensitive: false);
      final currencyMatches = currencyRegex.allMatches(rawText);
      double maxMonetaryVal = 0.0;
      for (final m in currencyMatches) {
        final symbol = m.group(1);
        final amtStr = m.group(2)?.replaceAll(',', '') ?? '0';
        final val = double.tryParse(amtStr) ?? 0.0;
        if (val > maxMonetaryVal) {
          maxMonetaryVal = val;
          bestAmount = val;
          if (symbol == '₹' || symbol?.toUpperCase() == 'INR') {
            parsedCurrency = 'INR';
          } else if (symbol == '\$' || symbol?.toUpperCase() == 'USD') {
            parsedCurrency = 'USD';
          } else if (symbol == '€' || symbol?.toUpperCase() == 'EUR') {
            parsedCurrency = 'EUR';
          } else if (symbol == '£' || symbol?.toUpperCase() == 'GBP') {
            parsedCurrency = 'GBP';
          } else {
            parsedCurrency = symbol?.toUpperCase();
          }
        }
      }

      // Second pass: if no currency symbol matches, scan lines near "Total" keywords
      if (bestAmount == null || bestAmount == 0.0) {
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (totalKeywords.hasMatch(line)) {
            // Check same line for numbers
            final numRegex = RegExp(r'(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)');
            final match = numRegex.firstMatch(line);
            if (match != null) {
              final val = double.tryParse(match.group(1)!.replaceAll(',', ''));
              if (val != null && val > 0) {
                bestAmount = val;
                break;
              }
            }

            // Check next line if same line has no numbers
            if (i + 1 < lines.length) {
              final nextLine = lines[i + 1];
              final nextMatch = numRegex.firstMatch(nextLine);
              if (nextMatch != null) {
                final val = double.tryParse(nextMatch.group(1)!.replaceAll(',', ''));
                if (val != null && val > 0) {
                  bestAmount = val;
                  break;
                }
              }
            }
          }
        }
      }
      parsedAmount = bestAmount;

      // 3. Context-Aware Date Parsing
      // Matches standard numeric dates: DD/MM/YYYY, DD-MM-YYYY, YYYY-MM-DD
      final numericDateRegex = RegExp(r'\b(\d{1,4})[-/.](\d{1,2})[-/.](\d{2,4})\b');
      final dateMatch = numericDateRegex.firstMatch(rawText);
      if (dateMatch != null) {
        final g1 = int.tryParse(dateMatch.group(1) ?? '');
        final g2 = int.tryParse(dateMatch.group(2) ?? '');
        final g3 = int.tryParse(dateMatch.group(3) ?? '');
        if (g1 != null && g2 != null && g3 != null) {
          try {
            if (g1 > 1000) {
              // YYYY-MM-DD
              parsedDate = DateTime(g1, g2, g3);
            } else if (g3 > 1000) {
              // DD-MM-YYYY or MM-DD-YYYY (assume DD-MM-YYYY first)
              parsedDate = DateTime(g3, g2, g1);
            } else {
              // DD-MM-YY
              parsedDate = DateTime(g3 + 2000, g2, g1);
            }
          } catch (_) {}
        }
      }

      // If numeric date match is not found, try alphanumeric month dates (e.g. 17 Jul 2026)
      if (parsedDate == null) {
        final alphaMonthRegex = RegExp(
          r'\b(\d{1,2})\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+(\d{4})\b',
          caseSensitive: false,
        );
        final alphaMatch = alphaMonthRegex.firstMatch(rawText);
        if (alphaMatch != null) {
          final day = int.tryParse(alphaMatch.group(1) ?? '');
          final monthStr = alphaMatch.group(2)?.toLowerCase();
          final year = int.tryParse(alphaMatch.group(3) ?? '');
          if (day != null && monthStr != null && year != null) {
            const months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
            final monthIdx = months.indexOf(monthStr) + 1;
            if (monthIdx > 0) {
              try {
                parsedDate = DateTime(year, monthIdx, day);
              } catch (_) {}
            }
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
      // Let the caller (OcrNotifier) surface this as OcrError instead of a
      // silently "successful" empty result the UI can't distinguish from
      // a receipt with no readable text.
      throw Exception('Could not read text from this receipt.');
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
