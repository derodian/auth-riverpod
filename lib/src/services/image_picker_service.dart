// lib/core/services/image_picker_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_picker_service.g.dart';

class ImagePickerService {
  ImagePickerService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<File?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    bool preferCameraDevice = false,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality ?? 80,
        preferredCameraDevice:
            preferCameraDevice ? CameraDevice.front : CameraDevice.rear,
      );

      if (pickedFile == null) return null;

      // Verify the file exists and is readable
      final file = File(pickedFile.path);
      if (!await file.exists()) {
        throw Exception('Selected image file does not exist');
      }

      return file;
    } on PlatformException catch (e) {
      debugPrint('Platform error picking image: ${e.message}');
      if (e.code == 'invalid_image') {
        throw Exception(
            'The selected image appears to be invalid or corrupted');
      }
      throw Exception('Error picking image: ${e.message}');
    } catch (e) {
      debugPrint('Error picking image: $e');
      throw Exception('Failed to pick image. Please try again.');
    }
  }

  Future<File?> pickImageFromGallery({
    double? maxWidth,
    double? maxHeight,
    int? quality,
  }) async {
    return pickImage(
      source: ImageSource.gallery,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: quality,
    );
  }

  Future<File?> pickImageFromCamera({
    double? maxWidth,
    double? maxHeight,
    int? quality,
    bool preferFrontCamera = false,
  }) async {
    return pickImage(
      source: ImageSource.camera,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: quality,
      preferCameraDevice: preferFrontCamera,
    );
  }
}

@riverpod
ImagePickerService imagePicker(Ref ref) {
  return ImagePickerService();
}
