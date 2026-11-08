import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import '../../../../../core/common/styles/global_text_style.dart';

class CampaignStatsList extends StatelessWidget {
  final String spent;
  final String totalBudget;
  final String clicks;
  final String ctr;
  final String durationStr;

  const CampaignStatsList({
    super.key,
    required this.spent,
    required this.totalBudget,
    required this.clicks,
    required this.ctr,
    required this.durationStr,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Campaign Stats',
          style: appTextStyleHeading1(
            fontSize: 18.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.height),
        _buildStatItem(
          Icons.monetization_on_outlined,
          'Total Budget Spent',
          spent,
        ),
        _buildStatItem(
          Icons.account_balance_wallet_outlined,
          'Total Budget Limit',
          'AED $totalBudget',
        ),
        _buildStatItem(Icons.ads_click_outlined, 'Clicks Generated', clicks),
        _buildStatItem(Icons.bar_chart_outlined, 'Average CTR', ctr),
        _buildStatItem(Icons.calendar_today_outlined, 'Duration', durationStr),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.height),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.width),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryButtonColor, size: 20.fontSize),
          ),
          SizedBox(width: 14.width),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: getTextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 2.height),
                Text(
                  value,
                  style: appTextStyleHeading1(
                    fontSize: 15.fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
