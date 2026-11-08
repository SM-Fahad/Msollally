// lib/widgets/engagement_card_widget.dart
import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProPartnersEngagementCardWidget extends StatelessWidget {
  final String engagementRate;

  const ProPartnersEngagementCardWidget({
    super.key,
    required this.engagementRate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.trending_up_rounded,
            color: AppColors.checkBoxActiveColor,
            size: 32.sp,
          ),
          SizedBox(height: 12.h),
          Text(
            engagementRate,
            style: TextStyle(
              color: AppColors.black09090B,
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Overall Engagement Rate',
            style: TextStyle(
              color: AppColors.darkSlateGrayAlphaB23F3F3F,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
