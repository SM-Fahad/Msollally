import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class JobDetailSection extends StatelessWidget {
  final String title;
  final String? description;
  final List<String>? items;

  const JobDetailSection({
    super.key,
    required this.title,
    this.description,
    this.items,
  });

  @override
  Widget build(BuildContext context) {
    if ((description == null || description!.isEmpty) &&
        (items == null || items!.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _getSectionIcon(title),
            SizedBox(width: 8.width),
            Text(
              title,
              style: getTextStyle(
                fontSize: 18.fontSize,
                fontWeight: FontWeight.w700,
                color: AppColors.darkSlateGray1E293B,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.height),
        if (description != null && description!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: 4.width),
            child: Text(
              description!,
              style: getTextStyle(
                fontSize: 14.fontSize,
                color: AppColors.darkSlateGray475569,
                height: 1.6,
              ),
            ),
          ),
        if (items != null && items!.isNotEmpty)
          ...items!.map((item) => _buildBulletPoint(item)),
        SizedBox(height: 28.height),
      ],
    );
  }

  Widget _getSectionIcon(String title) {
    IconData icon;
    Color color;
    switch (title.toLowerCase()) {
      case 'description':
        icon = Icons.description_outlined;
        color = AppColors.royalBlue3B82F6;
        break;
      case 'responsibilities':
        icon = Icons.assignment_outlined;
        color = AppColors.mediumPurple8B5CF6;
        break;
      case 'requirements':
        icon = Icons.checklist_outlined;
        color = AppColors.tomatoEF4444;
        break;
      case 'benefits':
        icon = Icons.card_giftcard_outlined;
        color = AppColors.lightSeaGreen10B981;
        break;
      default:
        icon = Icons.info_outline;
        color = AppColors.slateGray64748B;
    }
    return Icon(icon, size: 20.fontSize, color: color);
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.height, left: 4.width),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 8.height),
            child: Container(
              width: 5.width,
              height: 5.width,
              decoration: const BoxDecoration(
                color: AppColors.darkGray94A3B8,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: 12.width),
          Expanded(
            child: Text(
              text,
              style: getTextStyle(
                fontSize: 14.fontSize,
                color: AppColors.darkSlateGray475569,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
