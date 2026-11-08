import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/chat/model/chat_message_model.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/common/widgets/fullscreen_image_view.dart';
import 'package:msollaally/core/const/appcolors.dart';

class ChatMessageTile extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;
  final String formattedTime;

  const ChatMessageTile({
    super.key,
    required this.message,
    required this.isMe,
    required this.formattedTime,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        constraints: BoxConstraints(maxWidth: 0.72.sw),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: EdgeInsets.only(left: 4.w, bottom: 2.h),
                child: Text(
                  message.sender.name,
                  style: getTextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            _buildBubble(context),
            Padding(
              padding: EdgeInsets.only(top: 2.h, left: 4.w, right: 4.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formattedTime,
                    style: getTextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  if (isMe) ...[
                    SizedBox(width: 4.w),
                    _DeliveryIcon(status: message.status),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(BuildContext context) {
    final bgColor = isMe
        ? AppColors.primaryButtonColor
        : AppColors.whiteSmokeF2F3F5;
    final textColor = isMe ? Colors.white : Colors.black87;

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isMe ? 18 : 4),
      bottomRight: Radius.circular(isMe ? 4 : 18),
    );

    if (message.isImage) {
      final isRemote =
          message.content.startsWith('http://') ||
          message.content.startsWith('https://');
      return GestureDetector(
        onTap: () {
          Get.to(
            () => FullscreenImageView(
              imageUrl: message.content,
              isNetworkImage: isRemote,
              isFileImage: !isRemote,
            ),
          );
        },
        child: ClipRRect(
          borderRadius: radius,
          child: isRemote
              ? Image.network(
                  message.content,
                  width: 200.w,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 200.w,
                    height: 140.h,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                )
              : Image.file(
                  File(message.content),
                  width: 200.w,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 200.w,
                    height: 140.h,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
        ),
      );
    }

    return Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: message.hasFailed
                ? AppColors.uiDangerColor.withValues(alpha: 0.12)
                : bgColor,
            borderRadius: radius,
          ),
          child: Text(
            message.content,
            style: getTextStyle(
              fontSize: 14,
              color: message.hasFailed ? AppColors.uiDangerColor : textColor,
            ),
          ),
        ),
        if (message.isSending)
          Positioned(
            right: 6.w,
            bottom: 6.h,
            child: SizedBox(
              width: 10.w,
              height: 10.h,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: isMe ? Colors.white.withValues(alpha: 0.7) : Colors.grey,
              ),
            ),
          ),
      ],
    );
  }
}

class _DeliveryIcon extends StatelessWidget {
  final ChatMessageStatus status;

  const _DeliveryIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ChatMessageStatus.sending:
        return SizedBox(
          width: 10.w,
          height: 10.h,
          child: CircularProgressIndicator(
            strokeWidth: 1,
            color: Colors.grey.shade400,
          ),
        );
      case ChatMessageStatus.sent:
        return Icon(Icons.done, size: 14.sp, color: Colors.grey);
      case ChatMessageStatus.read:
        return Icon(
          Icons.done_all,
          size: 14.sp,
          color: AppColors.primaryButtonColor,
        );
      case ChatMessageStatus.failed:
        return Icon(
          Icons.error_outline,
          size: 14.sp,
          color: AppColors.uiDangerColor,
        );
    }
  }
}
