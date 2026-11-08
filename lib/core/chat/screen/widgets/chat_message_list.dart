import 'package:msollaally/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/chat/controller/chat_controller.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/common/widgets/shimmer_loading.dart';
import 'package:msollaally/core/chat/screen/widgets/chat_message_tile.dart';

class ChatMessageList extends StatelessWidget {
  final ChatController controller;
  final ScrollController scrollController;

  const ChatMessageList({
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
            padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 12.height),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: ShimmerLoading.card(
                    height: 50.height,
                    width: 200.width,
                    borderRadius: 12.radius,
                  ),
                ),
                SizedBox(height: 12.height),
                Align(
                  alignment: Alignment.centerRight,
                  child: ShimmerLoading.card(
                    height: 60.height,
                    width: 220.width,
                    borderRadius: 12.radius,
                  ),
                ),
                SizedBox(height: 12.height),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ShimmerLoading.card(
                    height: 40.height,
                    width: 140.width,
                    borderRadius: 12.radius,
                  ),
                ),
                SizedBox(height: 12.height),
                Align(
                  alignment: Alignment.centerRight,
                  child: ShimmerLoading.card(
                    height: 70.height,
                    width: 250.width,
                    borderRadius: 12.radius,
                  ),
                ),
                SizedBox(height: 12.height),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ShimmerLoading.card(
                    height: 55.height,
                    width: 180.width,
                    borderRadius: 12.radius,
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.messages.isEmpty) {
          return Center(
            child: Text(
              'No messages yet.\nSay hello! 👋',
              textAlign: TextAlign.center,
              style: getTextStyle(fontSize: 14, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          controller: scrollController,
          padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 12.height),
          itemCount: controller.messages.length,
          itemBuilder: (context, index) {
            final msg = controller.messages[index];
            final isMe = msg.sender.id == controller.currentUserId.value;

            if (!isMe && !msg.isRead && msg.id > 0) {
              controller.markRead(msg.id);
            }

            return ChatMessageTile(
              message: msg,
              isMe: isMe,
              formattedTime: controller.formatTime(msg.createdAt),
            );
          },
        );
      }),
    );
  }
}
