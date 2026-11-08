import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../model/recruiter_home_model.dart';

class QuickToolsWidget extends StatelessWidget {
  final List<QuickToolItem> tools;

  const QuickToolsWidget({super.key, required this.tools});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Tools',
          style: TextStyle(
            color: AppColors.blackAlpha7F1E1E1E,
            fontSize: 16.sp,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w400,
            height: 1.38,
            letterSpacing: -0.50,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: tools.map((tool) => _buildToolItem(tool)).toList(),
        ),
      ],
    );
  }

  Widget _buildToolItem(QuickToolItem tool) {
    return Container(
      width: 80.w,
      margin: EdgeInsets.only(right: 12.w),
      child: Column(
        children: [
          GestureDetector(
            onTap: tool.onTap,
            child: Container(
              padding: EdgeInsets.all(9.w),
              decoration: ShapeDecoration(
                color: tool.iconColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: SizedBox(
                width: 24.w,
                height: 24.h,
                child: Icon(
                  _getIconData(tool.title),
                  size: 24.w,
                  color: _getIconColor(tool.title),
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            tool.title,
            style: TextStyle(
              color: AppColors.appBarTitleColor,
              fontSize: 12.sp,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
              height: 1.83,
              letterSpacing: -0.50,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String title) {
    switch (title) {
      case 'Chat':
        return Icons.chat_bubble_outline;
      case 'Candidate':
        return Icons.people;
      case 'Jobs':
        return Icons.work;
      default:
        return Icons.circle;
    }
  }

  Color _getIconColor(String title) {
    switch (title) {
      case 'Chat':
        return AppColors.mediumPurple8757F3;
      case 'Candidate':
        return AppColors.coralFF9244;
      case 'Jobs':
        return AppColors.primaryButtonColor;
      default:
        return Colors.grey;
    }
  }
}
