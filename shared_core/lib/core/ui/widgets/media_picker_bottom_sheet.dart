import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../utils/media_picker_service.dart';
import 'bottom_sheet_layout.dart';
import '../../utils/colors.dart';

/// A reusable bottom sheet for presenting media picker options (Camera, Gallery, Files).
class MediaPickerBottomSheet extends StatelessWidget {
  const MediaPickerBottomSheet({
    super.key,
    this.allowFiles = true,
    this.cropImage = false,
    this.cropRatio = CropAspectRatioPreset.square,
  });

  /// If false, the "Pick File" document option is hidden.
  final bool allowFiles;

  /// Whether to trigger the cropper after selecting an image.
  final bool cropImage;

  /// The crop aspect ratio to enforce if [cropImage] is true.
  final CropAspectRatioPreset cropRatio;

  /// Shows the bottom sheet and returns the selected File (or null if canceled).
  static Future<File?> show(
    BuildContext context, {
    bool allowFiles = true,
    bool cropImage = false,
    CropAspectRatioPreset cropRatio = CropAspectRatioPreset.square,
  }) async {
    return showModalBottomSheet<File?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MediaPickerBottomSheet(
        allowFiles: allowFiles,
        cropImage: cropImage,
        cropRatio: cropRatio,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetLayout(
      title: 'Select Media',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: AppColor.black,
              ),
              title: const Text('Take a photo'),
              onTap: () async {
                final file = await MediaPickerService.pickImageFromCamera(
                  context: context,
                  crop: cropImage,
                  ratio: cropRatio,
                );
                if (context.mounted) Navigator.of(context).pop(file);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColor.black,
              ),
              title: const Text('Choose from gallery'),
              onTap: () async {
                final file = await MediaPickerService.pickImageFromGallery(
                  context: context,
                  crop: cropImage,
                  ratio: cropRatio,
                );
                if (context.mounted) Navigator.of(context).pop(file);
              },
            ),
            if (allowFiles)
              ListTile(
                leading: const Icon(
                  Icons.insert_drive_file_outlined,
                  color: AppColor.black,
                ),
                title: const Text('Select a document'),
                onTap: () async {
                  final file = await MediaPickerService.pickFile();
                  if (context.mounted) Navigator.of(context).pop(file);
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
