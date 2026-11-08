import 'dart:io';
import 'package:msollaally/core/const/appcolors.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/utils/device/device_utility.dart';
import 'package:msollaally/core/common/widgets/fullscreen_image_view.dart';

import '../controller/campaign_social_feed_mapper.dart';

class CommentMediaPreviewWidget extends StatelessWidget {
  final String mediaUrl;
  final bool isLocal;
  final VoidCallback? onRemove;

  const CommentMediaPreviewWidget({
    super.key,
    required this.mediaUrl,
    this.isLocal = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (mediaUrl.trim().isEmpty) return const SizedBox.shrink();

    final type = CampaignSocialFeedMapper.detectMediaType(mediaUrl);
    final child = type == 'image' ? _imageView() : _fileView(type);

    return Stack(
      children: [
        child,
        if (onRemove != null)
          Positioned(
            top: 6.h,
            right: 6.w,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22.w,
                height: 22.w,
                decoration: const BoxDecoration(
                  color: AppColors.blackAlphaCC0F172A,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(Icons.close, color: Colors.white, size: 14.sp),
              ),
            ),
          ),
      ],
    );
  }

  Widget _imageView() {
    if (isLocal) {
      return GestureDetector(
        onTap: () {
          Get.to(
            () => FullscreenImageView(
              imageUrl: mediaUrl,
              isNetworkImage: false,
              isFileImage: true,
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.file(
            File(mediaUrl),
            height: 140.h,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Get.to(
          () => FullscreenImageView(imageUrl: mediaUrl, isNetworkImage: true),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Image.network(
          mediaUrl,
          height: 140.h,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fileView('file'),
        ),
      ),
    );
  }

  Widget _fileView(String type) {
    return GestureDetector(
      onTap: isLocal ? null : () => AppDeviceUtility.launchUrl(mediaUrl),
      child: Container(
        height: 78.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.whiteSmokeF1F5F9,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.lavenderE2E8F0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Row(
          children: [
            Icon(
              type == 'video'
                  ? Icons.play_circle_fill_rounded
                  : Icons.insert_drive_file,
              color: AppColors.darkSlateGray334155,
              size: 22.sp,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                type == 'video' ? 'Video attachment' : 'Attachment',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.darkSlateGray334155,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
