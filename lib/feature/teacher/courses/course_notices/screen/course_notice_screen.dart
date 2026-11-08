import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/teacher/courses/course_notices/controller/course_notice_controller.dart';
import 'package:msollaally/feature/teacher/courses/course_notices/widget/notice_card.dart';
import 'package:msollaally/routes/app_route.dart';

class CourseNoticeScreen extends StatelessWidget {
  CourseNoticeScreen({super.key}) {
    controller = Get.isRegistered<CourseNoticeController>()
        ? Get.find<CourseNoticeController>()
        : Get.put(CourseNoticeController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initialize(Get.arguments);
    });
  }

  late final CourseNoticeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => RefreshIndicator(
        onRefresh: controller.fetchCourseNotices,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 18),
            child: Column(
              children: [
                if (controller.isLoadingNotices.value &&
                    controller.notices.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: CircularProgressIndicator(),
                  )
                else if (controller.notices.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: Text(
                      'No notices found for this course',
                      style: getTextStyle(
                        fontSize: 15,
                        color: Colors.grey[600]!,
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.notices.length,
                    itemBuilder: (context, index) {
                      final item = controller.notices[index];
                      return NoticeCard(
                        title: item.title,
                        message: item.notice,
                        dateLabel: _formatDate(item.createdAt),
                        onTap: () {
                          Get.toNamed(
                            AppRoute.teacherCourseNoticeDetailScreen,
                            arguments: {
                              'courseId': controller.currentCourseId.value,
                              'notice': item,
                            },
                          );
                        },
                      );
                    },
                  ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Get.toNamed(
                          AppRoute.teacherCreateCourseNoticeScreen,
                          arguments: {
                            'courseId': controller.currentCourseId.value,
                          },
                        );
                      },
                      icon: Icon(
                        Icons.add_circle_outline_outlined,
                        color: AppColors.primaryButtonColor,
                      ),
                      label: Text(
                        'Create Notice',
                        style: getTextStyle(
                          fontSize: 14,
                          color: AppColors.primaryButtonColor,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        side: BorderSide(
                          width: 2,
                          color: Colors.blue.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _formatDate(DateTime? value) {
    if (value == null) {
      return null;
    }
    return DateFormat('EEE, MMM d, yyyy').format(value.toLocal());
  }
}
