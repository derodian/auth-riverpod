import 'dart:io';

import 'package:flutter/material.dart';

class ImageValidationResult {
  const ImageValidationResult({
    required this.isValid,
    this.error,
  });

  final bool isValid;
  final String? error;
}

class ImageUtils {
  static Future<ImageValidationResult> validateImage(File file) async {
    try {
      // Check if file exists
      if (!await file.exists()) {
        return const ImageValidationResult(
          isValid: false,
          error: 'Image file does not exist',
        );
      }

      // Check file size (max 10MB)
      final bytes = await file.length();
      if (bytes > 10 * 1024 * 1024) {
        return const ImageValidationResult(
          isValid: false,
          error: 'Image size should be less than 10MB',
        );
      }

      // Try to decode the image
      final fileBytes = await file.readAsBytes();
      final result = await decodeImageFromList(fileBytes);

      // Check dimensions
      if (result.width < 100 || result.height < 100) {
        return const ImageValidationResult(
          isValid: false,
          error: 'Image dimensions too small',
        );
      }

      if (result.width > 4096 || result.height > 4096) {
        return const ImageValidationResult(
          isValid: false,
          error: 'Image dimensions too large',
        );
      }

      return const ImageValidationResult(isValid: true);
    } catch (e) {
      return ImageValidationResult(
        isValid: false,
        error: 'Invalid image format: ${e.toString()}',
      );
    }
  }
}
