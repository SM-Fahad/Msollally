import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:msollaally/routes/app_route.dart';
import 'package:msollaally/feature/student/notification/controller/student_notification_cotroller.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/const/icons_path.dart' show IconsPath;
import 'package:msollaally/core/const/appcolors.dart';

class AppBarHomePage extends StatelessWidget {
  const AppBarHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController notifController =
        Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController());

    return Container(
      height: 76.height,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.studentAppBarBorderColor),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.width),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    IconsPath.nodmacIconNext,
                    height: 40.height,
                    width: 47.63.width,
                  ),
                  SizedBox(width: 5.width),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Good Morning!", style: appTextStyleHeading2()),
                      Text("Jenny Wilson", style: appTextStyleHeading1()),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              child: Row(
                children: [
                  SvgPicture.asset(
                    IconsPath.searchIcon,
                    height: 24.height,
                    width: 24.width,
                  ),
                  SizedBox(width: 8.width),
                  InkWell(
                    onTap: () => Get.toNamed(AppRoute.studentNotificationPage),
                    // ignore: unused_label
                    child: Obx(
                      () => Stack(
                        clipBehavior: Clip.none,
                        children: [
                          SvgPicture.asset(
                            IconsPath.notificationIcon,
                            height: 24.height,
                            width: 24.width,
                          ),
                          if (notifController.unreadCount.value > 0)
                            Positioned(
                              right: -6.width,
                              top: -10.height,
                              child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: AppColors.uiDangerColor,
                                  shape: BoxShape.circle,
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 20.width,
                                  minHeight: 20.height,
                                ),
                                child: Center(
                                  child: Text(
                                    notifController.unreadCount.value > 99
                                        ? '99+'
                                        : notifController.unreadCount.value
                                              .toString(),
                                    style: appTextStyleHeading1(
                                      color: AppColors.buttonColorOnboarding,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(width: 8.width),
                  InkWell(
                    onTap: () {
                      Get.toNamed(AppRoute.studentProfilePage);
                    },

                    child: ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(80.radius),
                      child: Image.asset(
                        IconsPath.profileIIcon,
                        height: 40.height,
                        width: 40.width,
                      ),
                    ),
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
