import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import '../../../../../core/common/styles/global_text_style.dart';

class CampaignEligibilityCriteria extends StatelessWidget {
  final String university;
  final String major;
  final String yearOfStudy;

  const CampaignEligibilityCriteria({
    super.key,
    required this.university,
    required this.major,
    required this.yearOfStudy,
  });

  @override
  Widget build(BuildContext context) {
    if (university.isEmpty && major.isEmpty && yearOfStudy.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.height),
        Text(
          'Eligibility Criteria',
          style: appTextStyleHeading1(
            fontSize: 18.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.height),
        if (university.isNotEmpty)
          _buildStatItem(
            Icons.school_outlined,
            'Target University',
            university,
          ),
        if (major.isNotEmpty)
          _buildStatItem(Icons.menu_book_outlined, 'Target Major', major),
        if (yearOfStudy.isNotEmpty)
          _buildStatItem(
            Icons.timeline_outlined,
            'Target Year of Study',
            'Year $yearOfStudy',
          ),
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
