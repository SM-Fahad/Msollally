import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class CompetitionOverviewWidget extends StatelessWidget {
  const CompetitionOverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 353,
      height: 232,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Competition Overview',
            style: getTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Total Registered',
                          value: '15,420',
                          icon: Icons.people_outline,
                          backgroundColor: AppColors.lavenderE0ECFF,
                          borderColor: AppColors.lightSkyBlue8EC5FF,
                          iconColor: AppColors.royalBlue2563EB,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: _StatCard(
                          label: 'Finals Passed',
                          value: '1,000',
                          icon: Icons.emoji_events_outlined,
                          backgroundColor: AppColors.lavenderF3E8FF,
                          borderColor: AppColors.plumDAB2FF,
                          iconColor: AppColors.blueViolet9333EA,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Qualified',
                          value: '1,247',
                          icon: Icons.check_circle_outline,
                          backgroundColor: AppColors.gainsboroD1FAE5,
                          borderColor: AppColors.honeydewDCFCE7,
                          iconColor: AppColors.teal059669,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: _StatCard(
                          label: 'CTA',
                          value: '92.3%',
                          icon: Icons.trending_up,
                          backgroundColor: AppColors.lemonChiffonFEF3C7,
                          borderColor: AppColors.papayaWhipFFEDD4,
                          iconColor: AppColors.chocolateD97706,
                        ),
                      ),
                    ],
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170.5,
      height: 90,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.darkSlateGray4A5565,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 20, color: iconColor),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: getTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
