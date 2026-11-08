import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/const/icons_path.dart';
import 'package:msollaally/core/const/appcolors.dart';
import '../controller/student_notification_cotroller.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/student_notification_all_itean.dart';

class StudentNotificationPage extends StatelessWidget {
  const StudentNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController controller = Get.put(NotificationController());

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppBar(
              leadingIcon: SvgPicture.asset(IconsPath.arrowLeftIcon),
              onLeadingTap: () {
                Get.back();
              },
              title: 'Notification',
              actionWidget: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 6.height),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.radius),
                  border: Border.all(color: AppColors.markAllReadButtonColor),
                ),
                child: Obx(
                  () => Text(
                    controller.isMarkingAllRead.value
                        ? "Marking..."
                        : "Mark All Read",
                    style: appTextStyleHeading2(
                      fontWeight: FontWeight.w500,
                      color: AppColors.markAllReadButtonColor,
                    ),
                  ),
                ),
              ),
              onActionTap: controller.markAllRead,
            ),
            SizedBox(height: 15.height),

            Padding(
              padding: EdgeInsets.only(right: 16.width),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Obx(() {
                  return Row(
                    children: List.generate(
                      controller.notificationItem.length,
                      (index) {
                        final bool isSelected =
                            controller.selectIndex.value == index;
                        return GestureDetector(
                          onTap: () => controller.selectNotification(index),
                          child: Padding(
                            padding: EdgeInsets.only(right: 20.width),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  controller.notificationItem[index],
                                  style: appTextStyleHeading1(
                                    color: isSelected
                                        ? Colors.blue
                                        : AppColors.appBarTitleColor.withValues(alpha: .50),
                                  ),
                                ),
                                SizedBox(height: 8.height),
                                Container(
                                  height: 3.height,
                                  width: 65.width,
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.transparent,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ),

            const StudentotificationAllItem(),
          ],
        ),
      ),
    );
  }
}
