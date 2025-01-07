// lib/core/utils/image_error_handler.dart
import 'package:flutter/foundation.dart';

class ImageErrorHandler {
  static void handleError(String url, dynamic error) {
    debugPrint('Error loading image from URL: $url');
    debugPrint('Error details: $error');
    // Add your error reporting logic here
  }
}
