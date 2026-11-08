import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';

Widget buildTeacherMessage({
  required bool isMe,
  required String text,
  required String time,
  String? senderName,
  bool isRead = false,
}) {
  return Builder(
    builder: (context) => Align(
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
            if (!isMe && senderName != null && senderName.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  senderName.trim(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _nameColor(senderName),
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

  const _ReadTick({this.isRead = false});

  @override
  Widget build(BuildContext context) {
    final color = isRead ? Colors.white : Colors.white60;
    return Icon(isRead ? Icons.done_all : Icons.done, size: 14, color: color);
  }
}
