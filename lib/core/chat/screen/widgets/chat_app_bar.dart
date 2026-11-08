import 'package:msollaally/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/chat/controller/chat_controller.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String chatName;
  final String? chatAvatar;

  const ChatAppBar({super.key, required this.chatName, this.chatAvatar});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leadingWidth: 40.width,
      title: Obx(
        () => Row(
          children: [
            _Avatar(url: chatAvatar),
            SizedBox(width: 10.width),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chatName,
                    style: getTextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    Get.isRegistered<ChatController>(tag: chatName)
                        ? Get.find<ChatController>(tag: chatName).statusText
                        : 'Connecting…',
                    style: getTextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call_outlined),
          color: AppColors.primaryButtonColor,
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.videocam_outlined),
          color: AppColors.primaryButtonColor,
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.info_outline),
          color: Colors.grey,
          onPressed: () {},
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;

  const _Avatar({this.url});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 18.radius,
      backgroundColor: AppColors.primaryButtonColor.withValues(alpha: 0.15),
      backgroundImage: (url != null && url!.isNotEmpty)
          ? NetworkImage(url!)
          : null,
      child: (url == null || url!.isEmpty)
          ? Icon(Icons.person, color: AppColors.primaryButtonColor, size: 20.radius)
          : null,
    );
  }
}
