import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/pro_partners/chat/inbox/controller/pro_partners_inbox_controller.dart';
import 'package:msollaally/feature/pro_partners/chat/inbox/widgets/pro_partners_inbox_tile.dart';

class ProPartnersInboxScreen extends GetView<ProPartnersInboxController> {
  const ProPartnersInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<ProPartnersInboxController>()) {
      Get.delete<ProPartnersInboxController>(force: true);
    }
    Get.put(ProPartnersInboxController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadChats,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (val) => controller.searchQuery.value = val,
              decoration: InputDecoration(
                hintText: 'Search chats...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ),
          Expanded(child: _InboxBody(controller: controller)),
        ],
      ),
    );
  }
}

class _InboxBody extends StatelessWidget {
  final ProPartnersInboxController controller;
  const _InboxBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                controller.errorMessage.value!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: controller.loadChats,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      final list = controller.filteredChats;
      if (list.isEmpty) {
        return const Center(child: Text('No messages yet.'));
      }

      return RefreshIndicator(
        onRefresh: controller.loadChats,
        child: ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final room = list[index];
            return ProPartnersInboxTile(
              room: room,
              controller: controller,
            );
          },
        ),
      );
    });
  }
}
