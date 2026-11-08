import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/widgets/video_player_preview.dart';
import 'package:msollaally/core/const/appcolors.dart';
import '../controller/create_event_controller.dart';

class EventUploadWidget extends StatelessWidget {
  final CreateEventController controller;
  const EventUploadWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── 1. Cover Image ───
        Text(
          'Cover Image',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8.h),
        Obx(() {
          final coverPath = controller.coverImagePath.value;
          final uploadedCoverUrl = controller.uploadedCoverImageUrl.value;
          final hasPickedCover = coverPath != null && File(coverPath).existsSync();
          final hasUploadedCover =
              uploadedCoverUrl != null && uploadedCoverUrl.isNotEmpty;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: controller.pickFile,
                child: Container(
                  width: double.infinity,
                  height: 150.h,
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha((0.04 * 255).round()),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AppColors.sectionBorderColor),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (hasPickedCover)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: Image.file(
                            File(coverPath),
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      else if (hasUploadedCover)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: Image.network(
                            uploadedCoverUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _uploadPlaceholder(
                              'Tap to upload cover image',
                              Icons.add_photo_alternate_outlined,
                            ),
                          ),
                        )
                      else
                        _uploadPlaceholder(
                          'Tap to upload cover image',
                          Icons.add_photo_alternate_outlined,
                        ),
                    ],
                  ),
                ),
              ),
              if (hasPickedCover || hasUploadedCover) ...[
                SizedBox(height: 6.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: controller.clearCover,
                    icon: Icon(Icons.delete_outline, color: Colors.red, size: 18.sp),
                    label: Text(
                      'Remove Cover',
                      style: TextStyle(color: Colors.red, fontSize: 12.sp),
                    ),
                  ),
                ),
              ],
            ],
          );
        }),

        SizedBox(height: 14.h),

        // ─── 2. Video Clip (mediaUrl) ───
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Event Video Clip (Optional)',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
            Text(
              'mp4 / webm',
              style: TextStyle(fontSize: 11.sp, color: AppColors.tertiaryTextColor),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Obx(() {
          final videoPath = controller.videoClipPath.value;
          final uploadedVideoUrl = controller.uploadedVideoUrl.value;
          final hasVideo = (videoPath != null && videoPath.isNotEmpty) ||
              (uploadedVideoUrl != null && uploadedVideoUrl.isNotEmpty);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasVideo)
                Column(
                  children: [
                    VideoPlayerPreviewWidget(
                      localFilePath: videoPath,
                      remoteUrl: uploadedVideoUrl,
                      height: 160.h,
                      borderRadius: 10.r,
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (controller.isUploadingVideo.value)
                          Row(
                            children: [
                              SizedBox(
                                width: 14.w,
                                height: 14.h,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 8.w),
                              Text('Uploading video...', style: TextStyle(fontSize: 12.sp)),
                            ],
                          )
                        else
                          Text(
                            videoPath != null
                                ? videoPath.split('/').last
                                : 'Video linked',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.darkSlateGray4A4A4A,
                            ),
                          ),
                        TextButton.icon(
                          onPressed: controller.clearVideoClip,
                          icon: Icon(Icons.delete_outline, color: Colors.red, size: 18.sp),
                          label: Text(
                            'Remove Video',
                            style: TextStyle(color: Colors.red, fontSize: 12.sp),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    GestureDetector(
                      onTap: controller.pickVideoClip,
                      child: Container(
                        width: double.infinity,
                        height: 90.h,
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha((0.04 * 255).round()),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: AppColors.sectionBorderColor,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: _uploadPlaceholder(
                          'Upload a video clip (.mp4)',
                          Icons.video_call_outlined,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: controller.videoUrlController,
                      onChanged: (val) {
                        controller.uploadedVideoUrl.value = val.trim();
                      },
                      decoration: InputDecoration(
                        hintText: 'Or paste video URL (https://...)',
                        filled: true,
                        fillColor: Colors.black.withAlpha((0.04 * 255).round()),
                        prefixIcon: Icon(Icons.link, size: 20.sp),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _uploadPlaceholder(String label, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28.sp, color: AppColors.secondaryTextColor),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: AppColors.secondaryTextColor),
          ),
        ],
      ),
    );
  }
}
