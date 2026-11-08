import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../controller/student_more_controller.dart';

class StudentMoreSettingsAndPrivacy extends StatelessWidget {
  const StudentMoreSettingsAndPrivacy({super.key, required this.controller});

  final StudentMoreController controller;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: controller.settingAndPrivacy.length,
      itemBuilder: (_, index) {
        final items = controller.settingAndPrivacy[index];
        return InkWell(
          onTap: items.ontap,
          child: Container(
            margin: EdgeInsets.only(bottom: 10.height),
            padding: EdgeInsets.symmetric(horizontal: 6.width, vertical: 12.height),
            decoration: BoxDecoration(
              color: AppColors.black000000.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(8.radius),
            ),

            child: Row(
              children: [
                items.icon,

                SizedBox(width: 10.width),

                Text(
                  items.title,
                  style: appTextStyleHeading1(letterSpacing: 0.2.fontSize),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
