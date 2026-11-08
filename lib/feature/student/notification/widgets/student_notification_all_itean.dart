import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/const/icons_path.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/routes/app_route.dart';
import '../controller/student_notification_cotroller.dart';
import '../model/student_notification_model.dart';
import '../service/student_notification_service.dart';

class StudentotificationAllItem extends StatelessWidget {
  const StudentotificationAllItem({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController studentNotificationController = Get.find();

    return Expanded(
      child: Obx(() {
        if (studentNotificationController.isLoading.value &&
            studentNotificationController.notificationAll.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (studentNotificationController.errorMessage.value != null &&
            studentNotificationController.notificationAll.isEmpty) {
          return _NotificationStatusView(
            message: studentNotificationController.errorMessage.value!,
            actionLabel: 'Retry',
            onActionTap: studentNotificationController.fetchNotifications,
          );
        }

        if (studentNotificationController.notificationAll.isEmpty) {
          return RefreshIndicator(
            onRefresh: studentNotificationController.refreshNotifications,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 180),
                _NotificationStatusView(message: 'No notifications found'),
              ],
            ),
          );
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 160) {
              studentNotificationController.loadMoreNotifications();
            }
            return false;
          },
          child: RefreshIndicator(
            onRefresh: studentNotificationController.refreshNotifications,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount:
                  studentNotificationController.notificationAll.length +
                  (studentNotificationController.isLoadingMore.value ? 1 : 0),
              itemBuilder: (_, index) {
                if (index >=
                    studentNotificationController.notificationAll.length) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.height),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                final StudentNotificationModel item =
                    studentNotificationController.notificationAll[index];

                return _NotificationCard(
                  item: item,
                  onTap: () {
                    Get.toNamed(
                      AppRoute.studentNotificationDetailPage,
                      arguments: item,
                    );
                  },
                  onDelete: () async {
                    try {
                      await StudentNotificationService.deleteNotification(item.id);
                      studentNotificationController.notificationAll.removeAt(index);
                      return true;
                    } catch (e) {
                      Get.snackbar('Error', 'Failed to delete notification',
                          snackPosition: SnackPosition.BOTTOM);
                      return false;
                    }
                  },
                  onArchive: () async {
                    try {
                      await StudentNotificationService.archiveNotification(item.id);
                      studentNotificationController.notificationAll.removeAt(index);
                      return true;
                    } catch (e) {
                      Get.snackbar('Error', 'Failed to archive notification',
                          snackPosition: SnackPosition.BOTTOM);
                      return false;
                    }
                  },
                );
              },
            ),
          ),
        );
      }),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final StudentNotificationModel item;
  final VoidCallback? onTap;
  final Future<bool> Function()? onDelete;
  final Future<bool> Function()? onArchive;

  const _NotificationCard({
    required this.item,
    this.onTap,
    this.onDelete,
    this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = item.isRead
        ? Colors.transparent
        : AppColors.checkBoxActiveColor.withValues(alpha: 0.12);

    final content = GestureDetector(
      onTap: onTap,
      child: Container(
      padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 12.height),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(
            color: AppColors.black000000.withValues(alpha: 0.08),
          ),
          bottom: BorderSide(
            color: AppColors.black000000.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NotificationImage(imageUrl: item.imageUrl),
          SizedBox(width: 12.width),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: appTextStyleHeading1(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2.fontSize,
                  ),
                ),
                SizedBox(height: 4.height),
                Text(
                  item.message,
                  style: appTextStyleHeading2(
                    fontSize: 12.fontSize,
                    letterSpacing: 0.2.fontSize,
                  ),
                ),
                if (item.senderName != null && item.senderName!.isNotEmpty) ...[
                  SizedBox(height: 4.height),
                  Text(
                    'From: ${item.senderName}',
                    style: appTextStyleHeading2(
                      fontSize: 11.fontSize,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryButtonColor,
                    ),
                  ),
                ],
                SizedBox(height: 8.height),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.displayTime,
                        style: appTextStyleHeading2(fontSize: 10.fontSize),
                      ),
                    ),
                    Text(
                      item.category.toUpperCase(),
                      style: appTextStyleHeading2(
                        fontSize: 10.fontSize,
                        color: AppColors.markAllReadButtonColor,
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

    if (onDelete == null && onArchive == null) {
      return content;
    }

    return Dismissible(
      key: ValueKey('notification_${item.id}'),
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

class _NotificationImage extends StatelessWidget {
  final String? imageUrl;

  const _NotificationImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final String? trimmedUrl = imageUrl?.trim();
    if (trimmedUrl != null && trimmedUrl.isNotEmpty && !trimmedUrl.contains('example.com')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.radius),
        child: Image.network(
          trimmedUrl,
          height: 42.height,
          width: 42.width,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallback(),
        ),
      );
    }

    return _buildFallback();
  }

  Widget _buildFallback() {
    return Image.asset(IconsPath.communityIcon, height: 42.height, width: 42.width);
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
      margin: EdgeInsets.symmetric(vertical: 12.height, horizontal: 12.width),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.radius),
      ),
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: 24.width),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerLeft) ...[Icon(icon, color: Colors.white, size: 22.fontSize),
            SizedBox(width: 8.width),
            Text(
              label,
              style: appTextStyleHeading2(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14.fontSize,
              ),
            ),
          ] else ...[Text(
            label,
            style: appTextStyleHeading2(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14.fontSize,
            ),
          ),
            SizedBox(width: 8.width),
            Icon(icon, color: Colors.white, size: 22.fontSize),
          ],
        ],
      ),
    );
  }
}

class _NotificationStatusView extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const _NotificationStatusView({
    required this.message,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.width),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: appTextStyleHeading2(
                fontSize: 13.fontSize,
                color: AppColors.appBarTitleColor.withValues(alpha: .70),
              ),
            ),
            if (actionLabel != null && onActionTap != null) ...[
              SizedBox(height: 12.height),
              TextButton(
                onPressed: onActionTap,
                child: Text(
                  actionLabel!,
                  style: appTextStyleHeading2(
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
