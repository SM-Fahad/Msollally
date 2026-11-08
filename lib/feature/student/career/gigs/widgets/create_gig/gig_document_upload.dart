import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/widgets/fullscreen_image_view.dart';

import '../../controller/gigs_controller.dart';
import 'gig_form_styles.dart';

class GigDocumentUpload extends StatelessWidget {
  const GigDocumentUpload({super.key, required this.controller});

  final GigsController controller;

  bool _isImageUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('.jpg') ||
        lower.contains('.jpeg') ||
        lower.contains('.png') ||
        lower.contains('.webp') ||
        lower.contains('image/upload');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        gigFieldLabel('Attach Documents (optional)'),
        Obx(
          () => GestureDetector(
            onTap: controller.isUploadingFile.value
                ? null
                : controller.pickAndUploadFile,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 24.height, horizontal: 16.width),
              decoration: BoxDecoration(
                border: Border.all(
                  color: controller.isUploadingFile.value
                      ? Colors.blue
                      : Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(12.radius),
                color: Colors.grey.shade50,
              ),
              child: Column(
                children: [
                  controller.isUploadingFile.value
                      ? const CircularProgressIndicator()
                      : Icon(
                          Icons.cloud_upload_outlined,
                          size: 40.fontSize,
                          color: Colors.grey.shade400,
                        ),
                  SizedBox(height: 8.height),
                  Text(
                    controller.isUploadingFile.value
                        ? 'Uploading to cloud...'
                        : 'Tap to upload a file',
                    style: TextStyle(
                      fontSize: 14.fontSize,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  if (!controller.isUploadingFile.value)
                    Text(
                      'Supported: Image, PDF, Word',
                      style: TextStyle(
                        fontSize: 11.fontSize,
                        color: Colors.grey.shade400,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 10.height),
        Obx(
          () => controller.uploadedDocumentUrls.isEmpty
              ? const SizedBox.shrink()
              : Column(
                  children: List.generate(
                    controller.uploadedDocumentUrls.length,
                    (index) {
                      final url = controller.uploadedDocumentUrls[index];
                      final isImage = _isImageUrl(url);

                      return Container(
                        margin: EdgeInsets.only(bottom: 8.height),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.width,
                          vertical: 10.height,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8.radius),
                        ),
                        child: Row(
                          children: [
                            if (isImage)
                              GestureDetector(
                                onTap: () => Get.to(
                                  () => FullscreenImageView(
                                    imageUrl: url,
                                    isNetworkImage: true,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    url,
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.image,
                                      size: 20,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Icon(
                                Icons.attach_file,
                                size: 16.fontSize,
                                color: Colors.blue,
                              ),
                            SizedBox(width: 8.width),
                            Expanded(
                              child: GestureDetector(
                                onTap: isImage
                                    ? () => Get.to(
                                          () => FullscreenImageView(
                                            imageUrl: url,
                                            isNetworkImage: true,
                                          ),
                                        )
                                    : null,
                                child: Text(
                                  isImage
                                      ? 'Photo ${index + 1} (Tap to view full screen)'
                                      : 'Document ${index + 1}',
                                  style: TextStyle(
                                    fontSize: 13.fontSize,
                                    color: Colors.blue.shade700,
                                    fontWeight: isImage ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => controller.removeUploadedFile(index),
                              child: const Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
