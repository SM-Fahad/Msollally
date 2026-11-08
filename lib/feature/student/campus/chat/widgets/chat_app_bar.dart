import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/student/campus/chat/controller/student_campus_chat_controller.dart';
import 'package:msollaally/routes/app_route.dart';

class CampusChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final StudentCampusChatController controller;

  const CampusChatAppBar({super.key, required this.controller});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      centerTitle: false,
      title: Obx(
        () => InkWell(
          onTap: () {
            if (!controller.isGroup.value && controller.otherUserId > 0) {
              Get.toNamed(
                AppRoute.studentCampusPublicProfile,
                arguments: controller.otherUserId,
              );
            } else if (controller.isGroup.value) {
              _showInfoSheet(context);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.lavenderE8F0FE,
                child: Icon(
                  controller.isGroup.value ? Icons.group : Icons.person,
                  color: Colors.blue,
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
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      controller.statusText,
                      style: getTextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _showInfoSheet(context),
          icon: const Icon(Icons.info_outline, color: Colors.blue),
        ),
      ],
    );
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
                  color: Colors.grey[300],
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
                      backgroundColor: AppColors.lavenderE8F0FE,
                      child: Icon(
                        isGroup ? Icons.group : Icons.person,
                        color: Colors.blue,
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
                              color: Colors.grey,
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
                  color: Colors.red,
                ),
                title: Text(
                  isGroup ? 'Leave Group' : 'Delete Conversation',
                  style: const TextStyle(
                    color: Colors.red,
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Get.back(); // close dialog
              controller.leaveOrDeleteChat();
            },
            child: Text(isGroup ? 'Leave' : 'Delete'),
          ),
        ],
      ),
    );
  }
}
