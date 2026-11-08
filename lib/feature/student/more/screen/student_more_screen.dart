import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';
import 'package:msollaally/feature/student/more/controller/student_more_controller.dart';
import 'package:msollaally/feature/student/more/widgets/student_extraadd_tools.dart';
import 'package:msollaally/feature/student/notification/widgets/custom_app_bar.dart';
import 'package:msollaally/routes/app_route.dart';

import '../widgets/student_more_health_wellness.dart';
import '../widgets/student_more_settings_privacy.dart';
import '../widgets/student_more_tools.dart';

class StudentMoreScreen extends StatelessWidget {
  StudentMoreScreen({super.key});
  final controller = Get.put(StudentMoreController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsGeometry.only(top: 38.height),

              child: CustomAppBar(
                leadingIcon: SizedBox.shrink(),
                onLeadingTap: () {
                  Get.back();
                },
                title: "More",
              ),
            ),

            Padding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: 20.width,
                vertical: 16.height,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 11.width,
                      vertical: 20.height,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryButtonColor.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(12.radius),

                      border: Border.all(
                        color: AppColors.primaryButtonColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Go Premium", style: appTextStyleHeading1()),
                        SizedBox(height: 10.height),

                        Text(
                          "job from top recruiters,Premium resume templates AI-powered resume optimization , Highlighted profile for recruiters ,AI-powered resume optimization",
                          style: appTextStyleHeading2(color: AppColors.appBarTitleColor),
                        ),
                        SizedBox(height: 31.height),
                        CustomButton(
                          vertical: 6.height,
                          text: "Upgrade",
                          onPressed: () {
                            Get.toNamed(AppRoute.studentupgrade);
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.height),

                  Obx(
                    () => Column(
                      children: [
                        for (
                          int i = 0;
                          i < controller.extraList.length;
                          i++
                        ) ...[
                          MoreToolsItem(
                            model: controller.extraList[i],
                            color: i == 0
                                ? AppColors.coralFF9244.withValues(alpha: 0.2)
                                : null,
                          ),
                          if (i != controller.extraList.length - 1)
                            SizedBox(height: 24.height),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 24.height),
                  Text("Tools", style: appTextStyleHeading2(fontSize: 16.fontSize)),
                  SizedBox(height: 16.height),

                  StudentMoreTools(controller: controller),
                  SizedBox(height: 10.height),
                  Text(
                    "Health & Wellness",
                    style: appTextStyleHeading2(fontSize: 16.fontSize),
                  ),
                  SizedBox(height: 16.height),

                  StudentMoreHealthAndWellness(controller: controller),
                  SizedBox(height: 12.height),
                  Text(
                    "Settings & Privacy",
                    style: appTextStyleHeading2(fontSize: 16),
                  ),
                  SizedBox(height: 16.height),

                  StudentMoreSettingsAndPrivacy(controller: controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
