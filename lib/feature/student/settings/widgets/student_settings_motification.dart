import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../controller/student_settings_controller.dart';

class StudentSettingsNotification extends StatelessWidget {
  const StudentSettingsNotification({super.key, required this.controller});

  final StudentSettingsController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 12.height),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.radius),
                topRight: Radius.circular(8.radius),
              ),
            ),
            child: Text(
              "Notifications",
              style: appTextStyleHeading1(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2.fontSize,
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(
              //  horizontal: 12.width,
              vertical: 12.height,
            ),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey.shade300),
                right: BorderSide(color: Colors.grey.shade300),
                bottom: BorderSide(color: Colors.grey.shade300),
              ),

              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.radius),
                bottomRight: Radius.circular(8.radius),
              ),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: controller.notificationTypeList.length,

              itemBuilder: (_, index) {
                var items = controller.notificationTypeList[index];

                return Padding(
                  padding: EdgeInsets.only(bottom: 24.height),
                  child: SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Checkbox(
                            value: items.isTapped.value,
                            onChanged: (val) {
                              items.isTapped.value = val ?? false;
                            },
                          ),
                        ),
                        // SizedBox(width: 8.width),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              items.title,
                              style: appTextStyleHeading2(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2.fontSize,
                                color: AppColors.black18181B,
                              ),
                            ),
                            SizedBox(height: 4.height),

                            Text(
                              items.subTitle,
                              style: appTextStyleHeading2(
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2.fontSize,
                                color: AppColors.tertiaryTextColor,
                                fontSize: 12.fontSize,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
