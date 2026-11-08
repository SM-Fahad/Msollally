import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class JobStatCard extends StatelessWidget {
  final String value;
  final String label;
  final String iconPath;

  const JobStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.textfieldBorderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.mediumSeaGreenAlpha1E46C882,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: _buildIcon(iconPath),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  label,
                  style: TextStyle(fontSize: 12.sp, color: AppColors.tertiaryTextColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(String path) {
    if (path.endsWith('.svg')) {
      return SvgPicture.asset(path, width: 24.w, height: 24.h);
    }
    return Image.asset(path, width: 24.w, height: 24.h);
  }
}
