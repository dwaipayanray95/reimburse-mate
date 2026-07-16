import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

enum CustomFileType { image, pdf }

class PickedFileResult {
  final String path;
  final CustomFileType type;
  final int sizeBytes;

  PickedFileResult({
    required this.path,
    required this.type,
    required this.sizeBytes,
  });
}

class FilePickerService {
  final ImagePicker _imagePicker = ImagePicker();

  Future<PickedFileResult?> pickImageOrPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result == null || result.files.isEmpty) return null;
      final file = result.files.first;
      if (file.path == null) return null;

      final extension = p.extension(file.path!).toLowerCase();
      final type = extension == '.pdf' ? CustomFileType.pdf : CustomFileType.image;

      return PickedFileResult(
        path: file.path!,
        type: type,
        sizeBytes: file.size,
      );
    } catch (_) {
      return null;
    }
  }

  Future<PickedFileResult?> captureCameraPhoto() async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);
      if (pickedFile == null) return null;

      final bytes = await pickedFile.readAsBytes();
      return PickedFileResult(
        path: pickedFile.path,
        type: CustomFileType.image,
        sizeBytes: bytes.length,
      );
    } catch (_) {
      return null;
    }
  }
}
