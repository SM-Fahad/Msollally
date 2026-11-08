import 'package:flutter/material.dart' show StatelessWidget, InkWell;
import 'package:flutter/widgets.dart';
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
    return ListView.builder(
      // scrollDirection: Axis.vertical,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,

      padding: EdgeInsets.zero,
      itemCount: controller.toolsList.length,
      itemBuilder: (_, index) {
        var items = controller.toolsList[index];
        return InkWell(
          onTap: items.ontap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.width, vertical: 10.height),

            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.black000000.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(8.radius),
              border: Border.all(
                color: AppColors.black000000.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                items.icon,
                SizedBox(width: 8.width),
                Text(
                  items.title,
                  style: appTextStyleHeading1(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
