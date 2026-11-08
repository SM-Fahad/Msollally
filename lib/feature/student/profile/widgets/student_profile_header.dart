import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import '../controller/student_profile_controller.dart';

class StudentProfileHeader extends StatelessWidget {
  final StudentProfileController controller;

  const StudentProfileHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => Text(
            controller.displayName.value.isNotEmpty
                ? controller.displayName.value
                : controller.aboutItem.isNotEmpty
                ? controller.aboutItem[0].titleValue
                : '',
            style: appTextStyleHeading1(
              fontSize: 20.fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 10.height),
        Obx(
          () => Row(
            children: [
              Text(
                '${controller.friendsCount.value}',
                style: appTextStyleHeading1(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0.fontSize,
                ),
              ),
              Text(
                ' Friends',
                style: appTextStyleHeading2(letterSpacing: 0.0.fontSize),
              ),
            ],
          ),
        ),
        Obx(
          () => controller.bioText.value.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.only(top: 4.height),
                  child: Text(
                    controller.bioText.value,
                    style: appTextStyleHeading2(letterSpacing: 0.fontSize),
                  ),
                )
              : SizedBox.shrink(),
        ),
      ],
    );
  }
}
