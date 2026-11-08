import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/pro_partners/chat/controller/pro_partners_chat_controller.dart';

class CampusChatErrorBanner extends StatelessWidget {
  final ProPartnersChatController controller;

  const CampusChatErrorBanner({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final msg = controller.errorMessage.value;
      if (msg == null || msg.isEmpty) return const SizedBox.shrink();
      return Container(
        width: double.infinity,
        color: Colors.red.withValues(alpha: 0.08),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
            TextButton(onPressed: controller.retry, child: const Text('Retry')),
          ],
        ),
      );
    });
  }
}
