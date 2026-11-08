import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
// import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/services/notification_navigation_helper.dart';
// import 'package:msollaally/feature/student/notification/model/student_notification_model.dart';
import 'package:msollaally/feature/teacher/notification/controller/teacher_notification_detail_controller.dart';
import 'package:msollaally/feature/teacher/notification/widget/notification_container.dart';

class TeacherNotificationDetailScreen extends StatelessWidget {
  TeacherNotificationDetailScreen({super.key}) {
    controller = Get.put(TeacherNotificationDetailController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.prepareDetails(Get.arguments);
    });
  }

  late final TeacherNotificationDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Details'),
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.notification.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null &&
            controller.notification.value == null) {
          return TeacherNotificationStatusView(
            message: controller.errorMessage.value!,
            actionLabel: 'Retry',
            onActionTap: controller.fetchNotificationDetails,
          );
        }

        final notification = controller.notification.value;
        if (notification == null) {
          return const TeacherNotificationStatusView(
            message: 'Notification not found',
          );
        }

        final isUnread = !notification.isRead;

        return RefreshIndicator(
          onRefresh: controller.fetchNotificationDetails,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // if (controller.isLoading.value) const LinearProgressIndicator(),
                // if (controller.isLoading.value) SizedBox(height: 12.h),
                // Container(
                //   width: double.infinity,
                //   padding: EdgeInsets.symmetric(
                //     horizontal: 12.w,
                //     vertical: 8.h,
                //   ),
                //   decoration: BoxDecoration(
                //     color: isUnread
                //         ? AppColors.markAllReadButtonColor.withValues(
                //             alpha: 0.12,
                //           )
                //         : Colors.grey.shade100,
                //     borderRadius: BorderRadius.circular(8.r),
                //     border: Border.all(
                //       color: isUnread
                //           ? AppColors.markAllReadButtonColor.withValues(
                //               alpha: 0.35,
                //             )
                //           : Colors.grey.shade300,
                //     ),
                //   ),
                //   child: Text(
                //     isUnread ? 'Unread notification' : 'Read notification',
                //     style: getTextStyle(
                //       fontSize: 12.sp,
                //       fontWeight: FontWeight.w600,
                //       color: isUnread
                //           ? AppColors.markAllReadButtonColor
                //           : Colors.grey.shade600,
                //     ),
                //   ),
                // ),
                // SizedBox(height: 16.h),
                // _DetailHeader(notification: notification),
                // SizedBox(height: 20.h),
                Text(
                  notification.title,
                  style: getTextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: isUnread ? Colors.black87 : Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  notification.message,
                  style: getTextStyle(
                    fontSize: 15.sp,
                    height: 1.5,
                    color: isUnread ? Colors.black87 : Colors.grey.shade700,
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
                if (NotificationNavigationHelper.hasAction(notification)) ...[
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          NotificationNavigationHelper.navigateToAction(
                            notification,
                          ),
                      child: const Text('Open Link'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }
}

// class _DetailHeader extends StatelessWidget {
//   final StudentNotificationModel notification;

//   const _DetailHeader({required this.notification});

//   @override
//   Widget build(BuildContext context) {
//     final imageUrl = notification.imageUrl?.trim();
//     final isUnread = !notification.isRead;

//     return Row(
//       children: [
//         if (imageUrl != null &&
//             imageUrl.isNotEmpty &&
//             !imageUrl.contains('example.com'))
//           CircleAvatar(radius: 28.r, backgroundImage: NetworkImage(imageUrl))
//         else
//           CircleAvatar(
//             radius: 28.r,
//             backgroundColor: isUnread
//                 ? AppColors.markAllReadButtonColor.withValues(alpha: 0.18)
//                 : Colors.grey.shade200,
//             child: Icon(
//               Icons.notifications_outlined,
//               color: isUnread
//                   ? AppColors.markAllReadButtonColor
//                   : Colors.grey.shade600,
//               size: 28.sp,
//             ),
//           ),
//         SizedBox(width: 12.w),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 notification.displayTime,
//                 style: getTextStyle(fontSize: 13.sp, color: Colors.grey),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

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

// class _ActorCard extends StatelessWidget {
//   final Map<String, dynamic> actor;

//   const _ActorCard({required this.actor});

//   @override
//   Widget build(BuildContext context) {
//     final username = actor['username']?.toString() ?? 'Unknown user';
//     final role = actor['role']?.toString() ?? '';

//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(12.w),
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             username,
//             style: getTextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
//           ),
//           if (role.isNotEmpty)
//             Text(
//               role.toUpperCase(),
//               style: getTextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
//             ),
//         ],
//       ),
//     );
//   }
// }
