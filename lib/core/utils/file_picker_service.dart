import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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

/// Thrown when a pick/persist operation fails for a reason other than the
/// user simply cancelling the picker (which returns null, not an error).
class AttachmentPickException implements Exception {
  final String message;
  AttachmentPickException(this.message);

  @override
  String toString() => message;
}

class FilePickerService {
  final ImagePicker _imagePicker = ImagePicker();

  /// Copies [sourcePath] into permanent app-documents storage so the
  /// attachment survives OS cache/temp cleanup. Images are compressed;
  /// other files (PDFs) are copied as-is.
  Future<String> _persistFile(String sourcePath, {required bool isImage}) async {
    final appDir = await getApplicationDocumentsDirectory();
    final attachmentsDir = Directory(p.join(appDir.path, 'attachments'));
    if (!await attachmentsDir.exists()) {
      await attachmentsDir.create(recursive: true);
    }

    if (isImage) {
      final targetPath = p.join(attachmentsDir.path, '${const Uuid().v4()}.jpg');
      final compressed = await FlutterImageCompress.compressAndGetFile(
        sourcePath,
        targetPath,
        quality: 70,
        minWidth: 1600,
        minHeight: 1600,
        keepExif: false,
      );
      if (compressed != null) return compressed.path;
      // Compression can fail for some source formats — fall back to a raw copy.
    }

    final extension = p.extension(sourcePath);
    final targetPath = p.join(attachmentsDir.path, '${const Uuid().v4()}$extension');
    final copied = await File(sourcePath).copy(targetPath);
    return copied.path;
  }

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

      final persistedPath = await _persistFile(file.path!, isImage: type == CustomFileType.image);
      final sizeBytes = await File(persistedPath).length();

      return PickedFileResult(
        path: persistedPath,
        type: type,
        sizeBytes: sizeBytes,
      );
    } catch (e) {
      throw AttachmentPickException('Could not attach the selected file: $e');
    }
  }

  Future<PickedFileResult?> captureCameraPhoto() async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);
      if (pickedFile == null) return null;

      final persistedPath = await _persistFile(pickedFile.path, isImage: true);
      final sizeBytes = await File(persistedPath).length();

      return PickedFileResult(
        path: persistedPath,
        type: CustomFileType.image,
        sizeBytes: sizeBytes,
      );
    } catch (e) {
      throw AttachmentPickException('Could not capture a photo: $e');
    }
  }

  Future<PickedFileResult?> selectPhotoFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return null;

      final persistedPath = await _persistFile(pickedFile.path, isImage: true);
      final sizeBytes = await File(persistedPath).length();

      return PickedFileResult(
        path: persistedPath,
        type: CustomFileType.image,
        sizeBytes: sizeBytes,
      );
    } catch (e) {
      throw AttachmentPickException('Could not select a photo: $e');
    }
  }
}
