import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/const/appcolors.dart';

import '../controller/create_campaign_profile_controller.dart';

class CampaignProfileHeaderWidget extends StatelessWidget {
  const CampaignProfileHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateCampaignProfileController>();

    return Obx(() {
      final imageUrl = controller.profileImageUrl;

      return Row(
        children: [
          Container(
            width: 45.w,
            height: 45.w,
            padding: EdgeInsets.all(2.5.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.appBarTitleColor,
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.whiteSmokeF1F5F9,
                  child: Icon(
                    Icons.campaign_rounded,
                    color: AppColors.royalBlue6366F1,
                    size: 26,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              controller.displayName,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.black0F172A,
              ),
            ),
          ),
        ],
      );
    });
  }
}
