import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';

import '../controller/campaign_notice_controller.dart';
import '../model/campaign_notice_model.dart';
import '../screen/campaign_notice_form_screen.dart';
import 'expandable_text_widget.dart';

class NoticesTabWidget extends StatelessWidget {
  final int campaignId;

  const NoticesTabWidget({super.key, required this.campaignId});

  String _formatDate(DateTime? value) {
    if (value == null) return 'Unknown time';
    return DateFormat('dd MMM yyyy, hh:mm a').format(value.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CampaignNoticeController>(
      tag: 'campaign-notices-$campaignId',
    );

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value != null) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.errorMessage.value!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.appBarTitleColor,
                  ),
                ),
                SizedBox(height: 12.h),
                TextButton(
                  onPressed: controller.fetchNotices,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      return ListView(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.h),
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.sectionBorderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Campaign Notices',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black09090B,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Create and manage campaign notices from a dedicated screen.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.tertiaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  width: 100.w,
                  child: CustomButton(
                    text: 'Add Note',
                    fontSize: 13,
                    onPressed: () {
                      controller.clearForm();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              CampaignNoticeFormScreen(campaignId: campaignId),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          if (controller.notices.isEmpty)
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.sectionBorderColor),
              ),
              child: Text(
                'No notices added yet.',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.tertiaryTextColor,
                ),
              ),
            )
          else
            ...controller.notices.map(
              (notice) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _NoticeCard(
                  controller: controller,
                  notice: notice,
                  formattedTime: _formatDate(
                    notice.updatedAt ?? notice.createdAt,
                  ),
                  onEdit: () {
                    controller.startEdit(notice);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            CampaignNoticeFormScreen(campaignId: campaignId),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      );
    });
  }
}

class _NoticeCard extends StatelessWidget {
  final CampaignNoticeController controller;
  final CampaignNoticeModel notice;
  final String formattedTime;
  final VoidCallback onEdit;

  const _NoticeCard({
    required this.controller,
    required this.notice,
    required this.formattedTime,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.sectionBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  notice.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.appBarTitleColor,
                  ),
                ),
              ),
              TextButton(onPressed: onEdit, child: const Text('Edit')),
            ],
          ),
          SizedBox(height: 4.h),
          Obx(
            () => ExpandableTextWidget(
              text: notice.notice,
              isExpanded: controller.isNoticeExpanded(notice.id),
              onToggle: () => controller.toggleNoticeExpanded(notice.id),
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.4,
                color: AppColors.darkSlateGray334155,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Opacity(
            opacity: 0.6,
            child: Text(
              formattedTime,
              style: TextStyle(fontSize: 12.sp, color: AppColors.tertiaryTextColor),
            ),
          ),
        ],
      ),
    );
  }
}
