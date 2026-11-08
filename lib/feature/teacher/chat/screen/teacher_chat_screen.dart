import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/teacher/chat/controller/teacher_chat_controller.dart';
import 'package:msollaally/feature/teacher/chat/model/teacher_chat_message_model.dart';
import 'package:msollaally/feature/teacher/chat/widget/build_image_message.dart';
import 'package:msollaally/feature/teacher/chat/widget/build_message.dart';
import 'package:msollaally/feature/teacher/chat/widget/message_input_field.dart';

class TeacherChatScreen extends StatelessWidget {
  factory TeacherChatScreen({Key? key}) {
    final controllerTag = UniqueKey().toString();
    final data = Get.arguments as Map<String, dynamic>?;
    final controller = Get.put(TeacherChatController(), tag: controllerTag);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initialize(data);
    });
    return TeacherChatScreen._(
      key: key,
      controller: controller,
      controllerTag: controllerTag,
    );
  }

  const TeacherChatScreen._({
    super.key,
    required this.controller,
    required String controllerTag,
  }) : _controllerTag = controllerTag;

  final TeacherChatController controller;
  final String _controllerTag;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _deleteController();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: false,
          title: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  child: Icon(
                    controller.isGroup.value ? Icons.group : Icons.person,
                    color: AppColors.primaryButtonColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.title,
                        style: getTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        controller.statusText,
                        style: getTextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => _showInfoSheet(context),
              icon: const Icon(Icons.info),
              color: AppColors.primaryButtonColor,
            ),
          ],
        ),
        body: Column(
          children: [
            Obx(() {
              final error = controller.errorMessage.value;
              if (error == null || error.isEmpty) {
                return const SizedBox.shrink();
              }
              return Container(
                width: double.infinity,
                color: AppColors.uiDangerColor.withValues(alpha: 0.08),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  error,
                  style: getTextStyle(
                    fontSize: 12,
                    color: AppColors.uiDangerColor,
                  ),
                ),
              );
            }),
            Expanded(child: _TeacherMessageList(controller: controller)),
            MessageInputField(
              controller: controller.messageController,
              onChanged: controller.onTypingChanged,
              onSend: () {
                if (controller.selectedImagePath.value.isNotEmpty) {
                  controller.sendImageMessage();
                  controller.selectedImagePath.value = '';
                  controller.messageController.clear();
                } else if (controller.messageController.text
                    .trim()
                    .isNotEmpty) {
                  controller.sendMessage(
                    controller.messageController.text.trim(),
                  );
                  controller.messageController.clear();
                }
              },
              onAddPressed: () async {
                await controller.pickImage();
                if (controller.selectedImagePath.value.isNotEmpty) {
                  controller.messageController.text = '[Image Selected]';
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteController() {
    if (Get.isRegistered<TeacherChatController>(tag: _controllerTag)) {
      Get.delete<TeacherChatController>(tag: _controllerTag, force: true);
    }
  }

  void _showInfoSheet(BuildContext context) {
    final isGroup = controller.isGroup.value;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.sectionBorderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primaryButtonColor.withValues(
                        alpha: 0.08,
                      ),
                      child: Icon(
                        isGroup ? Icons.group : Icons.person,
                        color: AppColors.primaryButtonColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            isGroup ? 'Group Chat' : 'Personal Chat',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  isGroup ? Icons.exit_to_app_rounded : Icons.delete_outline,
                  color: AppColors.uiDangerColor,
                ),
                title: Text(
                  isGroup ? 'Leave Group' : 'Delete Conversation',
                  style: TextStyle(
                    color: AppColors.uiDangerColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Get.back();
                  _confirmAction(context, isGroup);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmAction(BuildContext context, bool isGroup) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isGroup ? 'Leave Group?' : 'Delete Conversation?'),
        content: Text(
          isGroup
              ? 'You will no longer receive messages from this group.'
              : 'This conversation will be permanently removed.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.uiDangerColor,
            ),
            onPressed: () {
              Get.back();
              controller.leaveOrDeleteChat();
            },
            child: Text(isGroup ? 'Leave' : 'Delete'),
          ),
        ],
      ),
    );
  }
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

class _TeacherMessageList extends StatelessWidget {
  final TeacherChatController controller;

  const _TeacherMessageList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        if (controller.isLoading.value && controller.messages.isEmpty) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: ListView.builder(
              itemCount: 6,
              itemBuilder: (context, index) {
                final isMe = index % 2 == 0;
                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    width:
                        MediaQuery.of(context).size.width *
                        (0.3 + (index % 3) * 0.15),
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isMe
                            ? const Radius.circular(16)
                            : Radius.zero,
                        bottomRight: isMe
                            ? Radius.zero
                            : const Radius.circular(16),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
        if (controller.messages.isEmpty &&
            controller.errorMessage.value != null &&
            controller.errorMessage.value!.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.errorMessage.value!,
                  style: getTextStyle(fontSize: 14),
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
          return const Center(child: Text('No messages yet'));
        }

        final showTyping = controller.typingUserIds.isNotEmpty;
        final itemCount = controller.messages.length + (showTyping ? 1 : 0);

        return ListView.builder(
          controller: controller.scrollController,
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (showTyping && index == itemCount - 1) {
              return _TeacherTypingIndicatorBubble(
                typingLabel: controller.typingLabel,
                typingAnimationController: controller.typingAnimationController,
              );
            }

            final TeacherChatMessageModel msg = controller.messages[index];
            final isMe = msg.sender.id == controller.userId.value;
            final senderName = (!isMe && controller.isGroup.value)
                ? msg.sender.displayName
                : null;

            if (!msg.isRead && !isMe) {
              controller.markRead(msg.id);
            }

            if (msg.isImage || _looksLikeImageContent(msg.content)) {
              return buildTeacherImageMessage(
                isMe: isMe,
                imageUrl: msg.content,
                time: controller.formatTime(msg.createdAt),
                senderName: senderName,
                isRead: msg.isRead,
              );
            }
            return buildTeacherMessage(
              isMe: isMe,
              text: msg.content,
              time: controller.formatTime(msg.createdAt),
              senderName: senderName,
              isRead: msg.isRead,
            );
          },
        );
      }),
    );
  }
}

class _TeacherTypingIndicatorBubble extends StatelessWidget {
  final String typingLabel;
  final AnimationController typingAnimationController;

  const _TeacherTypingIndicatorBubble({
    required this.typingLabel,
    required this.typingAnimationController,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: const BoxDecoration(
          color: AppColors.panelBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              typingLabel,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondaryTextColor,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(width: 6),
            AnimatedBuilder(
              animation: typingAnimationController,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final delay = i / 3;
                  final opacity = (typingAnimationController.value - delay)
                      .clamp(0.0, 1.0);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Opacity(
                      opacity: opacity < 0.3 ? 0.3 : opacity,
                      child: const CircleAvatar(
                        radius: 3,
                        backgroundColor: AppColors.secondaryTextColor,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
