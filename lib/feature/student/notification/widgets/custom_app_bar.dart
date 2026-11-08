import 'package:flutter/material.dart' show InkWell;
import 'package:flutter/widgets.dart';
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
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.height, horizontal: 20.width),
      decoration: BoxDecoration(
        color: AppColors.buttonColorOnboarding,
        border: Border(bottom: BorderSide(color: AppColors.appBarBottomColor)),
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
                    : SizedBox(),
                SizedBox(width: 8.width),
                Text(
                  title,
                  style: appTextStyleHeading1(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.appBarTitleColor,
                  ),
                ),
              ],
            ),
          ),
          actionWidget != null
              ? InkWell(onTap: onActionTap, child: actionWidget)
              : SizedBox(),
        ],
      ),
    );
  }
}
