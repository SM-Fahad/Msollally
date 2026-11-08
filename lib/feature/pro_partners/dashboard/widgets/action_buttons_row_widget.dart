// lib/widgets/action_buttons_row_widget.dart
import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/pro_partners/campaign/create_campaign/screen/create_campaign_screen.dart';
import 'package:msollaally/feature/pro_partners/events/create_event/screen/create_event_screen.dart';
import 'package:msollaally/feature/pro_partners/jobs/create_job/screen/create_job_screen.dart';

class ProPartnersActionButtonsWidget extends StatelessWidget {
  const ProPartnersActionButtonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 1. Campaign Button (Primary/Highlighted)
        Expanded(
          child: _buildButton(
            title: 'Campaign',
            icon: Icons.campaign_rounded,
            isPrimary: false, // Highlights this button with primary color
            onTap: () => Get.to(() => const CreateCampaignScreen()),
          ),
        ),
        SizedBox(width: 12.w),

        // 2. Event Button (Secondary/White)
        Expanded(
          child: _buildButton(
            title: 'Event',
            icon: Icons.event_rounded,
            isPrimary: false,
            onTap: () => Get.to(() => CreateEventScreen()),
          ),
        ),
        SizedBox(width: 12.w),

        // 3. Job Button (Secondary/White)
        Expanded(
          child: _buildButton(
            title: 'Job',
            icon: Icons.work_rounded,
            isPrimary: false,
            onTap: () => Get.to(() => CreateJobScreen()),
          ),
        ),
      ],
    );
  }

  // Reusable builder for the buttons
  Widget _buildButton({
    required String title,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primaryButtonColor : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: isPrimary
              ? null
              : Border.all(
                  color: AppColors.primaryButtonColor.withValues(alpha: .3),
                ),
          boxShadow: [
            BoxShadow(
              color: isPrimary
                  ? AppColors.primaryButtonColor.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: isPrimary ? Colors.white : AppColors.primaryButtonColor,
            ),
            SizedBox(width: 6.w),
            Text(
              title,
              style: TextStyle(
                color: isPrimary ? Colors.white : AppColors.primaryButtonColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
