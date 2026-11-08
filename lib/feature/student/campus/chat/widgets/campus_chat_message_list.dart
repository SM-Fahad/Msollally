import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/campus/chat/controller/student_campus_chat_controller.dart';
import 'package:msollaally/feature/student/campus/chat/model/student_chat_message_model.dart';
import 'package:msollaally/core/common/widgets/shimmer_loading.dart';
import 'package:msollaally/feature/student/campus/chat/widgets/chat_message_bubble.dart';

class CampusChatMessageList extends StatelessWidget {
  final StudentCampusChatController controller;
  final ScrollController scrollController;

  const CampusChatMessageList({
    super.key,
    required this.controller,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        if (controller.isLoading.value && controller.messages.isEmpty) {
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: ShimmerLoading.card(
                    height: 50,
                    width: 200,
                    borderRadius: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ShimmerLoading.card(
                    height: 60,
                    width: 220,
                    borderRadius: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ShimmerLoading.card(
                    height: 40,
                    width: 140,
                    borderRadius: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ShimmerLoading.card(
                    height: 70,
                    width: 250,
                    borderRadius: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ShimmerLoading.card(
                    height: 55,
                    width: 180,
                    borderRadius: 12,
                  ),
                ),
              ],
            ),
          );
        }
        if (controller.messages.isEmpty &&
            controller.errorMessage.value?.isNotEmpty == true) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.errorMessage.value!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: controller.retry,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (controller.messages.isEmpty) {
          return const Center(
            child: Text(
              'No messages yet.\nSay hello! 👋',
              textAlign: TextAlign.center,
            ),
          );
        }

        final typingIds = controller.typingUserIds;
        final showTyping = typingIds.isNotEmpty;
        final count = controller.messages.length + (showTyping ? 1 : 0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            controller: scrollController,
            itemCount: count,
            itemBuilder: (_, index) {
              if (showTyping && index == count - 1) {
                return _buildTypingBubble();
              }
              return _buildItem(controller.messages[index]);
            },
          ),
        );
      }),
    );
  }

  Widget _buildTypingBubble() {
    return TypingIndicatorBubble(typingLabel: controller.typingLabel);
  }

  Widget _buildItem(StudentChatMessageModel msg) {
    final isMe = msg.sender.id == controller.userId.value;
    if (!msg.isRead && !isMe) controller.markRead(msg.id);
    final time = controller.formatTime(msg.createdAt);
    final senderName = (!isMe && controller.isGroup.value)
        ? msg.sender.username
        : null;
    if (msg.isImage || _looksLikeImageContent(msg.content)) {
      return ChatImageBubble(
        isMe: isMe,
        imageUrl: msg.content,
        time: time,
        senderName: senderName,
        isRead: msg.isRead,
      );
    }
    return ChatTextBubble(
      isMe: isMe,
      text: msg.content,
      time: time,
      senderName: senderName,
      isRead: msg.isRead,
    );
  }

  bool _looksLikeImageContent(String content) {
    final text = content.trim().toLowerCase();
    return text.endsWith('.png') ||
        text.endsWith('.jpg') ||
        text.endsWith('.jpeg') ||
        text.endsWith('.gif') ||
        text.endsWith('.webp') ||
        text.startsWith('/data/') ||
        text.startsWith('/storage/') ||
        text.startsWith('file://');
  }
}
