// lib/core/extensions/file_extensions.dart
import 'dart:io';
import 'package:path/path.dart' as path;

extension FileX on File {
  String get fileName => path.basename(this.path);
  String get extension => path.extension(this.path);
  bool get isImage =>
      ['.jpg', '.jpeg', '.png', '.gif'].contains(extension.toLowerCase());
}

// lib/core/extensions/string_extensions.dart
extension StringX on String {
  bool get isValidImageUrl {
    final uri = Uri.tryParse(this);
    if (uri == null) return false;
    return uri.hasAbsolutePath &&
        ['.jpg', '.jpeg', '.png', '.gif']
            .any((ext) => this.toLowerCase().endsWith(ext));
  }
}
