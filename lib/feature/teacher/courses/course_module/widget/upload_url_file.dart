import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class UploadUrlField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onUpload;

  const UploadUrlField({
    super.key,
    required this.controller,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.07),
        border: Border.all(color: Colors.blueGrey[50]!, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Add file URL",
                hintStyle: getTextStyle(color: Colors.grey),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onUpload,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: Text("Upload"),
          ),
        ],
      ),
    );
  }
}
