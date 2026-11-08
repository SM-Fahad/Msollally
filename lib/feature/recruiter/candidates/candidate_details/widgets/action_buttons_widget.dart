import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../candidate_details/controller/candidate_details_controller.dart';
import '../../../../../core/common/widgets/custom_button.dart';
import '../../../../../core/common/styles/global_text_style.dart';

class ActionButtonsWidget extends StatelessWidget {
  final CandidateDetailsController controller;
  const ActionButtonsWidget({super.key, required this.controller});

  void _showDeclineDialog(BuildContext context) {
    final reasonController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: Text(
          'Decline Application',
          style: getTextStyle(
            color: AppColors.primaryTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please provide a reason for declining this application:',
              style: getTextStyle(
                color: AppColors.secondaryTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter rejection reason...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: AppColors.primaryButtonColor, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: getTextStyle(
                color: AppColors.secondaryTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              Get.back();
              controller.declineWithReason(reason);
            },
            child: Text(
              'Submit',
              style: getTextStyle(
                color: AppColors.uiDangerColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.only(right: 8.w),
            child: CustomButton(
              text: 'Decline',
              onPressed: () => _showDeclineDialog(context),
              color: AppColors.uiDangerColor,
              textColor: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(right: 8.w),
            child: CustomButton(
              text: 'Reserve',
              onPressed: controller.reserve,
              color: Colors.grey,
              textColor: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: CustomButton(
            text: 'Shortlist',
            onPressed: controller.shortlist,
            color: AppColors.primaryButtonColor,
          ),
        ),
      ],
    );
  }
}
