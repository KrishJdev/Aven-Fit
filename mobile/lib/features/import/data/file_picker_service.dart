import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'file_picker_service.g.dart';

/// Service interface for selecting a CSV export file from the device (FEATURES.md §12.4).
abstract class FilePickerService {
  /// Opens the system file picker to select a CSV file and returns its text content and filename.
  /// Returns null if the user cancelled the picker or if the file could not be read.
  Future<({String content, String name})?> pickCsvFile();
}

/// Production implementation using the [FilePicker] plugin.
class PlatformFilePickerService implements FilePickerService {
  const PlatformFilePickerService();

  @override
  Future<({String content, String name})?> pickCsvFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.first;
    String? content;

    if (file.bytes != null) {
      content = utf8.decode(file.bytes!);
    } else if (file.path != null) {
      content = await File(file.path!).readAsString();
    }

    if (content == null) {
      return null;
    }

    return (content: content, name: file.name);
  }
}

/// Riverpod provider exposing [FilePickerService].
@riverpod
FilePickerService filePickerService(Ref ref) {
  return const PlatformFilePickerService();
}
