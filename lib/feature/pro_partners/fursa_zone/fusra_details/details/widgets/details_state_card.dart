import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class StateCard extends StatelessWidget {
  const StateCard({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.ghostWhiteF9FAFB,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.sliderColorInboarding),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: AppColors.secondaryTextColor),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: getTextStyle(color: AppColors.secondaryTextColor),
          ),
        ],
      ),
    );
  }
}
