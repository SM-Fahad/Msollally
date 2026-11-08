import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';

class QuizCard extends StatelessWidget {
  final bool isEnabled;
  final bool isCompleted;
  final VoidCallback? onTap;

  final Color bgColor;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String tagText;
  final Color tagColor;
  final String buttonText;
  final Color buttonActiveColor;

  const QuizCard({
    super.key,
    this.isEnabled = true,
    this.isCompleted = false,
    this.onTap,
    this.bgColor = AppColors.aliceBlueEDF5FF,
    this.borderColor = AppColors.lavenderD0E2FF,
    this.icon = Icons.check_circle_outline_rounded,
    this.iconColor = AppColors.royalBlue2F69FF,
    this.title = 'Qualification Quiz',
    this.subtitle = 'Testing Mode Enabled',
    this.tagText = 'Stage 2',
    this.tagColor = AppColors.dodgerBlue1D61FF,
    this.buttonText = 'Start Qualification Quiz',
    this.buttonActiveColor = AppColors.dodgerBlue1D61FF,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isCompleted ? AppColors.checkBoxActiveColor : borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(isCompleted ? Icons.check_circle : icon, color: isCompleted ? AppColors.checkBoxActiveColor : iconColor, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.checkBoxActiveColor : tagColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isCompleted ? "Completed" : tagText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: isCompleted || !isEnabled ? null : onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.checkBoxActiveColor
                    : (isEnabled ? buttonActiveColor : AppColors.powderBlueC6D9FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  isCompleted ? "COMPLETED" : buttonText.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
