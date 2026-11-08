import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';

class FilterActions extends StatelessWidget {
  final VoidCallback onFilter;
  final VoidCallback onClear;
  final String filterLabel;
  final String clearLabel;

  const FilterActions({
    super.key,
    required this.onFilter,
    required this.onClear,
    this.filterLabel = 'Filter',
    this.clearLabel = 'Clear',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onFilter,
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: AppColors.primaryButtonColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Text(
                  filterLabel,
                  style: appTextStyleHeading2(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: InkWell(
            onTap: onClear,
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryButtonColor),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Text(
                  clearLabel,
                  style: appTextStyleHeading2(
                    color: AppColors.primaryButtonColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
