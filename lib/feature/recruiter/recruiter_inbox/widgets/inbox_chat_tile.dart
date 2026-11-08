import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/recruiter/chat/model/recruiter_chat_room_model.dart';
import 'package:msollaally/feature/recruiter/chat/screen/recruiter_chat_screen.dart';
import 'package:msollaally/feature/recruiter/recruiter_inbox/controller/chat_controller.dart';

class InboxChatTile extends StatelessWidget {
  final RecruiterChatRoomModel room;
  final InboxController controller;

  const InboxChatTile({
    super.key,
    required this.room,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final name = controller.displayName(room);
    final hasUnread = controller.hasUnread(room);

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Text(
              controller.avatarInitial(room),
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (hasUnread)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
      subtitle: Text(
        controller.lastMessage(room),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: hasUnread ? Colors.black87 : Colors.grey,
          fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (room.isGroup)
            const Padding(
              padding: EdgeInsets.only(right: 6),
              child: Icon(Icons.group, size: 16, color: Colors.grey),
            ),
          if (hasUnread)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'New',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      onTap: () =>
          Get.to(
            () => RecruiterChatScreen(),
            arguments: <String, dynamic>{
              'chatId': room.id,
              'chatName': name,
              'isGroup': room.isGroup,
            },
          )?.then((_) {
            // Refresh the chat list so unread badges reflect the latest read state
            if (Get.isRegistered<InboxController>()) {
              controller.loadChats();
            }
          }),
    );
  }
}
