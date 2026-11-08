import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/student_campus_controller.dart';

class FriendsTabs extends StatelessWidget {
  const FriendsTabs({super.key, required this.controller});

  final StudentCampusController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Row(
        children: List.generate(controller.studentFriendsTab.length, (index) {
          bool isSelected = controller.selectStudentFriendsTab.value == index;
          return GestureDetector(
            onTap: () => controller.selectStudentFriendsTab.value = index,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.width),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 4.height, horizontal: 12.width),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.aliceBlueF4F8FF
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(50.radius),
                ),
                child: Text(
                  controller.studentFriendsTab[index],
                  style: appTextStyleHeading1(
                    fontSize: 14.fontSize,
                    letterSpacing: -0.5.fontSize,
                    color: isSelected
                        ? AppColors.primaryButtonColor
                        : AppColors.appBarTitleColor,
                  ),
                ),
              ),
            ),
          );
        }),
      );
    });
  }
}
