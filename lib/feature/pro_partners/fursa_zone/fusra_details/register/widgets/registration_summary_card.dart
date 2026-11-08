import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class RegistrationSummaryCard extends StatelessWidget {
  const RegistrationSummaryCard({
    super.key,
    required this.title,
    required this.totalRegistrations,
  });

  final String title;
  final int totalRegistrations;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.lavenderD9E6F5),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.floralWhiteFFFBF2, AppColors.aliceBlueF2F8FF],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.emoji_events_outlined,
                  color: AppColors.black0F172A,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: getTextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Total Registrations',
            style: getTextStyle(fontSize: 14, color: AppColors.darkSlateGray475569),
          ),
          const SizedBox(height: 4),
          Text(
            '$totalRegistrations',
            style: getTextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.black0F172A,
            ),
          ),
        ],
      ),
    );
  }
}
