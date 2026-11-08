import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import '../controller/jobs.controller.dart';
import '../widgets/job_details/job_detail_bottom_bar.dart';
import '../widgets/job_details/job_detail_header.dart';
import '../widgets/job_details/job_detail_info_grid.dart';
import '../widgets/job_details/job_detail_section.dart';

class JobDetailsScreen extends StatelessWidget {
  final int jobId;
  const JobDetailsScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    final JobController controller = Get.find<JobController>();

    // Fetch details if not already loading or if it's a different job
    if (controller.selectedJob.value?.id != jobId &&
        !controller.isJobDetailsLoading.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchJobDetails(jobId);
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.black1A1C1E,
            size: 20.fontSize,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Job Details',
          style: getTextStyle(
            fontSize: 18.fontSize,
            fontWeight: FontWeight.w700,
            color: AppColors.black1A1C1E,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isJobDetailsLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryButtonColor),
          );
        }

        final job = controller.selectedJob.value;
        if (job == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48.fontSize,
                  color: Colors.red.shade300,
                ),
                SizedBox(height: 16.height),
                Text(
                  'Failed to load job details',
                  style: getTextStyle(color: AppColors.dimGray6C7278),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.width, vertical: 10.height),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    JobDetailHeader(job: job),
                    SizedBox(height: 24.height),
                    JobDetailInfoGrid(job: job),
                    SizedBox(height: 28.height),
                    JobDetailSection(
                      title: 'Description',
                      description: job.description,
                    ),
                    JobDetailSection(
                      title: 'Responsibilities',
                      items: job.responsibilities,
                    ),
                    JobDetailSection(
                      title: 'Requirements',
                      items: job.requirements,
                    ),
                    JobDetailSection(title: 'Benefits', items: job.benefits),
                  ],
                ),
              ),
            ),
            JobDetailBottomBar(job: job, controller: controller),
          ],
        );
      }),
    );
  }
}
