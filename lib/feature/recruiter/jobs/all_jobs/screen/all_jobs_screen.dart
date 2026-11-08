import 'package:flutter/foundation.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/const/icons_path.dart' show IconsPath;
import 'package:msollaally/feature/recruiter/widgets/default_recruiter_app_bar.dart';
import 'package:msollaally/feature/recruiter/jobs/add_job/screen/add_job_screen.dart';
import 'package:msollaally/feature/recruiter/jobs/add_job/model/add_job_model.dart';
import '../controller/all_jobs_controller.dart';
import '../widgets/job_card_widget.dart';
import 'package:msollaally/feature/recruiter/jobs/job_details/screen/job_details_screen.dart';
import 'package:msollaally/feature/recruiter/jobs/job_details/controller/job_details_controller.dart';
import '../widgets/jobs_filter_sheet_widget.dart';
import '../widgets/job_stat_card.dart';

class RecruiterAllJobsScreen extends StatelessWidget {
  RecruiterAllJobsScreen({super.key});

  final AllJobsController controller = Get.put(AllJobsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultRecruiterAppBar(
        title: 'Jobs',
        isHomePage: false,
        profileImageUrl: controller.profileImageUrl,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 12.h),
              _buildStats(),
              SizedBox(height: 16.h),
              _buildFilterRow(context),
              SizedBox(height: 12.h),
              Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.h),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (controller.error.value.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.h),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppColors.salmonFF6B6B,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Error Loading Jobs',
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
                    ),
                  );
                }

                if (controller.filteredJobs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.h),
                      child: Column(
                        children: [
                          Icon(
                            Icons.work_outline,
                            size: 64,
                            color: AppColors.darkGray94969D,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No jobs found',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.appBarTitleColor,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Try selecting a different status',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.darkGray94969D,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: controller.filteredJobs.length,
                  itemBuilder: (context, index) {
                    final job = controller.filteredJobs[index];
                    return JobCardWidget(
                      job: job,
                      onTap: () async {
                        Get.delete<JobDetailsController>();
                        Get.put(JobDetailsController(jobId: job.id));
                        final result = await Get.to(() => JobDetailsScreen());
                        if (result == 'deleted') {
                          if (kDebugMode) {
                            print('Job deleted, refreshing list...');
                          }
                          await controller.refreshJobs();
                        }
                      },
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Job Listings',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            final result = await Get.to(() => AddJobScreen());
            if (result is AddJobModel) {
              await controller.refreshJobs();
            }
          },
          icon: Icon(Icons.add, size: 18),
          label: Text('Create job', style: TextStyle(fontSize: 14.sp)),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Obx(
      () => Wrap(
        spacing: 12.w,
        runSpacing: 12.h,
        children: [
          _statContainer(
            controller.totalJobs.value.toString(),
            'Total Jobs',
            IconsPath.recruiterJobsInactive,
          ),
          _statContainer(
            controller.activeJobs.value.toString(),
            'Open Jobs',
            IconsPath.starIcon,
          ),
          _statContainer(
            controller.closedJobs.value.toString(),
            'Closed Jobs',
            IconsPath.starIcon,
          ),
          _statContainer(
            controller.draftJobs.value.toString(),
            'Draft Jobs',
            IconsPath.recruiterJobsInactive,
          ),
          _statContainer(
            controller.totalApplications.value.toString(),
            'Candidates',
            IconsPath.studentsIconTeacherFlow,
          ),
          _statContainer(
            controller.totalViews.value.toString(),
            'Total Views',
            IconsPath.studentsIconTeacherFlow,
          ),
          _statContainer(
            controller.appliedToday.value.toString(),
            'Applied Today',
            IconsPath.studentsIconTeacherFlow,
          ),
        ],
      ),
    );
  }

  Widget _statContainer(String val, String lbl, String path) {
    return SizedBox(
      width: (ScreenUtil().screenWidth - 48.w) / 2,
      child: JobStatCard(value: val, label: lbl, iconPath: path),
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'All Jobs',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        OutlinedButton.icon(
          onPressed: () => showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            ),
            builder: (_) => JobsFilterSheetWidget(),
          ),
          icon: Icon(Icons.filter_list, size: 18),
          label: Text('Filter'),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        ),
      ],
    );
  }
}
