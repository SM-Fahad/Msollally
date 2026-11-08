import 'dart:io';
import 'package:msollaally/core/const/appcolors.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/widgets/fullscreen_image_view.dart';

Widget buildTeacherImageMessage({
  required bool isMe,
  required String imageUrl,
  required String time,
  String? senderName,
  bool isRead = false,
}) {
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
          if (!isMe && senderName != null && senderName.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(
                senderName.trim(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _nameColor(senderName),
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
                      errorBuilder: (_, __, ___) => _buildImageFallback(),
                    )
                  : Image.file(
                      File(imageUrl),
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildImageFallback(),
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

Widget _buildImageFallback() {
  return Container(
    width: 200,
    height: 200,
    color: Colors.black12,
    alignment: Alignment.center,
    child: const Icon(
      Icons.broken_image_outlined,
      color: Colors.black45,
      size: 36,
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

class _ReadTick extends StatelessWidget {
  final bool isRead;
  final bool darkBg;

  const _ReadTick({this.isRead = false, this.darkBg = true});

  @override
  Widget build(BuildContext context) {
    final color = isRead
        ? (darkBg ? Colors.white : Colors.blue)
        : (darkBg ? Colors.white60 : Colors.grey);
    return Icon(isRead ? Icons.done_all : Icons.done, size: 14, color: color);
  }
}
