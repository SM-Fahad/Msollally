import 'dart:ui';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barBgColor = isDark
        ? const Color(0xFF18181B).withValues(alpha: 0.90)
        : Colors.white.withValues(alpha: 0.92);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.black.withValues(alpha: 0.08);

    return Container(
      color: isDark ? const Color(0xFF09090B) : Colors.white,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(14, 6, 14, 12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.10),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                decoration: BoxDecoration(
                  color: barBgColor,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: controller.navbarItems
                        .asMap()
                        .entries
                        .map(
                          (entry) => _buildNavbarItem(
                            context,
                            controller,
                            entry.key,
                            entry.value,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavbarItem(
    BuildContext context,
    NavbarController controller,
    int index,
    NavbarItem item,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Obx(() {
        final isSelected = index == controller.currentIndex;
        final itemColor = isSelected
            ? AppColors.primaryButtonColor
            : (isDark ? Colors.white70 : AppColors.appBarTitleColor);

        return GestureDetector(
          onTap: () => controller.changeTab(index),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryButtonColor.withValues(
                      alpha: isDark ? 0.18 : 0.10,
                    )
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  isSelected ? item.activeIcon : item.inactiveIcon,
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(itemColor, BlendMode.srcIn),
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: getTextStyle(
                    color: itemColor,
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    height: 1.15,
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
