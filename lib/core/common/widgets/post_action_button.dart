import 'package:msollaally/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../common/styles/global_text_style.dart';

class PostActionButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;
  final Color activeColor;
  final Color inactiveColor;

  const PostActionButton({
    super.key,
    required this.iconPath,
    required this.label,
    this.isActive = false,
    this.onTap,
    this.activeColor = AppColors.dodgerBlue2196F3,
    this.inactiveColor = AppColors.appBarTitleColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : inactiveColor;
    final isSvg = iconPath.toLowerCase().endsWith('.svg');

    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          isSvg
              ? SvgPicture.asset(
                  iconPath,
                  height: 20.height,
                  width: 20.width,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                )
              : Image.asset(iconPath, height: 20.height, width: 20.width, color: color),
          SizedBox(width: 6.width),
          Text(label, style: appTextStyleHeading2(color: color)),
        ],
      ),
    );
  }
}
