import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/chat/controller/chat_controller.dart';
import 'package:msollaally/core/chat/screen/widgets/chat_app_bar.dart';
import 'package:msollaally/core/chat/screen/widgets/chat_error_banner.dart';
import 'package:msollaally/core/chat/screen/widgets/chat_input_bar.dart';
import 'package:msollaally/core/chat/screen/widgets/chat_message_list.dart';
import 'package:msollaally/core/chat/screen/widgets/chat_typing_indicator.dart';

class ChatScreen extends GetView<ChatController> {
  final String chatName;
  final String? chatAvatar;

  const ChatScreen({super.key, required this.chatName, this.chatAvatar});

  @override
  String? get tag => chatName;

  @override
  Widget build(BuildContext context) {
    Get.put<ChatController>(ChatController(), tag: chatName, permanent: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initialize(Get.arguments as Map<String, dynamic>?);
    });

    final TextEditingController textCtrl = TextEditingController();
    final ScrollController scrollCtrl = ScrollController();

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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ChatAppBar(chatName: chatName, chatAvatar: chatAvatar),
      body: Column(
        children: [
          Obx(() {
            final err = controller.errorMessage.value;
            if (err == null || err.isEmpty) return const SizedBox.shrink();
            return ChatErrorBanner(message: err);
          }),

          ChatMessageList(controller: controller, scrollController: scrollCtrl),

          Obx(() {
            if (controller.typingUserIds.isEmpty) {
              return const SizedBox.shrink();
            }
            return const ChatTypingIndicator();
          }),

          ChatInputBar(
            textController: textCtrl,
            onChanged: controller.onTextChanged,
            onSend: () {
              final text = textCtrl.text.trim();
              if (text.isEmpty) return;
              controller.sendMessage(text);
              textCtrl.clear();
            },
          ),
        ],
      ),
    );
  }
}
