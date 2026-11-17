import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';

import '../../../../core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget leadingIcon;
  final VoidCallback onLeadingTap;
  final String title;
  final Widget? actionWidget;
  final VoidCallback? onActionTap;
  const CustomAppBar({
    super.key,
    required this.leadingIcon,
    required this.onLeadingTap,
    required this.title,

    this.actionWidget,
    this.onActionTap,
  });

  @override
  Size get preferredSize => Size.fromHeight(60.height);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? const Color(0xFF09090B)
        : AppColors.buttonColorOnboarding;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : AppColors.appBarBottomColor;
    final titleColor = isDark ? Colors.white : AppColors.appBarTitleColor;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.height, horizontal: 20.width),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: Row(
              children: [
                // ignore: unnecessary_null_comparison
                leadingIcon != null
                    ? InkWell(onTap: onLeadingTap, child: leadingIcon)
                    : const SizedBox(),
                SizedBox(width: 8.width),
                Text(
                  title,
                  style: appTextStyleHeading1(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
              ],
            ),
          ),
          actionWidget != null
              ? InkWell(onTap: onActionTap, child: actionWidget)
              : const SizedBox(),
        ],
      ),
    );
  }
}
