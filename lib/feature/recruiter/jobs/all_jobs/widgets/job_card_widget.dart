import 'package:flutter/foundation.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:msollaally/feature/recruiter/jobs/all_jobs/model/recruter_job_model.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/recruiter/jobs/job_details/screen/job_details_screen.dart';
import 'package:msollaally/feature/recruiter/jobs/job_details/controller/job_details_controller.dart';
import 'package:msollaally/feature/recruiter/jobs/all_jobs/controller/all_jobs_controller.dart';
import 'package:msollaally/core/common/widgets/fullscreen_image_view.dart';

class JobCardWidget extends StatelessWidget {
  final JobModel job;
  final VoidCallback? onTap;
  const JobCardWidget({super.key, required this.job, this.onTap});

  bool _isOpenStatus() {
    return job.status.toLowerCase() == 'open' ||
        job.status.toLowerCase() == 'published';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          onTap ??
          () async {
            Get.delete<JobDetailsController>();
            Get.put(JobDetailsController(jobId: job.id));

            // Listen for result (delete event)
            final result = await Get.to(() => JobDetailsScreen());

            // If job was deleted, refresh the list
            if (result == 'deleted') {
              if (kDebugMode) {
                print('Job deleted, refreshing list...');
              }
              final allJobsController = Get.find<AllJobsController>();
              await allJobsController.refreshJobs();
            }
          },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.mediumPurpleAlpha5B8757F3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Get.to(
                  () => FullscreenImageView(
                    imageUrl: job.imageUrl,
                    isNetworkImage: job.imageUrl.startsWith('http'),
                    isFileImage: false,
                  ),
                );
              },
              child: Container(
                height: 114.h,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: job.imageUrl.startsWith('http')
                    ? Image.network(
                        job.imageUrl,
                        width: double.infinity,
                        height: 114.h,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Image.asset(
                          'assets/images/book1.png',
                          width: double.infinity,
                          height: 114.h,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        job.imageUrl,
                        width: double.infinity,
                        height: 114.h,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.appBarTitleColor,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: _isOpenStatus()
                            ? AppColors.checkBoxActiveColor
                            : AppColors.darkGray94969D,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      job.status,
                      style: TextStyle(
                        color: _isOpenStatus()
                            ? AppColors.checkBoxActiveColor
                            : AppColors.darkGray94969D,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              job.description,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.darkSlateGrayAlphaB23F3F3F, fontSize: 14.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              'Salary: ${job.salary}',
              style: TextStyle(
                color: AppColors.appBarTitleColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.r),
                    border: Border.all(color: AppColors.darkSlateGrayAlpha1F3F3F3F),
                  ),
                  child: Text(job.level, style: TextStyle(fontSize: 14.sp)),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.r),
                    border: Border.all(color: AppColors.darkSlateGrayAlpha1F3F3F3F),
                  ),
                  child: Text(
                    job.experience,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Deadline: ${job.deadline}',
                  style: TextStyle(color: AppColors.darkGray94969D),
                ),
                Text(
                  'Job Post: ${job.postDate}',
                  style: TextStyle(color: AppColors.darkGray94969D),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
