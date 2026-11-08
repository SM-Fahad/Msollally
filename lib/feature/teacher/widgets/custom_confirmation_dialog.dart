import 'package:flutter/material.dart';

import 'package:msollaally/core/common/styles/global_text_style.dart';

class CustomConfirmationDialog extends StatelessWidget {
  final bool hasTextField;
  final String title;
  final String message;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final TextEditingController? textController;

  const CustomConfirmationDialog({
    super.key,
    this.hasTextField = false,
    required this.title,
    required this.message,
    required this.onConfirm,
    required this.onCancel,
    this.textController,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          if (hasTextField)
            TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'Say Something !',
                hintStyle: getTextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
              ),
            ),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: onCancel,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                minimumSize: Size(100, 40),
              ),
              child: Text('Cancel', style: getTextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(100, 40),
              ),
              child: Text('Yes'),
            ),
          ],
        ),
      ],
    );
  }
}
