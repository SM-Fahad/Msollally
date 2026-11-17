import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../controller/student_more_controller.dart';

class StudentMoreHealthAndWellness extends StatelessWidget {
  const StudentMoreHealthAndWellness({super.key, required this.controller});

  final StudentMoreController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: controller.healthAndWellnessList.length,
      itemBuilder: (_, index) {
        final items = controller.healthAndWellnessList[index];
        final cardBg = isDark
            ? items.borderColor.withValues(alpha: 0.14)
            : items.bgColor;
        final titleColor = isDark
            ? Colors.white
            : const Color(0xFF1F1F1F);
        final subTitleColor = isDark
            ? Colors.white70
            : const Color(0xCC3F3F3F);

        return Container(
          margin: EdgeInsets.only(bottom: 17.height),
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 16.width,
            vertical: 16.height,
          ),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(8.radius),
            border: Border.all(
              color: isDark
                  ? items.borderColor.withValues(alpha: 0.65)
                  : items.borderColor,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                items.title,
                style: appTextStyleHeading1(
                  letterSpacing: 0.2,
                  color: titleColor,
                ),
              ),
              SizedBox(height: 5.height),

              Text(
                items.subTitle,
                style: appTextStyleHeading2(
                  letterSpacing: 0.2,
                  color: subTitleColor,
                ),
              ),
              SizedBox(height: 12.height),

              InkWell(
                onTap: () {
                  items.ontap();
                },
                borderRadius: BorderRadius.circular(8.radius),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.width,
                    vertical: 6.height,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? items.borderColor.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.radius),
                    border: Border.all(color: items.borderColor),
                  ),
                  child: Text(
                    items.buttonText,
                    style: appTextStyleHeading2(
                      color: items.borderColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
