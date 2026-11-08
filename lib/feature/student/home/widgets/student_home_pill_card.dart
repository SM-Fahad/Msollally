import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';

const _pillBlue = Color(0xFFD9F3FF);
const _titleColor = Color(0xFF0F172A);

class StudentHomePillCard extends StatelessWidget {
  const StudentHomePillCard({
    super.key,
    this.leading,
    this.icon,
    required this.title,
    this.subtitle,
    this.titleSize = 15,
    this.dense = false,
    this.backgroundColor,
    this.borderColor,
  });

  final Widget? leading;
  final IconData? icon;
  final String title;
  final String? subtitle;
  final double titleSize;
  final bool dense;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: dense ? 38.height : 58.height),
      padding: EdgeInsets.symmetric(
        horizontal: 14.width,
        vertical: dense ? 6.height : 9.height,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? _pillBlue,
        borderRadius: BorderRadius.circular(14.radius),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1.0)
            : Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            SizedBox(width: 14.width),
          ] else if (icon != null) ...[
            Icon(icon, color: AppColors.saddleBrown6B4F00, size: 24.fontSize),
            SizedBox(width: 14.width),
          ],
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: getTextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w800,
                    color: _titleColor,
                    height: 1.05,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: getTextStyle(
                      fontSize: 12,
                      color: _titleColor,
                      height: 1.15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StudentHomeSectionTitle extends StatelessWidget {
  const StudentHomeSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: getTextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: _titleColor,
      ),
    );
  }
}
