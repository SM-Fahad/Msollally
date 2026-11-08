import 'dart:io';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/widgets/fullscreen_image_view.dart';
import '../controller/add_job_controller.dart';

class ImageUploadWidget extends StatelessWidget {
  final AddJobController controller = Get.find();

  ImageUploadWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Image Upload',
              style: TextStyle(color: AppColors.blackAlpha7F1E1E1E, fontSize: 14),
            ),
          ],
        ),
        SizedBox(height: 8),

        Obx(() {
          final imgs = controller.images;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < imgs.length; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            _imagePreview(imgs[i], i),

                            SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _imageTitle(imgs[i], i),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    _imageSubtitle(imgs[i], i),
                                    style: TextStyle(
                                      color: AppColors.darkGray9CA3AF,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(width: 8),

                            SizedBox(
                              width: 100,
                              height: 36,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  backgroundColor: AppColors.royalBlue3B82F6,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () => controller.pickImageAt(i),
                                child: Text(
                                  _buttonText(imgs[i], i),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Positioned(
                        right: 6,
                        top: 6,
                        child: GestureDetector(
                          onTap: () => controller.removeImageAt(i),
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  bool _hasExistingLogo(int index) {
    return index == 0 &&
        controller.isEditMode &&
        controller.existingCompanyLogo.isNotEmpty;
  }

  Widget _imagePreview(File? image, int index) {
    if (image != null) {
      return GestureDetector(
        onTap: () {
          Get.to(
            () => FullscreenImageView(
              imageUrl: image.path,
              isNetworkImage: false,
              isFileImage: true,
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(image, width: 120, height: 80, fit: BoxFit.cover),
        ),
      );
    }

    if (_hasExistingLogo(index)) {
      return GestureDetector(
        onTap: () {
          Get.to(
            () => FullscreenImageView(
              imageUrl: controller.existingCompanyLogo,
              isNetworkImage: true,
              isFileImage: false,
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            controller.existingCompanyLogo,
            width: 120,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _emptyPreview(),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 120,
                height: 80,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.ghostWhiteF8FAFF,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
          ),
        ),
      );
    }

    return _emptyPreview();
  }

  Widget _emptyPreview() {
    return Container(
      width: 120,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.ghostWhiteF8FAFF,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.image, color: AppColors.darkGray9CA3AF),
    );
  }

  String _imageTitle(File? image, int index) {
    if (image != null) return 'Selected image';
    if (_hasExistingLogo(index)) return 'Current image';
    return 'No image selected';
  }

  String _imageSubtitle(File? image, int index) {
    if (image != null || _hasExistingLogo(index)) return '';
    return 'JPEG, PNG, up to 50MB';
  }

  String _buttonText(File? image, int index) {
    if (image != null || _hasExistingLogo(index)) return 'Replace';
    return 'Select';
  }
}
