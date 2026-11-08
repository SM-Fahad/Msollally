import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/all_jobs_controller.dart';
import '../model/job_status_enum.dart';

class JobsFilterSheetWidget extends StatelessWidget {
  final AllJobsController controller = Get.find();

  JobsFilterSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by status',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          Obx(() {
            final selected = controller.statusFilter.value;
            return Column(
              children:
                  [
                    JobStatus.published,
                    JobStatus.closed,
                    JobStatus.draft,
                    JobStatus.filled,
                    JobStatus.archived,
                  ].map((status) {
                    final selectedFlag = selected == status;
                    return ListTile(
                      title: Text(
                        status.displayLabel,
                        style: TextStyle(
                          color: selectedFlag
                              ? AppColors.appBarTitleColor
                              : AppColors.darkGray94969D,
                        ),
                      ),
                      onTap: () {
                        controller.setStatusFilter(status);
                        Get.back();
                      },
                    );
                  }).toList(),
            );
          }),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }
}
