// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/student/ai_chat/controller/student_ai_chat_controller.dart';
import 'package:msollaally/feature/student/ai_chat/widgets/custom_text_field_button_student_ai_chat.dart';
import 'package:msollaally/feature/student/notification/widgets/custom_app_bar.dart';

import '../../../../core/const/icons_path.dart';
import 'package:msollaally/core/const/appcolors.dart';
import '../widgets/student_ai_chat_auto_visible_text.dart';
import '../widgets/student_ai_chat_click_visivle_text.dart';

class StudentAIChatPage extends StatelessWidget {
  const StudentAIChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _controller = Get.put(StudentAIChatController());
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Container(
          color: AppColors.aiChatBGColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar(
                leadingIcon: SvgPicture.asset(
                  IconsPath.arrowLeftIcon,
                  height: 24.height,
                  width: 24.width,
                ),
                onLeadingTap: () {
                  Get.back();
                },
                title: "AI Chat",
                actionWidget: SizedBox(
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Get.dialog(
                            AlertDialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.radius),
                              ),
                              title: Text(
                                'New Chat',
                                style: TextStyle(
                                  fontSize: 18.fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryTextColor,
                                ),
                              ),
                              content: Text(
                                'Are you sure you want to open a new chat?',
                                style: TextStyle(
                                  fontSize: 14.fontSize,
                                  color: AppColors.secondaryTextColor,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: Text(
                                    'No',
                                    style: TextStyle(
                                      color: AppColors.secondaryTextColor,
                                      fontSize: 14.fontSize,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Get.back();
                                    _controller.resetChat();
                                  },
                                  child: Text(
                                    'Yes',
                                    style: TextStyle(
                                      color: AppColors.primaryButtonColor,
                                      fontSize: 14.fontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: SvgPicture.asset(
                          IconsPath.addButtonIcon,
                          height: 28.height,
                          width: 28.width,
                        ),
                      ),
                      // Removed unused history menu button
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8.height),
              Expanded(
                child: Obx(
                  () =>
                      _controller.showFirst.value &&
                          _controller.messages.isEmpty
                      ? StudentAIChatAutoVIsibleText()
                      : StudentChatAIClickVisibleText(),
                ),
              ),
              Obx(
                () => _controller.isLoading.value
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.width,
                          vertical: 8.height,
                        ),
                        child: Text(
                          "AI is thinking...",
                          style: appTextStyleHeading2(
                            fontSize: 12.fontSize,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.width,
                  vertical: 52.height,
                ),
                child: Column(
                  children: [
                    Obx(
                      () => _controller.selectedFiles.isNotEmpty
                          ? Wrap(
                              children: _controller.selectedFiles
                                  .map(
                                    (file) => Chip(
                                      label: Text(
                                        file.path.split('/').last,
                                        style: TextStyle(fontSize: 10.fontSize),
                                      ),
                                      onDeleted: () => _controller.selectedFiles
                                          .remove(file),
                                    ),
                                  )
                                  .toList(),
                            )
                          : SizedBox.shrink(),
                    ),
                    CustomTextFieldButtonStudentAiChat(
                      onTap: _controller.clickToTextFieldToChangeMsg,
                      onSubmitted: (_) => _controller.sendMessage(),
                      hintText: 'Type here',
                      controller:
                          _controller.studentAiChatTextFieldButtonController,
                      prefix: InkWell(
                        onTap: () => _controller.pickFiles(),
                        child: Image.asset(
                          IconsPath.plusIcon,
                          height: 24.height,
                          width: 24.width,
                        ),
                      ),
                      suffix: InkWell(
                        onTap: () {
                          _controller.sendMessage();
                          // TODO: mic — commented for now
                          // if (_controller
                          //         .studentAiChatTextFieldButtonController
                          //         .text
                          //         .isNotEmpty ||
                          //     _controller.selectedFiles.isNotEmpty) {
                          //   _controller.sendMessage();
                          // } else {
                          //   _controller.pickAudio();
                          // }
                        },
                        child: Icon(
                          Icons.send_rounded,
                          color: AppColors.blueViolet7C4DFF,
                          size: 24.height,
                        ),
                        // TODO: mic toggle — commented for now
                        // child: Obx(
                        //   () =>
                        //       _controller
                        //               .studentAiChatTextFieldButtonController
                        //               .text
                        //               .isNotEmpty ||
                        //           _controller.selectedFiles.isNotEmpty
                        //       ? Icon(
                        //           Icons.send,
                        //           color: AppColors.aiChatBGColor,
                        //           size: 24.height,
                        //         )
                        //       : SvgPicture.asset(
                        //           IconsPath.voiceButtonIcon,
                        //           height: 44.height,
                        //           width: 44.width,
                        //         ),
                        // ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
