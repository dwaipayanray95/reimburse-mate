class OcrResult {
  final double? amount;
  final String? currencyCode;
  final DateTime? date;
  final String? vendor;
  final String rawText;

  OcrResult({
    this.amount,
    this.currencyCode,
    this.date,
    this.vendor,
    required this.rawText,
  });
}
