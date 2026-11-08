import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/icons_path.dart';
import 'package:msollaally/feature/student/campus/chat/service/chat_badge_service.dart';
import 'package:msollaally/feature/student/campus/campus_inbox/screen/inbox_screen.dart';
import '../controller/student_profile_controller.dart';

class StudentProfileTabs extends StatelessWidget {
  final StudentProfileController controller;

  const StudentProfileTabs({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 16.width),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => Row(
                children: List.generate(controller.tabs.length, (index) {
                  final isSelected = controller.selectedTab.value == index;
                  return GestureDetector(
                    onTap: () => controller.selectedTab.value = index,
                    child: Padding(
                      padding: EdgeInsets.only(right: 36.width),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.tabs[index],
                            style: appTextStyleHeading1(
                              color: isSelected
                                  ? Colors.blue
                                  : AppColors.appBarTitleColor.withValues(alpha: .50),
                            ),
                          ),
                          SizedBox(height: 8.height),
                          Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.transparent,
                            ),
                            height: 3.height,
                            width: 65.width,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            InkWell(
              onTap: () => Get.to(() => const InboxScreen()),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  SvgPicture.asset(
                    IconsPath.messageIcon,
                    height: 28.height,
                    width: 28.width,
                  ),
                  Obx(() {
                    final count = ChatBadgeService.unreadCount.value;
                    if (count == 0) return const SizedBox.shrink();
                    return Positioned(
                      right: -15.width,
                      bottom: 20,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.width,
                          vertical: 2.height,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.radius),
                          color: AppColors.uiDangerColor,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 20.width,
                          minHeight: 15.height,
                        ),
                        child: Center(
                          child: Text(
                            count > 99 ? '99+' : '$count',
                            style: appTextStyleHeading1(
                              fontWeight: FontWeight.w400,
                              fontSize: 10.fontSize,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
