import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/widgets/global_app_bar.dart';
import 'package:msollaally/feature/teacher/notification/controller/teacher_notification_controller.dart';
import 'package:msollaally/feature/teacher/profile/controller/teacher_profile_controller.dart';
import 'package:msollaally/routes/app_route.dart';

class DefaultTeacherAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool isHomePage;
  final String? title;

  const DefaultTeacherAppBar({super.key, this.isHomePage = false, this.title});

  @override
  Widget build(BuildContext context) {
    final TeacherProfileController controller =
        Get.isRegistered<TeacherProfileController>()
        ? Get.find<TeacherProfileController>()
        : Get.put(TeacherProfileController());

    final TeacherNotificationController notifController =
        Get.isRegistered<TeacherNotificationController>()
        ? Get.find<TeacherNotificationController>()
        : Get.put(TeacherNotificationController());

    return Obx(
      () => GlobalAppBar(
        isHomePage: isHomePage,
        title: title,
        subtitle: isHomePage ? controller.displayName : null,
        onSearchTap: () => debugPrint('Global search tapped'),
        onNotificationTap: () async {
          await Get.toNamed(AppRoute.teacherNotificationScreen);
          notifController.fetchUnreadCount();
        },
        onProfileTap: () => Get.toNamed(AppRoute.teacherProfileScreen),
        profileImageUrl: controller.profileImageUrl,
        notificationCount: notifController.unreadCount.value,
        backgroundColor: Colors.white,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(72);
}
