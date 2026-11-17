import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/feature/student/more/controller/student_more_controller.dart'
    show StudentMoreController;

import '../../../../core/common/styles/global_text_style.dart';

class StudentMoreTools extends StatelessWidget {
  const StudentMoreTools({super.key, required this.controller});

  final StudentMoreController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileBg = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : AppColors.black000000.withValues(alpha: 0.04);
    final tileBorder = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : AppColors.black000000.withValues(alpha: 0.12);
    final textColor = isDark ? Colors.white : AppColors.black1F1F1F;

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: controller.toolsList.length,
      itemBuilder: (_, index) {
        var items = controller.toolsList[index];
        return InkWell(
          onTap: items.ontap,
          borderRadius: BorderRadius.circular(8.radius),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10.width,
              vertical: 10.height,
            ),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: tileBg,
              borderRadius: BorderRadius.circular(8.radius),
              border: Border.all(color: tileBorder),
            ),
            child: Row(
              children: [
                items.icon,
                SizedBox(width: 8.width),
                Text(
                  items.title,
                  style: appTextStyleHeading1(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
