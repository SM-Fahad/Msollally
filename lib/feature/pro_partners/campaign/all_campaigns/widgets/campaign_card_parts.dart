import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../model/campaign_model.dart';

class CampaignMainInfo extends StatelessWidget {
  final CampaignModel campaign;

  const CampaignMainInfo({super.key, required this.campaign});

  Color get _statusColor {
    switch (campaign.status.toLowerCase()) {
      case 'active':
        return AppColors.seaGreen16A34A;
      case 'paused':
        return AppColors.chocolateD97706;
      case 'completed':
        return AppColors.darkSlateGray475569;
      default:
        return AppColors.slateGray64748B;
    }
  }

  Color get _statusBg {
    switch (campaign.status.toLowerCase()) {
      case 'active':
        return AppColors.honeydewF0FDF4;
      case 'paused':
        return AppColors.seaShellFFF7ED;
      case 'completed':
        return AppColors.panelBackgroundColor;
      default:
        return AppColors.whiteSmokeF1F5F9;
    }
  }

  @override
  Widget build(BuildContext context) {
    final schedule = CampaignCardText.dateRange(
      campaign.startDate,
      campaign.endDate,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                campaign.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.black09090B,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (campaign.isSponsored) ...[
              SizedBox(width: 8.w),
              Icon(Icons.workspace_premium, size: 16.sp, color: _statusColor),
            ],
          ],
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: _statusBg,
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(color: _statusColor.withValues(alpha: 0.16)),
              ),
              child: Text(
                campaign.status,
                style: TextStyle(
                  color: _statusColor,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (CampaignCardText.isNotEmpty(campaign.callToAction))
              InlineInfo(text: campaign.callToAction),
            if (CampaignCardText.isNotEmpty(schedule))
              InlineInfo(text: schedule),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          CampaignCardText.firstNonEmpty(
            campaign.destinationUrl,
            campaign.university,
            'No destination set',
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: AppColors.slateGray64748B, fontSize: 12.sp),
        ),
      ],
    );
  }
}

class CampaignStatsRow extends StatelessWidget {
  final CampaignModel campaign;

  const CampaignStatsRow({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatTile(
            label: 'Clicks',
            value: '${campaign.clicks}',
            icon: Icons.ads_click_outlined,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: StatTile(
            label: 'Spent',
            value: 'TZS ${campaign.spent.toStringAsFixed(0)}',
            icon: Icons.account_balance_wallet_outlined,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: StatTile(
            label: 'CTR',
            value: '${campaign.ctr.toStringAsFixed(1)}%',
            icon: Icons.trending_up,
          ),
        ),
      ],
    );
  }
}

class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.panelBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.sp, color: AppColors.slateGray64748B),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              color: AppColors.black09090B,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(color: AppColors.tertiaryTextColor, fontSize: 11.sp),
          ),
        ],
      ),
    );
  }
}

class MetaChip extends StatelessWidget {
  final String label;

  const MetaChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.panelBackgroundColor,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: AppColors.lavenderE2E8F0),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.darkSlateGray475569,
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class InlineInfo extends StatelessWidget {
  final String text;

  const InlineInfo({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.slateGray64748B,
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class CardActionButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const CardActionButton({
    super.key,
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isPrimary
              ? AppColors.primaryButtonColor
              : AppColors.panelBackgroundColor,
          foregroundColor: isPrimary ? Colors.white : AppColors.black0F172A,
          side: isPrimary ? null : const BorderSide(color: AppColors.lavenderE2E8F0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class CampaignCardText {
  static List<String> buildMeta(CampaignModel campaign) {
    return <String>[
      if (isNotEmpty(campaign.university)) campaign.university,
      if (isNotEmpty(campaign.gender)) campaign.gender,
      if (isNotEmpty(campaign.major)) campaign.major,
      if (isNotEmpty(campaign.yearOfStudy)) 'Year ${campaign.yearOfStudy}',
      if (campaign.totalBudget > 0)
        'Budget TZS ${campaign.totalBudget.toStringAsFixed(0)}',
    ];
  }

  static String firstNonEmpty(String a, String b, [String c = '']) {
    for (final value in [a, b, c]) {
      if (isNotEmpty(value)) return value;
    }
    return '';
  }

  static bool isNotEmpty(String value) => value.trim().isNotEmpty;

  static String dateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) return '';
    final startText = start == null ? '' : _formatDate(start);
    final endText = end == null ? '' : _formatDate(end);
    if (startText.isNotEmpty && endText.isNotEmpty) {
      return '$startText - $endText';
    }
    return startText.isNotEmpty ? startText : endText;
  }

  static String _formatDate(DateTime date) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
