import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/campus/campus_inbox/controller/chat_controller.dart';

class InboxFilterTabs extends StatelessWidget {
  final InboxController controller;

  const InboxFilterTabs({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Tab(
            label: 'All',
            isSelected: controller.selectedTab.value == 'All',
            onTap: () => controller.selectedTab.value = 'All',
          ),
          const SizedBox(width: 8),
          _Tab(
            label: 'Groups',
            isSelected: controller.selectedTab.value == 'Courses',
            onTap: () => controller.selectedTab.value = 'Courses',
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(color: isSelected ? Colors.white : Colors.black),
      ),
      selected: isSelected,
      selectedColor: Colors.blue,
      backgroundColor: Colors.white,
      onSelected: (_) => onTap(),
    );
  }
}
