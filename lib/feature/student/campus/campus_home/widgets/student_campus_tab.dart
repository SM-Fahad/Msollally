import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';

import '../controller/student_campus_controller.dart';

class StudentCampusTab extends StatelessWidget {
  const StudentCampusTab({
    super.key,
    required StudentCampusController controller,
  }) : _controller = controller;

  final StudentCampusController _controller;

  IconData _getTabIcon(int index, String tabTitle) {
    switch (tabTitle.toLowerCase()) {
      case 'wall':
        return Icons.dynamic_feed_rounded;
      case 'union':
        return Icons.diversity_3_rounded;
      case 'students':
        return Icons.people_alt_rounded;
      case 'campaign':
        return Icons.campaign_rounded;
      case 'events':
        return Icons.event_available_rounded;
      case 'campus inbox':
      case 'inbox':
        return Icons.chat_bubble_outline_rounded;
      default:
        return Icons.tab_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.textfieldBorderColor, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 8.height),
        child: Obx(() {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(_controller.tabs.length, (index) {
              final isSelected = _controller.selectedTab.value == index;
              final title = _controller.tabs[index];
              final icon = _getTabIcon(index, title);

              return CampusTabItem(
                title: title,
                icon: icon,
                isActive: isSelected,
                onTap: () => _controller.selectedTab.value = index,
              );
            }),
          );
        }),
      ),
    );
  }
}

class CampusTabItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const CampusTabItem({
    super.key,
    required this.title,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(right: 8.width),
        padding: EdgeInsets.symmetric(horizontal: 14.width, vertical: 8.height),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryButtonColor.withValues(alpha: 0.12)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10.radius),
          border: Border.all(
            color: isActive
                ? AppColors.primaryButtonColor.withValues(alpha: 0.4)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive
                  ? AppColors.primaryButtonColor
                  : Colors.grey.shade600,
            ),
            SizedBox(width: 6.width),
            Text(
              title,
              style: getTextStyle(
                fontSize: 13,
                height: 1.2,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? AppColors.primaryButtonColor
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
