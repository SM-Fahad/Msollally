import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import '../../../../../core/common/styles/global_text_style.dart';

class CampaignHeaderSection extends StatelessWidget {
  final String campaignId;
  final String title;
  final String tag;
  final String authorName;
  final String authorAvatar;
  final bool isSponsored;

  const CampaignHeaderSection({
    super.key,
    required this.campaignId,
    required this.title,
    required this.tag,
    required this.authorName,
    this.authorAvatar = '',
    required this.isSponsored,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = tag.toLowerCase() == 'active';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row containing Status Tag and Sponsored Tag
        Row(
          children: [
            // Status Tag
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 6.height),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.honeydewE8F5E9
                    : AppColors.cornsilkFFF3E0,
                borderRadius: BorderRadius.circular(6.radius),
              ),
              child: Text(
                tag,
                style: getTextStyle(
                  color: isActive
                      ? AppColors.forestGreen2E7D32
                      : AppColors.orangeRedE65100,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            if (isSponsored) ...[
              SizedBox(width: 8.width),
              // Sponsored Tag
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 6.height),
                decoration: BoxDecoration(
                  color: AppColors.lightYellowFFFDE7,
                  borderRadius: BorderRadius.circular(6.radius),
                  border: Border.all(color: AppColors.khakiFFF59D),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 14.fontSize,
                      color: AppColors.goldFBC02D,
                    ),
                    SizedBox(width: 4.width),
                    Text(
                      'Sponsored',
                      style: getTextStyle(
                        color: AppColors.darkOrangeF57F17,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 12.height),

        // Title
        Text(
          title,
          style: appTextStyleHeading1(
            fontSize: 24.fontSize,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 10.height),

        // Organizer Company Row with Logo and Name
        Row(
          children: [
            Container(
              width: 32.width,
              height: 32.width,
              decoration: BoxDecoration(
                color: AppColors.ghostWhiteF8F9FB,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: authorAvatar.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        authorAvatar,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.business,
                          size: 18.fontSize,
                          color: AppColors.primaryButtonColor,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.business,
                      size: 18.fontSize,
                      color: AppColors.primaryButtonColor,
                    ),
            ),
            SizedBox(width: 10.width),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authorName.isNotEmpty ? authorName : 'Partner Company',
                    style: appTextStyleHeading2(
                      fontSize: 14.fontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Campaign Organizer',
                    style: TextStyle(
                      fontSize: 11.fontSize,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
