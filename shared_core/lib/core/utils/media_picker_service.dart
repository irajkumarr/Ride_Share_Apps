import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:file_picker/file_picker.dart';

/// A comprehensive utility for picking images and common files.
class MediaPickerService {
  MediaPickerService._();

  static final ImagePicker _imagePicker = ImagePicker();

  /// Pick an image from the gallery (Optionally crop it).
  static Future<File?> pickImageFromGallery({
    BuildContext? context,
    bool crop = false,
    CropAspectRatioPreset ratio = CropAspectRatioPreset.square,
  }) async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return null;

    if (crop && context != null) {
      if (!context.mounted) return null;
      return cropImage(pickedFile.path, context, ratio: ratio);
    }

    return File(pickedFile.path);
  }

  /// Pick an image using the camera (Optionally crop it).
  static Future<File?> pickImageFromCamera({
    BuildContext? context,
    bool crop = false,
    CropAspectRatioPreset ratio = CropAspectRatioPreset.square,
  }) async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile == null) return null;

    if (crop && context != null) {
      if (!context.mounted) return null;
      return cropImage(pickedFile.path, context, ratio: ratio);
    }

    return File(pickedFile.path);
  }

  /// Shared crop logic using image_cropper using the app's theme.
  static Future<File?> cropImage(
    String path,
    BuildContext context, {
    CropAspectRatioPreset ratio = CropAspectRatioPreset.square,
  }) async {
    final theme = Theme.of(context);

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: theme.colorScheme.surface,
          toolbarWidgetColor: theme.colorScheme.onSurface,
          initAspectRatio: ratio,
          lockAspectRatio: false,
          activeControlsWidgetColor: theme.colorScheme.primary,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: false,
        ),
      ],
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    }
    return null;
  }

  /// Pick a generic file (PDF, Doc, etc.).
  static Future<File?> pickFile({
    FileType type = FileType.custom,
    List<String> allowedExtensions = const ['pdf', 'doc', 'docx'],
  }) async {
    final List<PlatformFile>? result = await FilePicker.pickFiles(
      type: type,
      allowedExtensions: type == FileType.custom ? allowedExtensions : null,
    );

    if (result != null && result.single.path != null) {
      return File(result.single.path!);
    }
    return null;
  }

  /// Pick multiple images from the gallery
  static Future<List<File>> pickMultipleImages() async {
    final List<XFile> pickedFiles = await _imagePicker.pickMultiImage();
    return pickedFiles.map((xFile) => File(xFile.path)).toList();
  }
}
