import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reimburse_mate/features/ocr/data/ocr_service.dart';
import 'package:reimburse_mate/models/ocr_result.dart';

abstract class OcrState {
  const OcrState();
}

class OcrIdle extends OcrState {
  const OcrIdle();
}

class OcrProcessing extends OcrState {
  const OcrProcessing();
}

class OcrDone extends OcrState {
  final OcrResult result;
  const OcrDone(this.result);
}

class OcrError extends OcrState {
  final String message;
  const OcrError(this.message);
}

class OcrNotifier extends StateNotifier<OcrState> {
  final OcrService _ocrService;

  OcrNotifier(this._ocrService) : super(const OcrIdle());

  Future<void> scanImage(String path) async {
    state = const OcrProcessing();
    try {
      final result = await _ocrService.processImage(path);
      state = OcrDone(result);
    } catch (e) {
      state = OcrError(e.toString());
    }
  }

  void reset() {
    state = const OcrIdle();
  }
}
