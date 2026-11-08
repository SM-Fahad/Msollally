import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../controller/student_more_controller.dart';

class StudentMoreHealthAndWellness extends StatelessWidget {
  const StudentMoreHealthAndWellness({super.key, required this.controller});

  final StudentMoreController controller;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: controller.healthAndWellnessList.length,
      itemBuilder: (_, index) {
        final items = controller.healthAndWellnessList[index];

        return Container(
          margin: EdgeInsets.only(bottom: 17.height),
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 16.height),
          decoration: BoxDecoration(
            color: items.bgColor,
            borderRadius: BorderRadius.circular(8.radius),

            border: Border.all(color: items.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                items.title,
                style: appTextStyleHeading1(letterSpacing: 0.2),
              ),
              SizedBox(height: 5.height),

              Text(
                items.subTitle,
                style: appTextStyleHeading2(letterSpacing: 0.2),
              ),
              SizedBox(height: 12.height),

              InkWell(
                onTap: () {
                  items.ontap();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.width,
                    vertical: 6.height,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.transparent,
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
