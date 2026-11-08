// lib/widgets/metric_card_widget.dart
import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProPartnersMetricCardWidget extends StatelessWidget {
  final String title;
  final String mainValue;
  final String subtitle;
  final IconData icon;
  final String? trailingText;
  final Color? trailingColor;
  final VoidCallback? onTap;

  const ProPartnersMetricCardWidget({
    super.key,
    required this.title,
    required this.mainValue,
    required this.subtitle,
    required this.icon,
    this.trailingText,
    this.trailingColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
      padding: EdgeInsets.all(20.w),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primaryButtonColor.withValues(alpha: .1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryButtonColor, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  mainValue,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black09090B,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12.sp),
                ),
                if (trailingText != null) ...[
                  SizedBox(height: 12.h),
                  Text(
                    trailingText!,
                    style: TextStyle(
                      color: trailingColor ?? Colors.black,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ));
  }
}

class ProPartnersMetricCardWithProgressWidget extends StatelessWidget {
  final String title;
  final String mainValue;
  final String subtitle;
  final double progress;
  final String conversionText;
  final VoidCallback? onTap;

  const ProPartnersMetricCardWithProgressWidget({
    super.key,
    required this.title,
    required this.mainValue,
    required this.subtitle,
    required this.progress,
    this.conversionText = '0.00%',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: .1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.star_rounded,
                  color: Colors.orange,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      mainValue,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black09090B,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[500], fontSize: 12.sp),
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(999.r),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8.h,
              backgroundColor: AppColors.whiteSmokeF4F4F5,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primaryButtonColor,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '$conversionText conversion rate',
            style: TextStyle(
              color: AppColors.primaryButtonColor,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ));
  }
}
