import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../create_campaign/controller/create_campaign_controller.dart';
import 'create_campaign_shared_widgets.dart';

class NoticesTabWidget extends StatelessWidget {
  const NoticesTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateCampaignController>();
    final noticeController = TextEditingController();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 28.h),
      child: Column(
        children: [
          CampaignSectionCard(
            title: 'Notices',
            description: 'Optional notices.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CampaignFieldLabel(label: 'Notice text', tag: 'Optional'),
                SizedBox(height: 8.h),
                TextField(
                  controller: noticeController,
                  maxLines: 3,
                  decoration: campaignInputDecoration(
                    hintText: 'Write a notice',
                  ),
                ),
                SizedBox(height: 18.h),
                CampaignFooterActions(
                  primaryText: 'Add Notice',
                  primaryAction: () {
                    controller.addNotice(noticeController.text);
                    noticeController.clear();
                  },
                  secondaryText: 'Clear',
                  secondaryAction: controller.notices.isEmpty
                      ? null
                      : controller.clearNotices,
                ),
                SizedBox(height: 18.h),
                Obx(
                  () => controller.notices.isEmpty
                      ? const CampaignEmptyState(
                          icon: Icons.notes,
                          title: 'No notices added',
                          description: '',
                        )
                      : Column(
                          children: controller.notices
                              .map(
                                (n) => Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.only(bottom: 10.h),
                                  padding: EdgeInsets.all(14.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.panelBackgroundColor,
                                    borderRadius: BorderRadius.circular(18.r),
                                    border: Border.all(
                                      color: AppColors.lavenderE2E8F0,
                                    ),
                                  ),
                                  child: Text(
                                    n,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      height: 1.4,
                                      color: AppColors.darkSlateGray334155,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Obx(
            () => CampaignFooterActions(
              primaryText: controller.isSubmitting.value
                  ? 'Launching...'
                  : 'Published a notes',
              primaryAction: controller.isSubmitting.value
                  ? null
                  : controller.submitCampaign,
              secondaryText: 'Back',
              secondaryAction: () =>
                  DefaultTabController.of(context).animateTo(3),
            ),
          ),
        ],
      ),
    );
  }
}
