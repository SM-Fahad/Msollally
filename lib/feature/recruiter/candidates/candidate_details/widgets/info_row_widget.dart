import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/common/styles/global_text_style.dart';

class InfoRowWidget extends StatelessWidget {
  final String label;
  final String value;
  const InfoRowWidget({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: Row(
        children: [
          // Label: take minimal space and stay left
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: appTextStyleHeading1(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.appBarTitleColor,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Value: take remaining space and align to right edge
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Opacity(
                opacity: 0.8,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: appTextStyleHeading1(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.appBarTitleColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
