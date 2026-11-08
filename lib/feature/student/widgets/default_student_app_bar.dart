import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/widgets/global_app_bar.dart';
import 'package:msollaally/feature/student/campus/chat/service/chat_badge_service.dart';
import 'package:msollaally/feature/student/profile/controller/student_profile_controller.dart';
import 'package:msollaally/feature/student/notification/controller/student_notification_cotroller.dart';
import 'package:msollaally/routes/app_route.dart';

class DefaultStudentAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool isHomePage;
  final String? title;

  const DefaultStudentAppBar({super.key, this.isHomePage = false, this.title});

  @override
  Widget build(BuildContext context) {
    // Ensure StudentProfileController is initialized
    final StudentProfileController controller =
        Get.isRegistered<StudentProfileController>()
        ? Get.find<StudentProfileController>()
        : Get.put(StudentProfileController());

    final NotificationController notifController =
        Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController());

    final String nameToShow;
    if (controller.displayName.value.isNotEmpty) {
      final cleanedName = controller.displayName.value.replaceAll(
        RegExp(r'[^\w\s]'),
        '',
      );
      final parts = cleanedName.trim().split(RegExp(r'\s+'));
      nameToShow = parts.isNotEmpty ? parts.first : 'Student';
    } else {
      nameToShow = 'Student';
    }

    return Obx(
      () => GlobalAppBar(
        isHomePage: isHomePage,
        title: isHomePage ? 'Welcome back' : title,
        subtitle: isHomePage ? nameToShow : null,
        profileImageUrl: controller.profileImageUrl.value,
        notificationCount: notifController.unreadCount.value,
        messageCount: ChatBadgeService.unreadCount.value,
        onSearchTap: () => Get.toNamed(AppRoute.studentGlobalSearch),
        onMessageTap: isHomePage ? () => Get.toNamed(AppRoute.studentCampusInbox) : null,
        onNotificationTap: () => Get.toNamed(AppRoute.studentNotificationPage),
        onProfileTap: () => Get.toNamed(AppRoute.studentProfilePage),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(72);
}
