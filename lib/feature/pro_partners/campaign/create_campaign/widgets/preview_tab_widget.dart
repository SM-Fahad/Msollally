import 'dart:io';
import 'package:msollaally/core/common/widgets/video_player_preview.dart';
import 'package:msollaally/core/const/appcolors.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../create_campaign/controller/create_campaign_controller.dart';
import 'campaign_profile_header_widget.dart';
import 'create_campaign_shared_widgets.dart';

class PreviewTabWidget extends StatelessWidget {
  const PreviewTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateCampaignController>();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 28.h),
      child: Column(
        children: [
          CampaignSectionCard(
            title: 'Review Campaign',
            description: 'Check before launch.',
            child: Obx(() => _content(controller)),
          ),
          SizedBox(height: 20.h),
          Obx(
            () => CampaignFooterActions(
              primaryText: controller.primaryActionText,
              primaryAction: controller.isSubmitting.value
                  ? null
                  : controller.submitCampaign,
              secondaryText: 'Edit',
              secondaryAction: () =>
                  DefaultTabController.of(context).animateTo(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(CreateCampaignController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _previewCard(controller),
        SizedBox(height: 18.h),
        _detailTile('URL', _valueOrFallback(controller.destinationUrl.value)),
        _detailTile('CTA', _valueOrFallback(controller.cta.value)),
        _detailTile(
          'University',
          _listValueOrFallback(controller.selectedUniversities),
        ),
        _detailTile(
          'Gender',
          controller.gender.value == 'Other' && controller.otherGender.value.isNotEmpty
              ? 'Other (${controller.otherGender.value})'
              : _valueOrFallback(controller.gender.value),
        ),
        _detailTile(
          'Major',
          _listValueOrFallback(
            controller.selectedMajors.map((m) {
              return m == 'Other' && controller.otherMajor.value.isNotEmpty
                  ? 'Other (${controller.otherMajor.value})'
                  : m;
            }).toList(),
          ),
        ),
        _detailTile('Year', _valueOrFallback(controller.year.value)),
        _detailTile(
          'Budget',
          controller.budgetAmount.value == null
              ? 'Not selected'
              : 'TZS ${controller.budgetAmount.value!.toStringAsFixed(0)}',
        ),
        _detailTile(
          'Start Date',
          controller.startDate.value == null
              ? 'Not selected'
              : DateFormat('MM/dd/yyyy').format(controller.startDate.value!),
        ),
        _detailTile(
          'End Date',
          controller.endDate.value == null
              ? 'Not selected'
              : DateFormat('MM/dd/yyyy').format(controller.endDate.value!),
        ),
      ],
    );
  }

  Widget _previewCard(CreateCampaignController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.panelBackgroundColor,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.lavenderE2E8F0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CampaignProfileHeaderWidget(),
          SizedBox(height: 16.h),
          if (controller.caption.value.trim().isNotEmpty) ...[
            Text(
              controller.caption.value.trim(),
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.45,
                color: AppColors.darkSlateGray475569,
              ),
            ),
            SizedBox(height: 14.h),
          ],
          _mediaPreview(controller),
          SizedBox(height: 14.h),
          Text(
            controller.title.value.trim().isEmpty
                ? 'Campaign title'
                : controller.title.value.trim(),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.black0F172A,
            ),
          ),
          if (controller.description.value.trim().isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              controller.description.value.trim(),
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.45,
                color: AppColors.slateGray64748B,
              ),
            ),
          ],
          SizedBox(height: 16.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: controller.cta.value.isEmpty
                    ? AppColors.lavenderE2E8F0
                    : AppColors.royalBlue2563EB,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Text(
                controller.cta.value.isEmpty
                    ? 'Not selected'
                    : controller.cta.value,
                style: TextStyle(
                  color: controller.cta.value.isEmpty
                      ? AppColors.slateGray64748B
                      : Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailTile(String label, String value) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.lavenderE2E8F0),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkSlateGray334155,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.4,
                color: AppColors.slateGray64748B,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mediaPreview(CreateCampaignController controller) {
    final path = controller.pickedFilePath.value;
    final mediaType = controller.pickedMediaType.value;
    final mediaUrl = controller.uploadedMediaUrl.value;

    if (!controller.hasSelectedMedia) {
      return const CampaignEmptyState(
        icon: Icons.perm_media_outlined,
        title: 'No media selected',
        description: '',
      );
    }
    if (mediaType == 'video') {
      return VideoPlayerPreviewWidget(
        localFilePath: path,
        remoteUrl: mediaUrl,
        height: 170.h,
        borderRadius: 18.r,
      );
    }
    if (mediaType == 'audio' || mediaType == 'file') {
      return _mediaPlaceholder(
        icon: mediaType == 'audio'
            ? Icons.audiotrack
            : Icons.insert_drive_file_outlined,
        label: mediaType == 'audio' ? 'Audio selected' : 'File selected',
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: path != null && path.isNotEmpty
          ? Image.file(
              File(path),
              height: 170.h,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _netImage(mediaUrl),
            )
          : _netImage(mediaUrl),
    );
  }

  Widget _netImage(String? url) {
    return Image.network(
      url ?? 'https://placehold.co/480x240.png',
      height: 170.h,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: 170.h,
        color: AppColors.lavenderE2E8F0,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image, color: AppColors.slateGray64748B),
      ),
    );
  }

  Widget _mediaPlaceholder({required IconData icon, required String label}) {
    return Container(
      height: 170.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.lavenderE2E8F0,
        borderRadius: BorderRadius.circular(18.r),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.darkSlateGray475569, size: 38.sp),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.darkSlateGray334155,
            ),
          ),
        ],
      ),
    );
  }

  String _valueOrFallback(String? value) {
    return value == null || value.trim().isEmpty
        ? 'Not selected'
        : value.trim();
  }

  String _listValueOrFallback(List<String> values) {
    if (values.isEmpty) return 'Not selected';
    return values.join(', ');
  }
}
