import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/routes/app_route.dart';
import '../../notification/widgets/custom_app_bar.dart';

class TaskDetailsHeader extends StatelessWidget {
  final dynamic items;

  const TaskDetailsHeader({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      leadingIcon: Icon(Icons.arrow_back, size: 24),
      onLeadingTap: () => Get.back(),
      title: "Task Details",
      actionWidget: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 6.height),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.radius),
          color: AppColors.buttonTextColorGoogleAppleOnboarding,
        ),
        child: InkWell(
          onTap: () {
            Get.toNamed(
              AppRoute.studentEditTask,
              arguments: {
                'taskId': items.id,
                'task': items.title,
                'note': items.note,
                'dateTime': items.rawDateTime,
              },
            );
          },
          child: Text(
            "Edit",
            style: appTextStyleHeading2(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
