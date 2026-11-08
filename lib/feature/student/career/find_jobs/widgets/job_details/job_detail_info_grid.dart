import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import '../../model/jobs.model.dart';

class JobDetailInfoGrid extends StatelessWidget {
  final JobModel job;
  const JobDetailInfoGrid({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.width),
      decoration: BoxDecoration(
        color: AppColors.panelBackgroundColor,
        borderRadius: BorderRadius.circular(16.radius),
        border: Border.all(color: AppColors.lavenderE2E8F0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoItem(
            Icons.location_on_outlined,
            'Location',
            job.location,
            AppColors.royalBlue3B82F6,
          ),
          _buildInfoItem(
            Icons.work_outline,
            'Type',
            job.jobTypeLabel,
            AppColors.lightSeaGreen10B981,
          ),
          _buildInfoItem(
            Icons.currency_exchange_outlined,
            'Salary',
            job.salaryRange,
            AppColors.orangeF59E0B,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.width),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20.fontSize),
          ),
          SizedBox(height: 8.height),
          Text(
            label,
            style: getTextStyle(
              fontSize: 11.fontSize,
              color: AppColors.darkGray94A3B8,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.height),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: getTextStyle(
              fontSize: 13.fontSize,
              fontWeight: FontWeight.w600,
              color: AppColors.darkSlateGray1E293B,
            ),
          ),
        ],
      ),
    );
  }
}
