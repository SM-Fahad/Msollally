import 'dart:io';
import 'package:msollaally/core/const/appcolors.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/widgets/fullscreen_image_view.dart';

class ChatTextBubble extends StatelessWidget {
  final bool isMe;
  final String text;
  final String time;
  final String? senderName;
  final bool isRead;

  const ChatTextBubble({
    super.key,
    required this.isMe,
    required this.text,
    required this.time,
    this.senderName,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isMe && senderName != null && senderName!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  senderName!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _nameColor(senderName!),
                  ),
                ),
              ),
            Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: isMe ? Colors.white70 : Colors.black54,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  _ReadTick(isRead: isRead),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _nameColor(String name) {
    const colors = [
      AppColors.royalBlue1565C0,
      AppColors.forestGreen2E7D32,
      AppColors.purple6A1B9A,
      AppColors.orangeRedE65100,
      AppColors.darkCyan00838F,
      AppColors.firebrickC62828,
      AppColors.darkSlateBlue4527A0,
      AppColors.teal00695C,
    ];
    return colors[name.hashCode.abs() % colors.length];
  }
}

class ChatImageBubble extends StatelessWidget {
  final bool isMe;
  final String imageUrl;
  final String time;
  final String? senderName;
  final bool isRead;

  const ChatImageBubble({
    super.key,
    required this.isMe,
    required this.imageUrl,
    required this.time,
    this.senderName,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    final imageUri = Uri.tryParse(imageUrl);
    final isRemoteImage =
        imageUri != null &&
        (imageUri.scheme == 'http' || imageUri.scheme == 'https');

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isMe && senderName != null && senderName!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Text(
                  senderName!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
            GestureDetector(
              onTap: () {
                Get.to(
                  () => FullscreenImageView(
                    imageUrl: imageUrl,
                    isNetworkImage: isRemoteImage,
                    isFileImage: !isRemoteImage,
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: isRemoteImage
                    ? Image.network(
                        imageUrl,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildBrokenImage(),
                      )
                    : Image.file(
                        File(imageUrl),
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildBrokenImage(),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  _ReadTick(isRead: isRead, darkBg: false),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildBrokenImage() {
  return const SizedBox(
    width: 200,
    height: 200,
    child: Center(child: Icon(Icons.broken_image)),
  );
}

/// ✓ (sent, grey) or ✓✓ (read, blue double tick)
class _ReadTick extends StatelessWidget {
  final bool isRead;
  final bool darkBg; // true = white ticks (inside blue bubble)

  const _ReadTick({this.isRead = false, this.darkBg = true});

  @override
  Widget build(BuildContext context) {
    final color = isRead
        ? (darkBg ? Colors.white : Colors.blue)
        : (darkBg ? Colors.white60 : Colors.grey);
    return Icon(isRead ? Icons.done_all : Icons.done, size: 14, color: color);
  }
}

/// Typing animation shown in the message list
class TypingIndicatorBubble extends StatelessWidget {
  final String typingLabel;

  const TypingIndicatorBubble({super.key, required this.typingLabel});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: const BorderRadius.only(
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
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(width: 8),
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
