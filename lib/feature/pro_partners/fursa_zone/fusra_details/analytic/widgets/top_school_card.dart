import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class TopSchoolCard extends StatelessWidget {
  const TopSchoolCard({super.key, required this.school});

  final Map<String, dynamic> school;

  @override
  Widget build(BuildContext context) {
    final rank = school['rank'] ?? '-';
    final name = '${school['schoolName'] ?? 'Unknown School'}'.trim();
    final students = school['studentCount'] ?? 0;
    final avg = school['averageQualificationScore'] ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.panelBackgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.blueVioletA020F0,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: getTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Unknown School' : name,
                  style: getTextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Students: $students',
                  style: getTextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.honeydewEFFFF2,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.aquamarine86EFAC),
            ),
            child: Text(
              '$avg% Average Qualified',
              style: getTextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.seaGreen22A75A,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
