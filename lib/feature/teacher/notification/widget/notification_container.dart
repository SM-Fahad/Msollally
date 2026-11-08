import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/const/icons_path.dart';
import 'package:msollaally/feature/student/notification/model/student_notification_model.dart';

class NotificationContainer extends StatelessWidget {
  final StudentNotificationModel notification;
  final VoidCallback? onTap;
  final Future<bool> Function()? onDelete;
  final Future<bool> Function()? onArchive;

  const NotificationContainer({
    super.key,
    required this.notification,
    this.onTap,
    this.onDelete,
    this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final content = _NotificationCard(notification: notification, onTap: onTap);

    if (onDelete == null && onArchive == null) {
      return content;
    }

    return Dismissible(
      key: ValueKey('notification_${notification.id}'),
      direction: DismissDirection.horizontal,
      background: _SwipeActionBackground(
        alignment: Alignment.centerLeft,
        color: Colors.orange.shade600,
        icon: Icons.archive_outlined,
        label: 'Archive',
      ),
      secondaryBackground: _SwipeActionBackground(
        alignment: Alignment.centerRight,
        color: AppColors.uiDangerColor,
        icon: Icons.delete_outline,
        label: 'Delete',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return onDelete?.call() ?? false;
        }
        if (direction == DismissDirection.startToEnd) {
          return onArchive?.call() ?? false;
        }
        return false;
      },
      child: content,
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final StudentNotificationModel notification;
  final VoidCallback? onTap;

  const _NotificationCard({required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isUnread
              ? AppColors.markAllReadButtonColor.withValues(alpha: 0.10)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isUnread
                ? AppColors.markAllReadButtonColor.withValues(alpha: 0.45)
                : Colors.grey.shade300,
            width: isUnread ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isUnread)
              Container(
                width: 4.w,
                height: 48.h,
                margin: EdgeInsets.only(right: 12.w),
                decoration: BoxDecoration(
                  color: AppColors.markAllReadButtonColor,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            // _NotificationLeading(notification: notification),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: getTextStyle(
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                      fontSize: 16.sp,
                      color: isUnread ? Colors.black : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    notification.message,
                    style: getTextStyle(
                      fontSize: 14.sp,
                      color: isUnread
                          ? Colors.black
                          : Colors.black.withValues(alpha: .8),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.displayTime,
                          style: getTextStyle(
                            fontSize: 12.sp,
                            color: Colors.black.withValues(alpha: .7),
                          ),
                        ),
                      ),
                      Text(
                        notification.category.toUpperCase(),
                        style: getTextStyle(
                          fontSize: 11.sp,
                          color: AppColors.markAllReadButtonColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeActionBackground extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;

  const _SwipeActionBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.r),
      ),
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerLeft) ...[
            Icon(icon, color: Colors.white, size: 22.sp),
            SizedBox(width: 8.w),
            Text(
              label,
              style: getTextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ] else ...[
            Text(
              label,
              style: getTextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(icon, color: Colors.white, size: 22.sp),
          ],
        ],
      ),
    );
  }
}

// class _NotificationLeading extends StatelessWidget {
//   final StudentNotificationModel notification;

//   const _NotificationLeading({required this.notification});

//   @override
//   Widget build(BuildContext context) {
//     final imageUrl = notification.imageUrl?.trim();
//     if (imageUrl != null && imageUrl.isNotEmpty && !imageUrl.contains('example.com')) {
//       return CircleAvatar(
//         radius: 24.r,
//         backgroundImage: NetworkImage(imageUrl),
//       );
//     }

//     final isUnread = !notification.isRead;

//     return CircleAvatar(
//       radius: 24.r,
//       backgroundColor: isUnread
//           ? AppColors.markAllReadButtonColor.withValues(alpha: 0.18)
//           : Colors.grey.shade200,
//       child: Icon(
//         _iconForType(notification.type),
//         size: 24.sp,
//         color: isUnread
//             ? AppColors.markAllReadButtonColor
//             : Colors.grey.shade600,
//       ),
//     );
//   }

//   IconData _iconForType(String type) {
//     switch (type) {
//       case 'grade_update':
//         return Icons.grade_outlined;
//       case 'StudentAddRequest':
//         return Icons.person_add_alt_1_outlined;
//       default:
//         return Icons.notifications_outlined;
//     }
//   }
// }

class TeacherNotificationStatusView extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const TeacherNotificationStatusView({
    super.key,
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
