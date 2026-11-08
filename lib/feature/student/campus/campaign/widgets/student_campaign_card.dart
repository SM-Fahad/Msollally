import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import '../../../../../core/common/styles/global_text_style.dart';
import '../../../../../routes/app_route.dart';
import '../service/student_campus_campaign_service.dart';

class StudentCampaignCard extends StatelessWidget {
  final Map<String, String> campaign;
  const StudentCampaignCard({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    final isActive = campaign['tag'] == 'Active';

    return InkWell(
      onTap: () {
        final campaignId = campaign['id'];
        if (campaignId != null && campaignId.isNotEmpty) {
          final service = StudentCampusCampaignService();
          service.trackCampaignView(campaignId);
          service.trackCampaignImpression(campaignId);
        }
        Get.toNamed(AppRoute.studentCampusCampaignDetail, arguments: campaign);
      },
      borderRadius: BorderRadius.circular(12.radius),
      child: Container(
        padding: EdgeInsets.all(16.width),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.radius),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Details Left Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campaign['title']!,
                    style: appTextStyleHeading1(
                      fontSize: 16.fontSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black09090B,
                    ),
                  ),
                  SizedBox(height: 8.height),
                  Row(
                    children: [
                      // Active / Completed Tag
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.width,
                          vertical: 4.height,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.honeydewE8F5E9
                              : AppColors.todaysQuickPicContainerBGColor,
                          borderRadius: BorderRadius.circular(4.radius),
                        ),
                        child: Text(
                          campaign['tag']!,
                          style: getTextStyle(
                            color: isActive
                                ? AppColors.forestGreen2E7D32
                                : AppColors.gray757575,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.width),
                      // Subtext
                      Flexible(
                        child: Text(
                          "${campaign['clicks']} • ${campaign['spent']}",
                          style: getTextStyle(
                            color: AppColors.tertiaryTextColor,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.width),
            // Company Branding Right Column
            SizedBox(
              width: 72.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44.width,
                    height: 44.width,
                    decoration: BoxDecoration(
                      color: AppColors.ghostWhiteF8F9FB,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: (campaign['authorAvatar'] != null &&
                            campaign['authorAvatar']!.isNotEmpty)
                        ? ClipOval(
                            child: Image.network(
                              campaign['authorAvatar']!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.business,
                                size: 22.fontSize,
                                color: AppColors.primaryButtonColor,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.business,
                            size: 22.fontSize,
                            color: AppColors.primaryButtonColor,
                          ),
                  ),
                  SizedBox(height: 6.height),
                  Text(
                    campaign['authorName'] ?? 'Partner',
                    style: getTextStyle(
                      color: AppColors.black1A1C1E,
                      fontSize: 11.fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
