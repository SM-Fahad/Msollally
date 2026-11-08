import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class RegisteredStudents extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const RegisteredStudents({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 106,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        gradient: const LinearGradient(
          colors: [AppColors.ghostWhiteFAF5FF, AppColors.aliceBlueEFF6FF],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.blueViolet7B3FE4),
              const SizedBox(width: 8),
              Text(
                title,
                style: getTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: getTextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
