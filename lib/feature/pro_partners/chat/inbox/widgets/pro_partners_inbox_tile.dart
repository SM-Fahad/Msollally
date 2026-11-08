import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/pro_partners/chat/inbox/controller/pro_partners_inbox_controller.dart';
import 'package:msollaally/feature/pro_partners/chat/model/pro_partners_chat_room_model.dart';
import 'package:msollaally/feature/pro_partners/chat/screen/pro_partners_chat_screen.dart';

class ProPartnersInboxTile extends StatelessWidget {
  final ProPartnersChatRoomModel room;
  final ProPartnersInboxController controller;

  const ProPartnersInboxTile({
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
            backgroundColor: const Color(0xFFE8F5E9),
            child: Text(
              controller.avatarInitial(room),
              style: const TextStyle(
                color: Color(0xFF2E7D32),
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
          color: hasUnread ? Colors.black87 : Colors.grey.shade600,
        ),
      ),
      trailing: hasUnread
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'New',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      onTap: () {
        Get.to(
          () => ProPartnersChatScreen(),
          arguments: {
            'chatId': room.id,
            'name': name,
            'isGroup': room.isGroup,
            'receiverIds': room.participants
                .where((p) => p.user.id != controller.currentUserId.value)
                .map((p) => p.user.id)
                .toList(),
          },
        )?.then((_) => controller.loadChats());
      },
    );
  }
}
