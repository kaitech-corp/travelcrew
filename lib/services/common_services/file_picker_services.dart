import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../utils/debugging.dart';
class FilePickerService {
  factory FilePickerService() {
    return _instance;
  }
  FilePickerService._internal();
  static final FilePickerService _instance = FilePickerService._internal();
  static Future<FilePickerResult?> _pickFiles() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );
      return result;
    } catch (e) {
      kLogging('FilePickerService ${e.toString()}');
      return null;
    }
  }
  /// pick only one file
  static Future<File?> pickFile() async {
    final FilePickerResult? result = await _pickFiles();
    if (result != null) {
      return result.files.single.path != null
          ? File(result.files.single.path!)
          : null;
    }
    return null;
  }
}
