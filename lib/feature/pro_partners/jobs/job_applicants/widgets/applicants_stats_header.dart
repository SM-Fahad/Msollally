// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/pro_partners/jobs/job_applicants/controller/job_applicants_controller.dart';

class ApplicantsStatsHeader extends StatelessWidget {
  final String controllerTag;
  final String jobTitle;

  ApplicantsStatsHeader({
    super.key,
    required this.controllerTag,
    required this.jobTitle,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JobApplicantsController>(tag: controllerTag);

    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Color.fromARGB(255, 82, 125, 243),
              // gradient: LinearGradient(
              //   colors: [AppColors.black0F172A, AppColors.darkSlateBlue1E3A8A],
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              // ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jobTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Review applicants, open resumes, and make decisions from a single polished flow.',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    color: AppColors.lavenderE2E8F0,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.55,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              _StatsCard(
                label: 'Total',
                value: controller.totalCount.value.toString(),
                icon: Icons.groups_2_outlined,
                tint: AppColors.lavenderDBEAFE,
                accent: AppColors.royalBlue1D4ED8,
              ),
              _StatsCard(
                label: 'Applicants',
                value: controller.pendingCount.value.toString(),
                icon: Icons.hourglass_top_rounded,
                tint: AppColors.lavenderE0F2FE,
                accent: AppColors.teal0369A1,
              ),
              _StatsCard(
                label: 'Shortlisted',
                value: controller.shortlistedCount.value.toString(),
                icon: Icons.task_alt_outlined,
                tint: AppColors.honeydewDCFCE7,
                accent: AppColors.forestGreen15803D,
              ),
              _StatsCard(
                label: 'Rejected',
                value: controller.rejectedCount.value.toString(),
                icon: Icons.do_not_disturb_alt_outlined,
                tint: AppColors.mistyRoseFFE4E6,
                accent: AppColors.crimsonDC2626,
              ),
            ],
          ),
        ],
      );
    });
  }
}

class _StatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color tint;
  final Color accent;

  _StatsCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.black0F172A.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black0F172A,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(fontSize: 12.5, color: AppColors.slateGray64748B),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
