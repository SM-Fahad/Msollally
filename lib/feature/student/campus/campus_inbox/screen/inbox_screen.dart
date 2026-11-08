import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/campus/campus_inbox/controller/chat_controller.dart';
import 'package:msollaally/feature/student/campus/campus_inbox/widgets/inbox_chat_tile.dart';
import 'package:msollaally/feature/student/campus/campus_inbox/widgets/inbox_filter_tabs.dart';

class InboxScreen extends GetView<InboxController> {
  final bool showAppBar;
  const InboxScreen({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<InboxController>()) {
      Get.put(InboxController());
    }

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: const Text('Inbox'),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: controller.loadChats,
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              onChanged: (val) => controller.searchQuery.value = val,
              decoration: InputDecoration(
                hintText: 'Search chats...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          InboxFilterTabs(controller: controller),
          const SizedBox(height: 10),
          Expanded(child: _InboxBody(controller: controller)),
        ],
      ),
    );
  }
}

class _InboxBody extends StatelessWidget {
  final InboxController controller;
  const _InboxBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.errorMessage.value?.isNotEmpty == true) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(
                controller.errorMessage.value!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: controller.loadChats,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        );
      }
      final chats = controller.filteredChats;
      if (chats.isEmpty) {
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'No chats yet.\nStart a conversation!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }
      return ListView.separated(
        itemCount: chats.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
        itemBuilder: (_, index) =>
            InboxChatTile(room: chats[index], controller: controller),
      );
    });
  }
}
