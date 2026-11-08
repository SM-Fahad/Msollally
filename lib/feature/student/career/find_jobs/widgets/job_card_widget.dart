import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import '../controller/jobs.controller.dart';
import '../model/jobs.model.dart';
import '../screen/job_details_screen.dart';

class JobCard extends StatelessWidget {
  final JobModel job;
  final JobController controller;

  const JobCard({super.key, required this.job, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.height),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.radius),
        border: Border.all(color: AppColors.gainsboroE5E5E5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.width),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title and Company
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: appTextStyleHeading1(
                          fontSize: 20.fontSize,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkSlateGray333333,
                        ),
                      ),
                      SizedBox(height: 4.height),
                      Text(
                        '${job.company} • ${job.location}',
                        style: appTextStyleHeading2(
                          fontSize: 14.fontSize,
                          color: AppColors.darkGray999999,
                        ),
                      ),
                    ],
                  ),
                ),
                // Deadline
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Deadline',
                      style: appTextStyleHeading2(
                        fontSize: 13.fontSize,
                        color: AppColors.darkSlateGray333333,
                      ),
                    ),
                    SizedBox(height: 4.height),
                    Text(
                      _formatDeadline(job.applicationDeadline),
                      style: appTextStyleHeading1(
                        fontSize: 13.fontSize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.tomatoFF4D4D,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.height),
            // Tags
            Wrap(
              spacing: 8.width,
              runSpacing: 8.height,
              children: [
                _buildTag(job.jobTypeLabel),
                ...job.professionalSkills
                    .take(2)
                    .map((skill) => _buildTag(skill)),
              ],
            ),
            SizedBox(height: 16.height),
            Divider(color: AppColors.whiteSmokeEEEEEE, height: 1.height),
            SizedBox(height: 12.height),
            // View Details Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  controller.fetchJobDetails(job.id);
                  Get.to(() => JobDetailsScreen(jobId: job.id));
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryButtonColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.radius),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.height),
                ),
                child: Text(
                  'View Details',
                  style: appTextStyleHeading2(
                    fontSize: 16.fontSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryButtonColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 6.height),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50.radius),
        border: Border.all(color: AppColors.gainsboroE0E0E0),
      ),
      child: Text(
        label,
        style: appTextStyleHeading2(
          fontSize: 12.fontSize,
          color: AppColors.dimGray666666,
        ),
      ),
    );
  }

  String _formatDeadline(String isoDate) {
    if (isoDate.isEmpty) return 'N/A';
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return isoDate;
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
