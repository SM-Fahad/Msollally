import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/recruiter/jobs/add_job/screen/add_job_screen.dart';
import 'package:msollaally/feature/recruiter/jobs/all_jobs/controller/all_jobs_controller.dart';
import 'package:msollaally/feature/recruiter/home/controller/recruiter_home_controller.dart';
import '../model/job_details_model.dart';
import '../controller/job_details_controller.dart';

class JobDetailsTabWidget extends StatelessWidget {
  final JobDetailsModel job;
  const JobDetailsTabWidget({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JobDetailsController>();

    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jobs Details',
                style: TextStyle(color: AppColors.blackAlpha7F1E1E1E, fontSize: 16),
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: AppColors.blackAlpha7F1E1E1E),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    builder: (_) => Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 4),
                            title: Text(
                              'Update job status',
                              style: TextStyle(fontSize: 16),
                            ),
                            trailing: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.lavenderF3E8FF,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.edit, color: AppColors.blueViolet7C4DFF),
                            ),
                            onTap: () async {
                              Get.back();
                              showModalBottomSheet(
                                context: context,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                ),
                                builder: (_) => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _statusOption(context, controller, 'draft'),
                                    Divider(height: 1),
                                    _statusOption(
                                      context,
                                      controller,
                                      'closed',
                                    ),
                                    Divider(height: 1),
                                    _statusOption(
                                      context,
                                      controller,
                                      'filled',
                                    ),
                                    Divider(height: 1),
                                    _statusOption(
                                      context,
                                      controller,
                                      'archived',
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          Divider(height: 1),
                          ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 4),
                            title: Text('Edit', style: TextStyle(fontSize: 16)),
                            trailing: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.lavenderF3E8FF,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.edit, color: AppColors.blueViolet7C4DFF),
                            ),
                            onTap: () async {
                              Get.back();
                              final result = await Get.to(
                                () => AddJobScreen(editJob: job),
                              );
                              if (result != null) {
                                await controller.refreshJobDetails();
                              }
                            },
                          ),
                          Divider(height: 1),
                          ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 4),
                            title: Text(
                              'Delete',
                              style: TextStyle(fontSize: 16),
                            ),
                            trailing: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.lavenderBlushFFF0F0,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.delete_outline,
                                color: AppColors.tomatoF44336,
                              ),
                            ),
                            onTap: () {
                              Get.back();
                              _showDeleteConfirmation(context, controller);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  job.title,
                  style: TextStyle(
                    color: AppColors.appBarTitleColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.checkBoxActiveColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    job.status,
                    style: TextStyle(color: AppColors.checkBoxActiveColor, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryButtonColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(child: _leftColumn()),
                SizedBox(width: 16),
                _rightColumn(),
              ],
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 22),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Professional Skill',
                  style: TextStyle(color: AppColors.appBarTitleColor, fontSize: 16),
                ),
                SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: job.skills.map((s) => _skillChip(s)).toList(),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Text(
            'About The Jobs',
            style: TextStyle(color: AppColors.blackAlpha7F1E1E1E, fontSize: 16),
          ),
          SizedBox(height: 12),
          Text(
            job.about,
            style: TextStyle(
              color: AppColors.appBarTitleColor,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _skillChip(String label) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
      borderRadius: BorderRadius.circular(50),
    ),
    child: Text(
      label,
      style: TextStyle(color: AppColors.appBarTitleColor, fontSize: 14),
    ),
  );

  Widget _leftColumn() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _infoRow('Salary', job.salary),
      SizedBox(height: 8),
      _infoRow('Type', job.type),
      SizedBox(height: 8),
      _infoRow('Location', job.location),
    ],
  );

  Widget _rightColumn() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _infoRow('Experience', job.experience),
      SizedBox(height: 8),
      _infoRow('Education', job.education),
      SizedBox(height: 8),
      _infoRow('Deadline', job.deadline),
    ],
  );

  Widget _infoRow(String title, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: TextStyle(color: AppColors.darkSlateGrayAlphaB23F3F3F, fontSize: 12)),
      SizedBox(height: 2),
      Text(value, style: TextStyle(color: AppColors.appBarTitleColor, fontSize: 14)),
    ],
  );

  Widget _statusOption(
    BuildContext context,
    JobDetailsController controller,
    String status,
  ) => ListTile(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    title: Text(
      status[0].toUpperCase() + status.substring(1),
      style: TextStyle(fontSize: 16),
    ),
    onTap: () async {
      // close the bottom sheet with status options
      Get.back();

      // show a simple progress dialog while updating
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 16),
              Text('Updating...'),
            ],
          ),
        ),
      );
      await controller.updateJobStatus(status);
      Get.back();

      if (Get.isRegistered<AllJobsController>()) {
        await Get.find<AllJobsController>().refreshJobs();
      }

      if (Get.isRegistered<RecruiterHomeController>()) {
        await Get.find<RecruiterHomeController>().refreshLatestJob();
      }

      Get.back();
    },
  );

  void _showDeleteConfirmation(
    BuildContext context,
    JobDetailsController controller,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Delete Job',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.tomatoF44336,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this job post? This action cannot be undone.',
          style: TextStyle(fontSize: 14, color: AppColors.appBarTitleColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: AppColors.appBarTitleColor)),
          ),
          Obx(
            () => TextButton(
              onPressed: controller.isDeleting.value
                  ? null
                  : () {
                      controller.deleteJob();
                      Navigator.of(context).pop();
                    },
              child: controller.isDeleting.value
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('Delete', style: TextStyle(color: AppColors.tomatoF44336)),
            ),
          ),
        ],
      ),
    );
  }
}
