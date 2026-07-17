import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reimburse_mate/features/ocr/data/ocr_service.dart';
import 'package:reimburse_mate/models/ocr_result.dart';

/// Which attachment slot a scan applies to, so results are never applied
/// to the wrong field (e.g. a payment-proof scan overwriting invoice data).
enum OcrTarget { invoice, payment }

abstract class OcrState {
  const OcrState();
}

class OcrIdle extends OcrState {
  const OcrIdle();
}

class OcrProcessing extends OcrState {
  final OcrTarget target;
  const OcrProcessing(this.target);
}

class OcrDone extends OcrState {
  final OcrResult result;
  final OcrTarget target;
  const OcrDone(this.result, this.target);
}

class OcrError extends OcrState {
  final String message;
  final OcrTarget target;
  const OcrError(this.message, this.target);
}

class OcrNotifier extends StateNotifier<OcrState> {
  final OcrService _ocrService;

  OcrNotifier(this._ocrService) : super(const OcrIdle());

  Future<void> scanImage(String path, OcrTarget target) async {
    // Don't let a second scan clobber an in-flight one — the caller should
    // wait for the current scan (invoice or payment) to finish first.
    if (state is OcrProcessing) return;

    state = OcrProcessing(target);
    try {
      final result = await _ocrService.processImage(path);
      state = OcrDone(result, target);
    } catch (e) {
      state = OcrError(e.toString(), target);
    }
  }

  void reset() {
    state = const OcrIdle();
  }
}
