import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatsMetricItem {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  StatsMetricItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
}

class StatsMetricCard extends StatelessWidget {
  final StatsMetricItem item;

  const StatsMetricCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.lavenderEAF0F7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .035),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 110;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: compact ? 32.w : 38.w,
                height: compact ? 32.w : 38.w,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: .12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  size: compact ? 17.sp : 19.sp,
                  color: item.color,
                ),
              ),
              SizedBox(height: compact ? 6.h : 10.h),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item.value,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: compact ? 18.sp : 20.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: compact ? 2.h : 3.h),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 11.sp : 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray7A7A7A,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
