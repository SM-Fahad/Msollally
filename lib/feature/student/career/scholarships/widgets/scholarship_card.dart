import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import '../model/scholarship_model.dart';
import '../screen/detail_screen.dart';

class ScholarshipCard extends StatelessWidget {
  final ScholarshipModel scholarship;

  const ScholarshipCard({super.key, required this.scholarship});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.width, vertical: 8.height),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.radius),
        border: Border.all(color: AppColors.gainsboroE5E5E5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.width),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (scholarship.fullFoundationLogoUrl.isNotEmpty ||
                    scholarship.fullThumbnailUrl.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.radius),
                    child: Container(
                      width: 48.width,
                      height: 48.width,
                      decoration: BoxDecoration(
                        color: AppColors.primaryButtonColor.withValues(
                          alpha: 0.08,
                        ),
                        border: Border.all(
                          color: AppColors.gainsboroE5E5E5,
                        ),
                        borderRadius: BorderRadius.circular(12.radius),
                      ),
                      child: Image.network(
                        scholarship.fullFoundationLogoUrl.isNotEmpty
                            ? scholarship.fullFoundationLogoUrl
                            : scholarship.fullThumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.apartment_rounded,
                          color: AppColors.primaryButtonColor,
                          size: 24.radius,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.width),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        scholarship.title,
                        style: appTextStyleHeading1(
                          fontSize: 18.fontSize,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkSlateGray333333,
                        ),
                      ),
                      SizedBox(height: 4.height),
                      // Subtitle / Organization
                      Text(
                        scholarship.foundationName,
                        style: appTextStyleHeading2(
                          fontSize: 13.fontSize,
                          color: AppColors.darkGray999999,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.height),
            Divider(color: AppColors.whiteSmokeEEEEEE, height: 1.height),
            SizedBox(height: 12.height),
            // Footer
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.width,
                    vertical: 6.height,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.honeydewEDF7ED,
                    borderRadius: BorderRadius.circular(50.radius),
                  ),
                  child: Text(
                    '${scholarship.currency} ${scholarship.amount}',
                    style: appTextStyleHeading2(
                      fontSize: 12.fontSize,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mediumSeaGreen4CAF50,
                    ),
                  ),
                ),
                SizedBox(width: 8.width),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.width,
                    vertical: 6.height,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cornsilkFFF3E0,
                    borderRadius: BorderRadius.circular(50.radius),
                  ),
                  child: Text(
                    'Due ${_formatDate(scholarship.dueDate)}',
                    style: appTextStyleHeading2(
                      fontSize: 12.fontSize,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkOrangeFF9800,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Get.to(
                    () => ScholarshipDetailScreen(scholarship: scholarship),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'View Details',
                    style: appTextStyleHeading2(
                      fontSize: 14.fontSize,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryButtonColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return 'N/A';
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return isoDate;
    final months = [
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
    return '${months[dt.month - 1]} ${dt.day}';
  }
}
