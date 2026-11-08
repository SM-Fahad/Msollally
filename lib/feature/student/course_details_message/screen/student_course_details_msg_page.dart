import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/const/images_path.dart';
import 'package:msollaally/feature/student/ai_chat/widgets/custom_text_field_button_student_ai_chat.dart';
import 'package:msollaally/feature/student/course_details_message/controller/student_course_details_msg_controller.dart';
import 'package:msollaally/feature/student/course_details_message/widgets/student_course_details_msg.dart';
import 'package:msollaally/feature/student/notification/widgets/custom_app_bar.dart';

import '../../../../core/const/icons_path.dart' show IconsPath;
import 'package:msollaally/core/const/appcolors.dart';

class StudentCourseDetailsMsg extends StatelessWidget {
  const StudentCourseDetailsMsg({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(StudentCourseDetailsMsgController());

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 38.height),
            child: CustomAppBar(
              leadingIcon: Icon(Icons.arrow_back, size: 24.height),
              onLeadingTap: () {
                Get.back();
              },
              title: "Physics Basics",
              // 🔥 Added multiple actions (voice & video call icons)
              actionWidget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.call, size: 24, color: Colors.black87),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.videocam, size: 24, color: Colors.black87),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      size: 24,
                      color: Colors.black87,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              onActionTap: () {
                // keep empty since we use multiple icons
              },
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.width, vertical: 20.height),
            child: Obx(
              () => SizedBox(
                height: 612.height,
                child: ListView(
                  controller: controller.scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    buildMessage(
                      isMe: false,
                      text:
                          "Have you seen the latest holographic display technology?",
                      time: "12.12 AM",
                      name: 'Prof. Alex Hales',
                      imageUrl: "",
                      active: true,
                    ),
                    buildMessage(
                      isMe: true,
                      text:
                          "Have you seen the latest holographic display technology?",
                      time: "12.12 AM",
                      imageUrl: "",
                    ),
                    buildMessage(
                      isMe: false,
                      text:
                          "Have you seen the latest holographic display technology?",
                      time: "12.12 AM",
                      name: 'Prof. Alex Hales',
                      imageUrl: ImagesPath.onboarding1,
                      active: true,
                    ),
                    for (var msg in controller.message)
                      buildMessage(
                        isMe: true,
                        text: msg,
                        time: "Now",
                        imageUrl: "",
                      ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(left: 20.width, right: 20.width),
            child: CustomTextFieldButtonStudentAiChat(
              gradient: LinearGradient(
                colors: [AppColors.lightGrayCBD5E1, AppColors.lightGrayCBD5E1],
              ),
              hintText: 'Write your message...',
              hintextColor: AppColors.darkSlateGray475569,
              controller: controller.textController,
              prefix: InkWell(
                onTap: () {},
                child: Image.asset(
                  IconsPath.plusIcon,
                  height: 24.height,
                  width: 24.width,
                  color: AppColors.darkGray94A3B8,
                ),
              ),
              suffix: SizedBox(
                width: 60.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {},
                      child: Image.asset(
                        IconsPath.voiceIcon,
                        height: 32.height,
                        width: 32.width,
                      ),
                    ),
                    SizedBox(width: 4.width),
                    InkWell(
                      onTap: () {
                        controller.sendMessage(controller.textController.text);
                        controller.textController.clear();
                      },
                      child: Icon(
                        Icons.send,
                        size: 24,
                        color: AppColors.buttonTextColorGoogleAppleOnboarding,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
