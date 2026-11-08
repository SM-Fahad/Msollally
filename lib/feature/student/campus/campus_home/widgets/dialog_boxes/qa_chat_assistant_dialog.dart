import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'controller/dialogbox_controller.dart';
import 'package:get/get.dart';

class QAChatAssistantDialog extends StatelessWidget {
  const QAChatAssistantDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DialogboxController>();

    Future.delayed(Duration.zero, () {
      Future.delayed(const Duration(seconds: 20), () {
        final engagement = ChatEngagementData(
          messagesSent: controller.chatMessageCount.value,
          engagementTimeSeconds: 20,
          messages: controller.chatMessages.toList(),
          qualifiesForPoints: controller.chatMessageCount.value >= 3,
        );
        controller.setChatEngagement(engagement);
      });
    });

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.only(
          top: 16,
          right: 12,
          bottom: 12,
          left: 12,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildProgressIndicator(controller),
              const SizedBox(height: 16),
              _buildChatThread(),
              const SizedBox(height: 16),
              _buildQuickActions(),
              const SizedBox(height: 16),
              _buildInputSection(controller),
              const SizedBox(height: 16),
              _buildContactCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Q&A Chat Assistant",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                "Ask questions and engage with our AI assistant to earn points",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.close, color: Colors.grey, size: 20),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(DialogboxController controller) {
    return Obx(
      () => Row(
        children: [
          const Icon(Icons.circle, color: Colors.orange, size: 10),
          const SizedBox(width: 8),
          Text(
            "${controller.chatMessageCount.value}/3 messages • 9s",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatThread() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.dodgerBlue155DFC,
              child: Icon(
                Icons.smart_toy_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello! I'm your AI assistant for CRDB Bank products. I can answer questions about our loan products...",
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "08:20 AM",
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.blueViolet9810FA,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "What are the loan amounts available?",
                      style: TextStyle(fontSize: 13, color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "08:20 AM",
                      style: TextStyle(fontSize: 10, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.blueViolet9810FA,
              child: Icon(Icons.person_outline, color: Colors.white, size: 18),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ["Loan Amounts", "Interest Rates", "Documents"].map((text) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              child: Text(
                text,
                style: const TextStyle(color: Colors.black87, fontSize: 12),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInputSection(DialogboxController controller) {
    final messageController = TextEditingController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: messageController,
                  onSubmitted: (text) {
                    if (text.isNotEmpty) {
                      controller.addChatMessage(text);
                      controller.incrementChatMessageCount();
                      messageController.clear();
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: "Ask about loan products...",
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                onPressed: () {
                  final text = messageController.text;
                  if (text.isNotEmpty) {
                    controller.addChatMessage(text);
                    controller.incrementChatMessageCount();
                    messageController.clear();
                  }
                },
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          "Engage for at least 20s and send 3 messages to earn points",
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildContactCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.aliceBlueEDF5FF,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lavenderD0E2FF),
      ),
      child: Column(
        children: [
          const Text(
            "Need to speak with a representative?",
            style: TextStyle(fontSize: 12, color: Colors.blueGrey),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.open_in_new, size: 16),
                SizedBox(width: 8),
                Text(
                  "Contact CRDB Bank",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
