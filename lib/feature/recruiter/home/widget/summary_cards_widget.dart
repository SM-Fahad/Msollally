import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../model/recruiter_home_model.dart';

class SummaryCardsWidget extends StatelessWidget {
  final List<SummaryCardData> cards;

  const SummaryCardsWidget({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary',
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
        Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildSummaryCard(cards[0])),
                SizedBox(width: 19.w),
                Expanded(child: _buildSummaryCard(cards[1])),
              ],
            ),
            SizedBox(height: 18.h),
            Row(
              children: [
                SizedBox(width: 167.w, child: _buildSummaryCard(cards[2])),
                Spacer(),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(SummaryCardData card) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: AppColors.textfieldBorderColor),
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(9.w),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: card.iconColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: SizedBox(
              width: 24.w,
              height: 24.h,
              child: Icon(
                _getIconData(card.subtitle),
                size: 24.w,
                color: _getIconColor(card.subtitle),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  style: TextStyle(
                    color: AppColors.black18181B,
                    fontSize: 20.sp,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w700,
                    height: 1.40,
                    letterSpacing: 0.20,
                  ),
                ),
                Text(
                  card.subtitle,
                  style: TextStyle(
                    color: AppColors.tertiaryTextColor,
                    fontSize: 12.sp,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w500,
                    height: 1.67,
                    letterSpacing: 0.20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String subtitle) {
    switch (subtitle) {
      case 'Candidates':
        return Icons.people;
      case 'Open Jobs':
        return Icons.work_outline;
      case 'Applied Today':
        return Icons.assignment;
      default:
        return Icons.circle;
    }
  }

  Color _getIconColor(String subtitle) {
    switch (subtitle) {
      case 'Candidates':
        return AppColors.coralFF9244;
      case 'Open Jobs':
        return AppColors.checkBoxActiveColor;
      case 'Applied Today':
        return AppColors.primaryButtonColor;
      default:
        return Colors.grey;
    }
  }
}
