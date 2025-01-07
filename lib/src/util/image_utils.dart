import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageUtils {
  // Constants for image configuration
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB in bytes
  static const double compressionQuality = 0.7;
  static const int minWidth = 1024; // Minimum width to maintain quality
  static const int minHeight = 1024; // Minimum height to maintain quality
  static const int maxAllowedWidth = 2048; // For validation
  static const int maxAllowedHeight = 2048; // For validation

  /// Checks if the image file size is within the allowed limit
  static bool isValidImageSize(File file) {
    final size = file.lengthSync();
    return size <= maxImageSize;
  }

  /// Compresses an image file
  static Future<File?> compressImage(File file) async {
    try {
      // Check if compression is needed
      if (!isValidImageSize(file)) {
        debugPrint('Image size exceeds limit. Compressing...');
      }

      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${const Uuid().v4()}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: (compressionQuality * 100).toInt(),
        minWidth: minWidth,
        minHeight: minHeight,
        rotate: 0,
      );

      if (result == null) {
        throw Exception('Failed to compress image');
      }

      // Verify compressed size
      final compressedFile = File(result.path);
      if (!isValidImageSize(compressedFile)) {
        // Try again with lower quality if still too large
        return await _compressWithLowerQuality(file);
      }

      return compressedFile;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }

  /// Attempts to compress with progressively lower quality
  static Future<File?> _compressWithLowerQuality(File file) async {
    double quality = compressionQuality;
    final dir = await getTemporaryDirectory();

    while (quality > 0.2) {
      // Don't go below 20% quality
      quality -= 0.1;
      final targetPath = '${dir.path}/${const Uuid().v4()}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: (quality * 100).toInt(),
        minWidth: minWidth,
        minHeight: minHeight,
        rotate: 0,
      );

      if (result != null) {
        final compressedFile = File(result.path);
        if (isValidImageSize(compressedFile)) {
          return compressedFile;
        }
        // Clean up the failed attempt
        await compressedFile.delete();
      }
    }

    throw Exception('Unable to compress image to required size');
  }

  /// Gets the file size in MB
  static double getFileSizeInMB(File file) {
    final bytes = file.lengthSync();
    return bytes / (1024 * 1024);
  }

  /// Validates image file type
  static bool isValidImageType(File file) {
    final extension = file.path.toLowerCase();
    return extension.endsWith('.jpg') ||
        extension.endsWith('.jpeg') ||
        extension.endsWith('.png');
  }

  /// Get image dimensions from file
  static Future<({int width, int height})> getImageDimensions(File file) async {
    final bytes = await file.readAsBytes();
    final image = await decodeImageFromBytes(bytes);
    return (width: image.width, height: image.height);
  }

  /// Decode image from bytes
  static Future<ui.Image> decodeImageFromBytes(Uint8List bytes) async {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(bytes, completer.complete);
    return completer.future;
  }

  /// Comprehensive image validation
  static Future<({bool isValid, String? error})> validateImage(
      File file) async {
    // Check file type
    if (!isValidImageType(file)) {
      return (
        isValid: false,
        error: 'Invalid file type. Please use JPG or PNG images.',
      );
    }

    // Check file size
    if (!isValidImageSize(file)) {
      final size = getFileSizeInMB(file);
      return (
        isValid: false,
        error:
            'Image size (${size.toStringAsFixed(2)}MB) exceeds limit of 5MB.',
      );
    }

    // Check image dimensions
    try {
      final dimensions = await getImageDimensions(file);
      if (dimensions.width > maxAllowedWidth ||
          dimensions.height > maxAllowedHeight) {
        return (
          isValid: false,
          error:
              'Image dimensions exceed maximum allowed size of ${maxAllowedWidth}x$maxAllowedHeight',
        );
      }
    } catch (e) {
      return (
        isValid: false,
        error: 'Invalid image format',
      );
    }

    return (isValid: true, error: null);
  }

  /// Cleans up temporary files
  static Future<void> cleanupTempFiles() async {
    try {
      final dir = await getTemporaryDirectory();
      final tempFiles = dir.listSync();

      for (final file in tempFiles) {
        if (file is File &&
            (file.path.endsWith('.jpg') ||
                file.path.endsWith('.jpeg') ||
                file.path.endsWith('.png'))) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up temp files: $e');
    }
  }
}

// Optional: Add an extension for File
extension FileX on File {
  Future<({bool isValid, String? error})> validateAsImage() {
    return ImageUtils.validateImage(this);
  }

  double get sizeInMB => ImageUtils.getFileSizeInMB(this);

  Future<({int width, int height})> get dimensions =>
      ImageUtils.getImageDimensions(this);
}
