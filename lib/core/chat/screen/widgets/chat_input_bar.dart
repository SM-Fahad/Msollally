import 'package:msollaally/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController textController;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;

  const ChatInputBar({
    super.key,
    required this.textController,
    required this.onChanged,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 8.height),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(
                Icons.add_circle_outline,
                color: AppColors.primaryButtonColor,
                size: 26.fontSize,
              ),
              onPressed: () {},
            ),
            Expanded(
              child: Container(
                constraints: BoxConstraints(maxHeight: 120.height),
                decoration: BoxDecoration(
                  color: AppColors.whiteSmokeF2F3F5,
                  borderRadius: BorderRadius.circular(24.radius),
                ),
                child: TextField(
                  controller: textController,
                  onChanged: onChanged,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  style: getTextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Write a message…',
                    hintStyle: getTextStyle(fontSize: 14, color: Colors.grey),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.width,
                      vertical: 10.height,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.width),
            GestureDetector(
              onTap: onSend,
              child: Container(
                width: 44.width,
                height: 44.width,
                decoration: BoxDecoration(
                  color: AppColors.primaryButtonColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20.fontSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
