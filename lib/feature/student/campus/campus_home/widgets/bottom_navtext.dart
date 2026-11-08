import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';

class BottomNavText extends StatelessWidget {
  final String rankText;
  final String subText;

  const BottomNavText({
    super.key,
    required this.rankText,
    required this.subText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [AppColors.honeydewF0FFF4, AppColors.aliceBlueEBF8FF],
            ),
            // border: Border(
            //   top: BorderSide(color: AppColors.mediumSeaGreen48BB78, width: 1.5),
            // ),
          ),
          child: Column(
            children: [
              const Text("🎯", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                rankText,
                style: const TextStyle(
                  color: AppColors.darkSlateGray1E293B,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subText,
                style: const TextStyle(color: AppColors.slateGray64748B, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
