import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/campus/chat/controller/student_campus_chat_controller.dart';
import 'package:msollaally/feature/student/campus/chat/widgets/campus_chat_error_banner.dart';
import 'package:msollaally/feature/student/campus/chat/widgets/campus_chat_message_list.dart';
import 'package:msollaally/feature/student/campus/chat/widgets/chat_app_bar.dart';
import 'package:msollaally/feature/student/campus/chat/widgets/chat_input_field.dart';

class CampusChatScreen extends StatelessWidget {
  final String controllerTag;

  CampusChatScreen({super.key}) : controllerTag = UniqueKey().toString();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StudentCampusChatController>(
      tag: controllerTag,
      init: StudentCampusChatController(),
      dispose: (_) {
        if (Get.isRegistered<StudentCampusChatController>(tag: controllerTag)) {
          Get.delete<StudentCampusChatController>(
            tag: controllerTag,
            force: true,
          );
        }
      },
      initState: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final data = Get.arguments as Map<String, dynamic>?;
          if (Get.isRegistered<StudentCampusChatController>(
            tag: controllerTag,
          )) {
            Get.find<StudentCampusChatController>(
              tag: controllerTag,
            ).initialize(data);
          }
        });
      },
      builder: (controller) {
        final ScrollController scrollCtrl = ScrollController();

        // Auto-scroll logic for new messages
        ever(controller.messages, (_) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (scrollCtrl.hasClients) {
              scrollCtrl.animateTo(
                scrollCtrl.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        });

        // Auto-scroll logic when someone starts typing
        ever(controller.typingUserIds, (_) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (scrollCtrl.hasClients) {
              scrollCtrl.animateTo(
                scrollCtrl.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        });

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: CampusChatAppBar(controller: controller),
          body: Column(
            children: [
              CampusChatErrorBanner(controller: controller),
              CampusChatMessageList(
                controller: controller,
                scrollController: scrollCtrl,
              ),
              CampusChatInputField(
                controller: controller.textController,
                onChanged: controller.onTypingChanged,
                onSend: controller.sendText,
                onAddPressed: () async {
                  await controller.pickImage();
                  if (controller.selectedImagePath.value.isNotEmpty) {
                    controller.textController.text = '[Image Selected]';
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
