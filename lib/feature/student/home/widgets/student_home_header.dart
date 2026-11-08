import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';

import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/const/icons_path.dart';
import 'package:msollaally/feature/student/campus/chat/service/chat_badge_service.dart';
import 'package:msollaally/feature/student/notification/controller/student_notification_cotroller.dart';
import 'package:msollaally/feature/student/profile/controller/student_profile_controller.dart';
import 'package:msollaally/routes/app_route.dart';

class StudentHomeHeader extends StatelessWidget {
  const StudentHomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = Get.isRegistered<StudentProfileController>()
        ? Get.find<StudentProfileController>()
        : Get.put(StudentProfileController());
    final notifications = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController());

    return Obx(
      () => Row(
        children: [
          InkWell(
            onTap: () => Get.toNamed(AppRoute.studentProfilePage),
            borderRadius: BorderRadius.circular(24.radius),
            child: _Avatar(url: profile.profileImageUrl.value),
          ),
          SizedBox(width: 12.width),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: getTextStyle(
                    fontSize: 13,
                    color: AppColors.black111111,
                  ),
                ),
                SizedBox(height: 2.height),
                Text(
                  _displayName(profile.displayName.value),
                  style: getTextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black111111,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Get.toNamed(AppRoute.studentGlobalSearch),
            icon: Icon(Icons.search_rounded, size: 24.fontSize),
            color: AppColors.black0F172A,
          ),
          InkWell(
            onTap: () => Get.toNamed(AppRoute.studentCampusInbox),
            borderRadius: BorderRadius.circular(22.radius),
            child: SizedBox(
              width: 38.width,
              height: 38.height,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  SvgPicture.asset(
                    IconsPath.messageIcon,
                    height: 24.height,
                    width: 24.width,
                    colorFilter: const ColorFilter.mode(
                      AppColors.black0F172A,
                      BlendMode.srcIn,
                    ),
                  ),
                  Obx(() {
                    final messageCount = ChatBadgeService.unreadCount.value;
                    if (messageCount > 0) {
                      return Positioned(
                        right: 2.width,
                        top: 2.height,
                        child: _Badge(count: messageCount),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ),
          SizedBox(width: 4.width),
          InkWell(
            onTap: () => Get.toNamed(AppRoute.studentNotificationPage),
            borderRadius: BorderRadius.circular(22.radius),
            child: SizedBox(
              width: 38.width,
              height: 38.height,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  ImageIcon(
                    const AssetImage(IconsPath.mainNotificationIcon),
                    size: 24.fontSize,
                    color: AppColors.black0F172A,
                  ),
                  if (notifications.unreadCount.value > 0)
                    Positioned(
                      right: 2.width,
                      top: 2.height,
                      child: _Badge(count: notifications.unreadCount.value),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _displayName(String name) {
    final cleaned = name.replaceAll(RegExp(r'[^\w\s]'), '').trim();
    return cleaned.isEmpty ? '....' : cleaned;
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning!';
    } else if (hour < 17) {
      return 'Good Afternoon!';
    } else if (hour < 21) {
      return 'Good Evening!';
    } else {
      return 'Good Night!';
    }
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: url.isEmpty
          ? Image.asset(IconsPath.profileIIcon, height: 46.height, width: 46.width)
          : Image.network(
              url,
              height: 46.height,
              width: 46.width,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Image.asset(
                IconsPath.profileIIcon,
                height: 46.height,
                width: 46.width,
              ),
            ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 16.width, minHeight: 16.height),
      decoration: const BoxDecoration(
        color: AppColors.uiDangerColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : '$count',
          style: getTextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
