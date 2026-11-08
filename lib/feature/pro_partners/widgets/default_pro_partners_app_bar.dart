import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:msollaally/core/widgets/global_app_bar.dart';

import '../../../routes/app_route.dart';
import '../../student/notification/controller/student_notification_cotroller.dart';
import '../more/profile/screen/pro_partners_profile_screen.dart';

class DefaultProPartnersAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool isHomePage;
  final String? title;
  final String? subtitle;
  final String? profileImageUrl;
  final int notificationCount;

  const DefaultProPartnersAppBar({
    super.key,
    this.isHomePage = false,
    this.title,
    this.subtitle,
    this.profileImageUrl,
    this.notificationCount = 0,
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
      subtitle: subtitle,
      profileImageUrl: profileImageUrl,
      notificationCount: notifController.unreadCount.value,
      onSearchTap: () => debugPrint('Global search tapped'),
      onNotificationTap: () => Get.toNamed(AppRoute.studentNotificationPage),
      onProfileTap: () => Get.to(ProPartnersProfileScreen()),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}
