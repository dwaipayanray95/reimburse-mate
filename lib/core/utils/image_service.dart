import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickAndCompressImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 100, // Pick full size and compress ourselves
      );

      if (pickedFile == null) return null;

      final appDir = await getApplicationDocumentsDirectory();
      final targetPath = p.join(appDir.path, '${const Uuid().v4()}.jpg');

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        targetPath,
        quality: 60,
        minWidth: 1200,
        minHeight: 1200,
        keepExif: false,
      );

      if (compressedFile == null) return null;
      return File(compressedFile.path);
    } catch (_) {
      return null;
    }
  }
}
