import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/recruiter/jobs/job_details/widgets/rejected_tab_widget.dart';
import 'package:msollaally/feature/recruiter/jobs/job_details/widgets/reserved_tab_widget.dart';
import '../controller/job_details_controller.dart';
import '../widgets/job_details_tab_widget.dart';
import '../widgets/candidates_tab_widget.dart';
import '../widgets/shortlisted_tab_widget.dart';

class JobDetailsScreen extends GetView<JobDetailsController> {
  const JobDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.primaryTextColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Obx(
              () => Text(
                controller.jobDetails.value != null
                    ? 'Job Details: ${controller.jobDetails.value!.title}'
                    : 'Job Details',
                style: TextStyle(
                  color: AppColors.primaryTextColor,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            centerTitle: true,
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _tabButton('Job Details', 0, controller),
                  SizedBox(width: 12),
                  _tabButton('Candidates', 1, controller),
                  SizedBox(width: 12),
                  _tabButton('Shortlisted', 2, controller),
                  SizedBox(width: 12),
                  _tabButton('Reserved', 3, controller),
                  SizedBox(width: 12),
                  _tabButton('Rejected', 4, controller),
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.error.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.salmonFF6B6B,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Error Loading Job',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.appBarTitleColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        controller.error.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.darkGray94969D,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (controller.jobDetails.value == null) {
                return Center(child: Text('No job data available'));
              }

              final job = controller.jobDetails.value!;

              if (controller.selectedIndex.value == 0) {
                return JobDetailsTabWidget(job: job);
              }
              if (controller.selectedIndex.value == 1) {
                return CandidatesTabWidget();
              }
              if (controller.selectedIndex.value == 2) {
                return ShortlistedTabWidget();
              }
              if (controller.selectedIndex.value == 3) {
                return ReservedTabWidget();
              }
              return RejectedTabWidget();
            }),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String label, int index, JobDetailsController controller) {
    return Obx(() {
      final selected = controller.selectedIndex.value == index;
      return GestureDetector(
        onTap: () => controller.changeTab(index),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryButtonColor.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.appBarTitleColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    });
  }
}
