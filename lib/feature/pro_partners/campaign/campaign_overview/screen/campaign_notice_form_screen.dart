import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/campaign_notice_controller.dart';

class CampaignNoticeFormScreen extends StatelessWidget {
  final int campaignId;

  const CampaignNoticeFormScreen({super.key, required this.campaignId});

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.panelBackgroundColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.sectionBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.sectionBorderColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CampaignNoticeController>(
      tag: 'campaign-notices-$campaignId',
    );

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(controller.isEditing ? 'Update Notice' : 'Add Notice'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => Text(
                controller.isEditing ? 'Update Notice' : 'Create Notice',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black09090B,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: controller.titleController,
              decoration: _inputDecoration('Notice title'),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: controller.noticeController,
              maxLines: 5,
              decoration: _inputDecoration('Write your notice'),
            ),
            SizedBox(height: 16.h),
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isSaving.value
                      ? null
                      : () async {
                          final success = await controller.saveNotice();
                          if (success && context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                  child: Text(
                    controller.isSaving.value
                        ? 'Saving...'
                        : controller.isEditing
                        ? 'Update Notice'
                        : 'Add Notice',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
