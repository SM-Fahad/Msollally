import 'package:msollaally/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class ChatTypingIndicator extends StatelessWidget {
  const ChatTypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.width, vertical: 6.height),
      child: Row(
        children: [
          SizedBox(
            width: 14.width,
            height: 14.width,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.grey,
            ),
          ),
          SizedBox(width: 8.width),
          Text(
            'Typing…',
            style: getTextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
