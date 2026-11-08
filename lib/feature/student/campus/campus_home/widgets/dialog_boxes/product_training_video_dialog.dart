import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'controller/dialogbox_controller.dart';

class ProductTrainingVideoDialog extends StatefulWidget {
  final String? videoUrl;
  const ProductTrainingVideoDialog({super.key, this.videoUrl});

  @override
  State<ProductTrainingVideoDialog> createState() => _ProductTrainingVideoDialogState();
}

class _ProductTrainingVideoDialogState extends State<ProductTrainingVideoDialog> {
  late VideoPlayerController _videoPlayerController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<DialogboxController>();
    final url = widget.videoUrl ?? controller.promoVideoLink.value;
    
    if (url.isNotEmpty) {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isVideoInitialized = true;
            });
            _videoPlayerController.play();
            controller.startVideoTimer();
          }
        });
    }
  }

  @override
  void dispose() {
    if (_isVideoInitialized) {
      _videoPlayerController.dispose();
    }
    if (Get.isRegistered<DialogboxController>()) {
      Get.find<DialogboxController>().cancelVideoTimer();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DialogboxController>();

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Product Training Video",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black1D1D1D,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Watch the complete video to earn ${controller.videoPoints.value} points and learn about our products",
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 20, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: _isVideoInitialized 
                    ? _videoPlayerController.value.aspectRatio 
                    : 16 / 9,
                child: _isVideoInitialized
                    ? VideoPlayer(_videoPlayerController)
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Watch at least ${controller.formatTime(controller.minimumVideoWatchTime.value)} to earn points",
              style: const TextStyle(
                color: AppColors.orangeRedFF4500,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.tagBackgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.redFF0000,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Obx(
                      () => Text(
                        "Keep watching... ${controller.formatTime(controller.videoSecondsRemaining.value)} remaining",
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.black1D1D1D,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
