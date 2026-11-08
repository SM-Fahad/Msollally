import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/teacher/notification/controller/teacher_notification_controller.dart';
import 'package:msollaally/feature/teacher/notification/widget/notification_container.dart';
import 'package:msollaally/routes/app_route.dart';

class TeacherNotificationScreen extends StatelessWidget {
  TeacherNotificationScreen({super.key}) {
    controller = Get.put(TeacherNotificationController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchNotifications();
    });
  }

  late final TeacherNotificationController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification'),
        centerTitle: false,
        actions: [
          Obx(
            () => TextButton(
              onPressed: controller.isMarkingAllRead.value
                  ? null
                  : controller.markAllRead,
              child: Text(
                controller.isMarkingAllRead.value
                    ? 'Marking...'
                    : 'Mark All Read',
                style: getTextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.markAllReadButtonColor,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(() {
                return Row(
                  children: List.generate(
                    controller.categoryLabels.length,
                    (index) {
                      final isSelected =
                          controller.selectedCategoryIndex.value == index;
                      return GestureDetector(
                        onTap: () => controller.selectCategory(index),
                        child: Padding(
                          padding: EdgeInsets.only(right: 20.w),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                controller.categoryLabels[index],
                                style: getTextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.markAllReadButtonColor
                                      : AppColors.appBarTitleColor
                                          .withValues(alpha: 0.5),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Container(
                                height: 3.h,
                                width: 65.w,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.markAllReadButtonColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(2.r),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 8.h),
          Expanded(child: _NotificationList(controller: controller)),
        ],
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  final TeacherNotificationController controller;

  const _NotificationList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.notifications.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value != null &&
          controller.notifications.isEmpty) {
        return TeacherNotificationStatusView(
          message: controller.errorMessage.value!,
          actionLabel: 'Retry',
          onActionTap: controller.fetchNotifications,
        );
      }

      if (controller.notifications.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.refreshNotifications,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 180),
              TeacherNotificationStatusView(
                message: 'No notifications found',
              ),
            ],
          ),
        );
      }

      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 160) {
            controller.loadMoreNotifications();
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: controller.refreshNotifications,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: controller.notifications.length +
                (controller.isLoadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= controller.notifications.length) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }

              final item = controller.notifications[index];
              return NotificationContainer(
                notification: item,
                onTap: () => Get.toNamed(
                  AppRoute.teacherNotificationDetailScreen,
                  arguments: item,
                ),
                onDelete: () => controller.deleteNotification(item.id),
                onArchive: () => controller.archiveNotification(item.id),
              );
            },
          ),
        ),
      );
    });
  }
}
