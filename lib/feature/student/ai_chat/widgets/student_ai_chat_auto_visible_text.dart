import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart'
    show appTextStyleHeading2, appTextStyleHeading1;
import 'package:msollaally/feature/student/ai_chat/controller/student_ai_chat_controller.dart';

import '../../../../core/const/icons_path.dart';
import 'package:msollaally/core/const/appcolors.dart';

class StudentAIChatAutoVIsibleText extends StatelessWidget {
  const StudentAIChatAutoVIsibleText({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentAIChatController>();
    return SizedBox(
      child: Padding(
        padding: EdgeInsets.only(left: 20.width, right: 20.width),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Text(
                  "Hi ${controller.userName.value},\nhow can I help you today?",
                  style: appTextStyleHeading1(
                    fontWeight: FontWeight.w600,
                    fontSize: 18.fontSize,
                    letterSpacing: 0.fontSize,
                  ),
                )),
            SizedBox(height: 24.height),
            InkWell(
              onTap: () {
                controller.studentAiChatTextFieldButtonController.text =
                    "Find what’s in my today’s tasks";
                controller.sendMessage();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 10.height),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.fileConverterUploadFileBorderColor,
                  ),
                  borderRadius: BorderRadius.circular(24.radius),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      IconsPath.fireIcon,
                      height: 16.height,
                      width: 12.55,
                    ),
                    SizedBox(width: 6.width),
                    Text(
                      "Find what’s in my today’s tasks",
                      style: appTextStyleHeading2(
                        letterSpacing: 0.fontSize,
                        color: AppColors.darkGray999999,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.height),
            InkWell(
              onTap: () {
                controller.studentAiChatTextFieldButtonController.text =
                    "Create a plan for upcoming Exam";
                controller.sendMessage();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 10.height),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.radius),
                  border: Border.all(
                    color: AppColors.fileConverterUploadFileBorderColor,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(IconsPath.rocketIcon),
                    SizedBox(width: 6.width),
                    Text(
                      "Create a plan for upcoming Exam",
                      style: appTextStyleHeading2(
                        letterSpacing: 0.fontSize,
                        color: AppColors.darkGray999999,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
