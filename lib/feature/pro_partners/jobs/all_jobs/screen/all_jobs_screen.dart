import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:msollaally/feature/pro_partners/more/controller/pro_partners_more_controller.dart';

import 'package:msollaally/feature/pro_partners/widgets/default_pro_partners_app_bar.dart';
import '../controller/all_jobs_controller.dart';
import '../widgets/job_card_widget.dart';

class ProPartnersAllJobsScreen extends StatelessWidget {
  ProPartnersAllJobsScreen({super.key});

  final AllJobsController controller = Get.put(AllJobsController());
  final ProPartnersMoreController moreController = Get.put(
    ProPartnersMoreController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Obx(() {
          final profileImageUrl =
              moreController.me.value?.profile?.profilePicture ?? '';
          return DefaultProPartnersAppBar(
            title: 'Jobs',
            profileImageUrl: profileImageUrl,
            notificationCount: 9,
          );
        }),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 6.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jobs',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.appBarTitleColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Manage your job postings and applications',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.tertiaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => controller.openCreateJob(),
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text(
                    'Post Job',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButtonColor,
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 42.h,
            child: Obx(() {
              final selectedIndex = controller.selectedStatusIndex.value;
              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                scrollDirection: Axis.horizontal,
                itemCount: controller.jobStatuses.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (_, index) {
                  final status = controller.jobStatuses[index];
                  final isSelected = selectedIndex == index;
                  final label = status[0].toUpperCase() + status.substring(1);
                  return InkWell(
                    borderRadius: BorderRadius.circular(20.r),
                    onTap: () => controller.changeStatusTab(index),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryButtonColor
                            : AppColors.whiteSmokeF4F4F5,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryButtonColor
                              : AppColors.sectionBorderColor,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.appBarTitleColor,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          SizedBox(height: 6.h),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final items = controller.jobs;
              if (items.isEmpty) {
                return const Center(child: Text('No jobs found'));
              }

              return RefreshIndicator(
                onRefresh: controller.fetchAllJobs,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.pixels >=
                        notification.metrics.maxScrollExtent - 200) {
                      controller.fetchAllJobs(isLoadMore: true);
                    }
                    return false;
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 6.h, bottom: 80.h),
                    itemCount:
                        items.length + (controller.isLoadingMore.value ? 1 : 0),
                    itemBuilder: (ctx, i) {
                      if (i >= items.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return JobCardWidget(job: items[i]);
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: SizedBox(height: 20.h),
    );
  }
}
