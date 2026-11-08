import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/student/campus/union/create_union/controller/create_union_controller.dart';

class UnionSettingsSwitches extends StatelessWidget {
  const UnionSettingsSwitches({super.key, required this.controller});

  final CreateUnionController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => SwitchListTile(
            title: Text(
              'Public Union',
              style: appTextStyleHeading2(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Anyone can find and see content',
              style: TextStyle(fontSize: 12.fontSize),
            ),
            value: controller.isPublic.value,
            onChanged: (value) => controller.isPublic.value = value,
            activeThumbColor: AppColors.primaryButtonColor,
          ),
        ),
        Obx(
          () => SwitchListTile(
            title: Text(
              'Allow Join Requests',
              style: appTextStyleHeading2(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Users can request to join',
              style: TextStyle(fontSize: 12.fontSize),
            ),
            value: controller.allowJoinRequests.value,
            onChanged: (value) => controller.allowJoinRequests.value = value,
            activeThumbColor: AppColors.primaryButtonColor,
          ),
        ),
      ],
    );
  }
}
