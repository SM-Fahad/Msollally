import 'dart:io';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:msollaally/core/common/widgets/video_player_preview.dart';
import 'package:msollaally/core/const/appcolors.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../create_campaign/controller/create_campaign_controller.dart';
import 'create_campaign_shared_widgets.dart';

class ContentTabWidget extends StatelessWidget {
  const ContentTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateCampaignController>();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 28.h),
      child: Column(
        children: [
          CampaignSectionCard(
            title: 'Campaign Content',
            description: 'Add the main content.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _mediaPicker(controller),
                SizedBox(height: 18.h),
                _field(
                  label: 'Caption',
                  hint: 'Optional short text',
                  textController: controller.captionController,
                  tag: 'Optional',
                ),
                SizedBox(height: 16.h),
                Obx(
                  () => _field(
                    label: 'Campaign Title',
                    hint: 'Summer Internship Applications',
                    required: true,
                    textController: controller.titleController,
                    errorText: controller.titleError,
                  ),
                ),
                SizedBox(height: 16.h),
                const CampaignFieldLabel(label: 'Description', required: true),
                SizedBox(height: 8.h),
                Container(
                  height: 220.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.lavenderE2E8F0,
                    ),
                  ),
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: quill.QuillSimpleToolbar(
                          controller: controller.quillController,
                          config: const quill.QuillSimpleToolbarConfig(
                            showFontFamily: false,
                            showFontSize: false,
                            showSubscript: false,
                            showSuperscript: false,
                            showInlineCode: false,
                            showCodeBlock: false,
                            showQuote: false,
                            showLink: false,
                            showUndo: true,
                            showRedo: true,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(12.w),
                          child: quill.QuillEditor.basic(
                            controller: controller.quillController,
                            config: const quill.QuillEditorConfig(
                              placeholder:
                                  'Tell students what this is about (supports Bold, Italic, Lists, Alignment)...',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(() {
                  if (controller.descriptionError != null) {
                    return Padding(
                      padding: EdgeInsets.only(top: 6.h, left: 4.w),
                      child: Text(
                        controller.descriptionError!,
                        style: TextStyle(color: Colors.red, fontSize: 12.sp),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                SizedBox(height: 16.h),
                Obx(
                  () => _field(
                    label: 'Destination URL',
                    hint: 'https://your-landing-page.com',
                    required: true,
                    textController: controller.destinationUrlController,
                    errorText: controller.destinationUrlError,
                  ),
                ),
                SizedBox(height: 16.h),
                _ctaDropdown(controller),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          CampaignFooterActions(
            primaryText: 'Continue',
            primaryAction: () => DefaultTabController.of(context).animateTo(1),
          ),
        ],
      ),
    );
  }

  Widget _mediaPicker(CreateCampaignController controller) {
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
          final hasPickedCover =
              coverPath != null && File(coverPath).existsSync();
          final hasUploadedCover =
              uploadedCoverUrl != null && uploadedCoverUrl.isNotEmpty;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: controller.pickCoverImage,
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
                    icon: Icon(Icons.delete_outline,
                        color: Colors.red, size: 18.sp),
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

        // ─── 2. Video Clip (Optional) ───
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Campaign Video Clip (Optional)',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
            Text(
              'mp4 / webm (Max 50MB)',
              style: TextStyle(
                  fontSize: 11.sp, color: AppColors.tertiaryTextColor),
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
                                child:
                                    const CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 8.w),
                              Text('Uploading video...',
                                  style: TextStyle(fontSize: 12.sp)),
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
                          icon: Icon(Icons.delete_outline,
                              color: Colors.red, size: 18.sp),
                          label: Text(
                            'Remove Video',
                            style:
                                TextStyle(color: Colors.red, fontSize: 12.sp),
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
                        fillColor:
                            Colors.black.withAlpha((0.04 * 255).round()),
                        prefixIcon: Icon(Icons.link, size: 20.sp),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 10.h),
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

  Widget _uploadPlaceholder(String text, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 32.sp, color: AppColors.secondaryTextColor),
        SizedBox(height: 6.h),
        Text(
          text,
          style: TextStyle(fontSize: 12.sp, color: AppColors.secondaryTextColor),
        ),
      ],
    );
  }

  Widget _field({
    required String label,
    required String hint,
    required TextEditingController textController,
    bool required = false,
    int maxLines = 1,
    String? tag,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CampaignFieldLabel(label: label, required: required, tag: tag),
        SizedBox(height: 8.h),
        TextFormField(
          controller: textController,
          maxLines: maxLines,
          style: TextStyle(fontSize: 15.sp, color: AppColors.black0F172A),
          decoration: campaignInputDecoration(
            hintText: hint,
            errorText: errorText,
          ),
        ),
      ],
    );
  }

  Widget _ctaDropdown(CreateCampaignController controller) {
    final options = controller.ctaLabelToValue.keys.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CampaignFieldLabel(label: 'Call To Action', required: true),
        SizedBox(height: 8.h),
        Obx(
          () => DropdownButtonFormField<String>(
            key: ValueKey('cta-${controller.cta.value}'),
            initialValue: controller.cta.value.isEmpty
                ? null
                : controller.cta.value,
            items: options
                .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                .toList(),
            onChanged: (v) => controller.cta.value = v ?? '',
            style: TextStyle(fontSize: 15.sp, color: AppColors.black0F172A),
            decoration: campaignInputDecoration(
              hintText: 'Choose button text',
              errorText: controller.ctaError,
            ),
          ),
        ),
      ],
    );
  }

  Widget _preview({
    required String? filePath,
    required String? mediaType,
    required String? existingUrl,
  }) {
    if (filePath != null && filePath.isNotEmpty) {
      return _previewLocal(filePath, mediaType);
    }
    return _previewRemote(existingUrl, mediaType);
  }

  Widget _previewLocal(String filePath, String? mediaType) {
    if (mediaType == 'video') {
      return VideoPlayerPreviewWidget(
        localFilePath: filePath,
        height: 180.h,
        borderRadius: 18.r,
      );
    }
    if (mediaType == 'audio') {
      return _mediaPlaceholder(
        icon: Icons.audiotrack,
        label: 'Audio selected',
      );
    }
    if (mediaType == 'file') {
      return _mediaPlaceholder(
        icon: Icons.insert_drive_file_outlined,
        label: 'File selected',
      );
    }
    return Image.file(
      File(filePath),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.lavenderE2E8F0,
        alignment: Alignment.center,
        child: const Text('Could not preview image'),
      ),
    );
  }

  Widget _previewRemote(String? url, String? mediaType) {
    if (url == null || url.isEmpty) {
      return _mediaPlaceholder(
        icon: Icons.perm_media_outlined,
        label: 'Preview unavailable',
      );
    }
    if (mediaType == 'video') {
      return VideoPlayerPreviewWidget(
        remoteUrl: url,
        height: 180.h,
        borderRadius: 18.r,
      );
    }
    if (mediaType == 'audio' || mediaType == 'file') {
      return _mediaPlaceholder(
        icon: mediaType == 'audio'
            ? Icons.audiotrack
            : Icons.insert_drive_file_outlined,
        label: mediaType == 'audio'
            ? 'Existing audio'
            : 'Existing file',
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _mediaPlaceholder(
        icon: Icons.broken_image_outlined,
        label: 'Preview unavailable',
      ),
    );
  }

  Widget _mediaPlaceholder({required IconData icon, required String label}) {
    return Container(
      color: AppColors.lavenderE2E8F0,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 42.sp, color: AppColors.darkSlateGray475569),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.darkSlateGray334155,
            ),
          ),
        ],
      ),
    );
  }
}
