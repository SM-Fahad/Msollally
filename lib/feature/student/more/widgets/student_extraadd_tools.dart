import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/student/more/model/student_more_tools_model.dart';

class MoreToolsItem extends StatelessWidget {
  final StudentMoreToolsModel model;
  final Color? color;

  const MoreToolsItem({super.key, required this.model, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: model.ontap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 45,
        width: double.infinity,
        decoration: BoxDecoration(
          color: color ?? AppColors.black000000.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.sliderColorInboarding, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: model.icon,
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Text(
                model.title,
                style: appTextStyleHeading1(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
