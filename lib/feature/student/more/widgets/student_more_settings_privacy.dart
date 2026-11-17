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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileBg = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : AppColors.black000000.withValues(alpha: 0.04);
    final tileBorder = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.transparent;
    final fgColor = isDark ? Colors.white : AppColors.black1F1F1F;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: controller.settingAndPrivacy.length,
      itemBuilder: (_, index) {
        final items = controller.settingAndPrivacy[index];
        return InkWell(
          onTap: items.ontap,
          borderRadius: BorderRadius.circular(8.radius),
          child: Container(
            margin: EdgeInsets.only(bottom: 10.height),
            padding: EdgeInsets.symmetric(
              horizontal: 10.width,
              vertical: 12.height,
            ),
            decoration: BoxDecoration(
              color: tileBg,
              borderRadius: BorderRadius.circular(8.radius),
              border: isDark ? Border.all(color: tileBorder) : null,
            ),
            child: Row(
              children: [
                IconTheme(
                  data: IconThemeData(color: fgColor, size: 24),
                  child: items.icon,
                ),
                SizedBox(width: 10.width),
                Text(
                  items.title,
                  style: appTextStyleHeading1(
                    letterSpacing: 0.2.fontSize,
                    color: fgColor,
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
