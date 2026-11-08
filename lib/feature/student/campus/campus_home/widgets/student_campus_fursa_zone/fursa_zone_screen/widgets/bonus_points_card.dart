import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/student_campus_controller.dart';
import 'package:msollaally/feature/student/campus/campus_home/model/bonus_data_model.dart';

class BonusCard extends StatelessWidget {
  const BonusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 16),
            child: Text(
              'Earn Bonus Points',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ),
          BonusItem(
            itemKey: 'share_social_media',
            icon: Icons.share_outlined,
            label: 'Share on social media',
            points: 5,
          ),
          const SizedBox(height: 8),
          BonusItem(
            itemKey: 'daily_login_streak',
            icon: Icons.access_time,
            label: 'Daily login streak: 3 days',
            points: 6,
          ),
          const SizedBox(height: 8),
          BonusItem(
            itemKey: 'early_completion_bonus',
            icon: Icons.emoji_events_outlined,
            label: 'Early completion bonus',
            points: 5,
          ),
        ],
      ),
    );
  }
}

class BonusItem extends StatelessWidget {
  final String itemKey;
  final IconData icon;
  final String label;
  final int points;

  const BonusItem({
    super.key,
    required this.itemKey,
    required this.icon,
    required this.label,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentCampusController>();

    return Obx(() {
      final isEarned = controller.bonusItemEarned[itemKey] ?? false;
      final displayLabel = itemKey == 'daily_login_streak'
          ? 'Daily login streak: ${controller.loginStreakDays.value} days'
          : label;
          
      // Determine bonus type for API lookup
      String apiType = '';
      if (itemKey == 'share_social_media') apiType = 'SOCIAL_SHARE';
      if (itemKey == 'daily_login_streak') apiType = 'LOGIN_STREAK';
      if (itemKey == 'early_completion_bonus') apiType = 'EARLY_COMPLETION';
      
      // Look up dynamic points, fallback to default 'points' param
      final dynamicBonus = controller.bonusData.firstWhere(
        (b) => b.type == apiType,
        orElse: () => BonusDataModel(type: '', claimed: false, coins: points),
      );
      final displayPoints = dynamicBonus.coins;

      return GestureDetector(
        onTap: () {
          if (!isEarned) controller.toggleBonusItemEarned(itemKey);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.ghostWhiteFBFBFE,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.darkSlateGray2D3142, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  displayLabel,
                  style: const TextStyle(
                    color: AppColors.darkSlateGray2D3142,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isEarned
                      ? AppColors.springGreen00E676
                      : AppColors.black0D0D0D,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isEarned)
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    Text(
                      '+$displayPoints pts',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
