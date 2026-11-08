import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';

class LearningPhaseAlert extends StatelessWidget {
  final bool isCompleted;
  
  const LearningPhaseAlert({
    super.key,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isCompleted ? AppColors.checkBoxActiveColor : AppColors.sliderColorInboarding, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Learning Phase",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black1D1D1D,
                ),
              ),
              Text(
                "Monday - Wednesday",
                style: TextStyle(fontSize: 14, color: AppColors.secondaryTextColor),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.checkBoxActiveColor.withValues(alpha: 0.1) : AppColors.ghostWhiteFAF5FF,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              isCompleted ? "Completed" : "Active",
              style: TextStyle(
                color: isCompleted ? AppColors.checkBoxActiveColor : AppColors.blueViolet9333EA,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
