import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/widgets/global_app_bar.dart';
import 'package:msollaally/feature/recruiter/more/profile/screen/recruiter_profile_screen.dart';
import 'package:msollaally/feature/student/notification/controller/student_notification_cotroller.dart';
import 'package:msollaally/routes/app_route.dart';

class DefaultRecruiterAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool isHomePage;
  final String? title;
  final String? profileImageUrl;

  const DefaultRecruiterAppBar({
    super.key,
    this.isHomePage = false,
    this.title,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final NotificationController notifController =
        Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController());
    return GlobalAppBar(
      isHomePage: isHomePage,
      title: title,
      profileImageUrl: profileImageUrl,
      onSearchTap: () => debugPrint('Global search tapped'),
      onNotificationTap: () => Get.toNamed(AppRoute.recruiterNotificationScreen),
      onProfileTap: () => Get.to(RecruiterProfileScreen()),
      notificationCount: notifController.unreadCount.value,
      backgroundColor: Colors.white,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(72);
}
