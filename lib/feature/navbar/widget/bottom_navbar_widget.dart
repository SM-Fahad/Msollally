import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controller/navbar_controller.dart';
import '../model/navbar_item.dart';

class BottomNavbarWidget extends StatelessWidget {
  final NavbarController controller;

  const BottomNavbarWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.85 * 255).round()),
        border: Border(
          top: BorderSide(
            width: 1,
            color: Colors.black.withAlpha((0.12 * 255).round()),
          ),
        ),
      ),
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      child: SafeArea(
        top: false,
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: controller.navbarItems
                .asMap()
                .entries
                .map(
                  (entry) =>
                      _buildNavbarItem(controller, entry.key, entry.value),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavbarItem(
    NavbarController controller,
    int index,
    NavbarItem item,
  ) {
    return Expanded(
      child: Obx(() {
        final isSelected = index == controller.currentIndex;
        final itemColor = isSelected
            ? AppColors.primaryButtonColor
            : AppColors.appBarTitleColor;

        bool displayNotification = item.hasNotification;
        String? displayCount = item.notificationCount;

        // Campus button no longer shows notification count here.

        return GestureDetector(
          onTap: () => controller.changeTab(index),
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            height: 52,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  isSelected ? item.activeIcon : item.inactiveIcon,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(itemColor, BlendMode.srcIn),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    item.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: getTextStyle(
                      color: itemColor,
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
