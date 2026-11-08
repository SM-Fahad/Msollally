import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import '../../model/jobs.model.dart';

class JobDetailHeader extends StatelessWidget {
  final JobModel job;
  const JobDetailHeader({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64.width,
              height: 64.width,
              padding: EdgeInsets.all(6.width),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.radius),
                border: Border.all(color: AppColors.whiteSmokeEDF0F3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: job.companyLogo.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12.radius),
                      child: Image.network(
                        job.companyLogo,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.business_center_outlined,
                            size: 32.fontSize,
                            color: AppColors.primaryButtonColor,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.business_center_outlined,
                      size: 32.fontSize,
                      color: AppColors.primaryButtonColor,
                    ),
            ),
            SizedBox(width: 16.width),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: getTextStyle(
                      fontSize: 22.fontSize,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black1A1C1E,
                    ),
                  ),
                  SizedBox(height: 6.height),
                  Text(
                    job.company,
                    style: getTextStyle(
                      fontSize: 16.fontSize,
                      color: AppColors.dimGray6C7278,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16.height),
        Row(
          children: [
            if (job.department.isNotEmpty) ...[
              _buildSmallBadge(Icons.category_outlined, job.department),
              SizedBox(width: 12.width),
            ],
            _buildSmallBadge(
              Icons.calendar_today_outlined,
              'Posted ${_formatDate(job.postedDate)}',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallBadge(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.width, vertical: 6.height),
      decoration: BoxDecoration(
        color: AppColors.whiteSmokeF1F5F9,
        borderRadius: BorderRadius.circular(8.radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.fontSize, color: AppColors.slateGray64748B),
          SizedBox(width: 6.width),
          Text(
            text,
            style: getTextStyle(
              fontSize: 12.fontSize,
              color: AppColors.slateGray64748B,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
