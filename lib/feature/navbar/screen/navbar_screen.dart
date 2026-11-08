import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controller/navbar_controller.dart';
import '../model/navbar_item.dart';

class NavbarScreen extends StatelessWidget {
  final UserProfile userProfile;
  final Widget? body;

  const NavbarScreen({super.key, required this.userProfile, this.body});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller with the user profile
    final controller = Get.put(
      NavbarController(userProfile: userProfile),
      tag: userProfile.name,
    );

    return Scaffold(
      body: body ?? _buildDefaultBody(controller),
      bottomNavigationBar: _buildBottomNavbar(controller),
    );
  }

  Widget _buildDefaultBody(NavbarController controller) {
    return Obx(() {
      final currentItem = controller.navbarItems[controller.currentIndex];
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              currentItem.activeIcon,
              width: 64,
              height: 64,
              colorFilter: const ColorFilter.mode(
                AppColors.primaryButtonColor,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${currentItem.label} Screen',
              style: getTextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Profile: ${userProfile.name.toUpperCase()}',
              style: getTextStyle(fontSize: 16, color: Colors.grey[600]!),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBottomNavbar(NavbarController controller) {
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
    return Obx(() {
      final isSelected = index == controller.currentIndex;
      final itemColor = isSelected
          ? AppColors.primaryButtonColor
          : AppColors.appBarTitleColor;

      return GestureDetector(
        onTap: () => controller.changeTab(index),
        behavior: HitTestBehavior
            .opaque, // This ensures the entire container is clickable
        child: Container(
          width: 70,
          padding: const EdgeInsets.symmetric(
            vertical: 4,
          ), // Add some vertical padding
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  SvgPicture.asset(
                    isSelected ? item.activeIcon : item.inactiveIcon,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(itemColor, BlendMode.srcIn),
                  ),
                  if (item.hasNotification && item.notificationCount != null)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.uiDangerColor,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          item.notificationCount!,
                          style: getTextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                textAlign: TextAlign.center,
                style: getTextStyle(
                  color: itemColor,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  height: 1.50,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
