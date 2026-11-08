import 'package:flutter/material.dart';

class CampusChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAddPressed;
  final ValueChanged<String>? onChanged;

  final int minLines;
  final int maxLines;

  const CampusChatInputField({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onAddPressed,
    this.onChanged,
    this.minLines = 1,
    this.maxLines = 5,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add_circle_outline, color: Colors.grey),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                minLines: minLines,
                maxLines: maxLines,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: 'Write your message...',
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.blue,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: onSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
