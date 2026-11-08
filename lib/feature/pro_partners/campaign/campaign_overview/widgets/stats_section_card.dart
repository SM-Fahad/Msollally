import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatsSectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const StatsSectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.lavenderEAF0F7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: .12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20.sp, color: iconColor),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.tertiaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          child,
        ],
      ),
    );
  }
}

class StatsSummaryCard extends StatelessWidget {
  final String status;
  final String totalBudget;
  final String remainingBudget;
  final String startDate;
  final String endDate;

  const StatsSummaryCard({
    super.key,
    required this.status,
    required this.totalBudget,
    required this.remainingBudget,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return StatsSectionCard(
      title: 'Campaign Summary',
      subtitle: 'Budget and timeline overview',
      icon: Icons.campaign_outlined,
      iconColor: AppColors.primaryButtonColor,
      child: Column(
        children: [
          StatsDetailRow(label: 'Status', value: status),
          StatsDetailRow(label: 'Total Budget', value: totalBudget),
          StatsDetailRow(label: 'Remaining Budget', value: remainingBudget),
          StatsDetailRow(label: 'Start Date', value: startDate),
          StatsDetailRow(label: 'End Date', value: endDate, showDivider: false),
        ],
      ),
    );
  }
}

class StatsAudienceCard extends StatelessWidget {
  final List<StatsDemoItem> items;

  const StatsAudienceCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return StatsSectionCard(
      title: 'Audience Demographics',
      subtitle: 'Student majors who engaged with your campaign',
      icon: Icons.groups_2_outlined,
      iconColor: AppColors.mediumSeaGreen22B573,
      child: items.isEmpty
          ? Padding(
              padding: EdgeInsets.only(top: 6.h),
              child: Text(
                'No audience demographic data yet.',
                style: TextStyle(fontSize: 13.sp, color: AppColors.tertiaryTextColor),
              ),
            )
          : Column(
              children: items
                  .map(
                    (item) => StatsDemoRow(
                      label: item.label,
                      fraction: item.fraction,
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class StatsDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool showDivider;

  const StatsDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 9.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.primaryTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (showDivider) Container(height: 1, color: AppColors.whiteSmokeF1F5F9),
      ],
    );
  }
}

class StatsDemoRow extends StatelessWidget {
  final String label;
  final double fraction;

  const StatsDemoRow({super.key, required this.label, required this.fraction});

  @override
  Widget build(BuildContext context) {
    final percent = (fraction * 100).toStringAsFixed(0);

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.darkSlateGray374151,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.primaryTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 7.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(999.r),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8.h,
              backgroundColor: AppColors.aliceBlueEFF4FA,
              valueColor: AlwaysStoppedAnimation(AppColors.primaryButtonColor),
            ),
          ),
        ],
      ),
    );
  }
}

class StatsDemoItem {
  final String label;
  final double fraction;

  StatsDemoItem({required this.label, required this.fraction});
}
