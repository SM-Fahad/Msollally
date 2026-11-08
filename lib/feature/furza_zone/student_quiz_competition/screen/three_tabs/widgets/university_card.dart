import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class UniversityCard extends StatelessWidget {
  final String indexText;
  final String title;
  final String subtitle;
  final String badgeText;

  const UniversityCard({
    super.key,
    required this.indexText,
    required this.title,
    required this.subtitle,
    required this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Fill
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left section
          Row(
            children: [
              // Index circle
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.blueViolet7B3FE4, // purple
                ),
                child: Text(
                  indexText,
                  style: getTextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Title + subtitle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: getTextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),
            ],
          ),

          // Right badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.honeydewE7F7EE,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badgeText,
              style: getTextStyle(
                fontSize: 12,
                color: AppColors.seaGreen1E8E5A,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
