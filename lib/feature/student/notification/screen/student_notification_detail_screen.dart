import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/const/icons_path.dart';
import 'package:msollaally/core/services/notification_navigation_helper.dart';
import 'package:msollaally/feature/student/notification/controller/student_notification_detail_controller.dart';

class StudentNotificationDetailScreen extends StatelessWidget {
  StudentNotificationDetailScreen({super.key}) {
    controller = Get.put(StudentNotificationDetailController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.prepareDetails(Get.arguments);
    });
  }

  late final StudentNotificationDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Notification Details',
          style: getTextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.notification.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null &&
            controller.notification.value == null) {
          return _StudentNotificationStatusView(
            message: controller.errorMessage.value!,
            actionLabel: 'Retry',
            onActionTap: controller.fetchNotificationDetails,
          );
        }

        final notification = controller.notification.value;
        if (notification == null) {
          return const _StudentNotificationStatusView(
            message: 'Notification not found',
          );
        }

        final campaignName = notification.campaignName;

        return RefreshIndicator(
          onRefresh: controller.fetchNotificationDetails,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (campaignName != null && campaignName.isNotEmpty) ...[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: AppColors.royalBlue2563EB.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: AppColors.royalBlue2563EB.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.campaign_outlined,
                            size: 18.sp,
                            color: AppColors.royalBlue2563EB,
                          ),
                          SizedBox(width: 8.w),
                          Flexible(
                            child: Text(
                              'Campaign: $campaignName',
                              style: getTextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.royalBlue2563EB,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                  Text(
                    notification.title,
                    style: getTextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black09090B,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    notification.message,
                    style: getTextStyle(
                      fontSize: 15.sp,
                      height: 1.5,
                      color: AppColors.darkSlateGray334155,
                    ),
                  ),
                  if (notification.createdAt != null) ...[
                    SizedBox(height: 20.h),
                    _DetailMetaRow(
                      label: 'Received',
                      value: DateFormat(
                        'EEE, MMM d, yyyy hh:mm a',
                      ).format(notification.createdAt!.toLocal()),
                    ),
                  ],
                  if (campaignName != null && campaignName.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    _DetailMetaRow(
                      label: 'Campaign',
                      value: campaignName,
                    ),
                  ],
                  if (notification.actor != null ||
                      (notification.senderName != null &&
                          notification.senderName!.isNotEmpty)) ...[
                    SizedBox(height: 20.h),
                    Text(
                      'From: ${notification.senderName ?? notification.actor?['fullName'] ?? notification.actor?['name'] ?? notification.actor?['username'] ?? ''}',
                      style: getTextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _ActorCard(
                      actor: notification.actor ??
                          {'name': notification.senderName},
                    ),
                  ],
                  if (NotificationNavigationHelper.hasAction(notification)) ...[
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.royalBlue2563EB,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        onPressed: () =>
                            NotificationNavigationHelper.navigateToAction(
                              notification,
                            ),
                        child: const Text('Open'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}


class _DetailMetaRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailMetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88.w,
          child: Text(
            label,
            style: getTextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: getTextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _ActorCard extends StatelessWidget {
  final Map<String, dynamic> actor;

  const _ActorCard({required this.actor});

  @override
  Widget build(BuildContext context) {
    final username = actor['fullName']?.toString() ??
        actor['name']?.toString() ??
        actor['username']?.toString() ??
        'Unknown sender';
    final role = actor['role']?.toString() ?? '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            username,
            style: getTextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
          if (role.isNotEmpty)
            Text(
              role.toUpperCase(),
              style: getTextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
            ),
        ],
      ),
    );
  }
}

class _StudentNotificationStatusView extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const _StudentNotificationStatusView({
    required this.message,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(IconsPath.communityIcon, height: 64.h, width: 64.w),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: getTextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
            if (actionLabel != null && onActionTap != null) ...[
              SizedBox(height: 12.h),
              TextButton(
                onPressed: onActionTap,
                child: Text(
                  actionLabel!,
                  style: getTextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.markAllReadButtonColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
