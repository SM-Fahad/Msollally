import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class ProPartnersQuizCompetitionCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final Color tagColor;
  final Color tagTextColor;
  final String tagText;
  final String leftText;
  final String endText;
  final VoidCallback? onTap;

  const ProPartnersQuizCompetitionCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.tagColor,
    required this.tagTextColor,
    required this.tagText,
    required this.leftText,
    required this.endText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: getTextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.darkSlateGray3F3F46,
              ),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 160,
                    width: double.infinity,
                    color: Colors.blueGrey.withAlpha(50),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_outlined,
                      color: AppColors.darkGray9CA3AF,
                      size: 34,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            DefaultTextStyle(
              style: getTextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppColors.darkGrayA1A1AA,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: tagColor,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: tagTextColor.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Text(
                      tagText,
                      style: getTextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: tagTextColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(leftText),
                  const Spacer(),
                  Expanded(
                    child: Text(
                      endText,
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
