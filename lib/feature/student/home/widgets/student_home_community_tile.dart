import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import '../model/community_model.dart';

class StudentHomeCommunityTile extends StatelessWidget {
  const StudentHomeCommunityTile({super.key, required this.chat});
  final CommunityModel chat;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: chat.ontap,
      borderRadius: BorderRadius.circular(14.radius),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.width, vertical: 10.height),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14.radius),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            chat.icon.endsWith('.svg')
                ? SvgPicture.asset(
                    chat.icon,
                    height: 32.height,
                    width: 32.width,
                  )
                : Image.asset(
                    chat.icon,
                    height: 32.height,
                    width: 32.width,
                    fit: BoxFit.contain,
                  ),
            SizedBox(width: 12.width),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.text,
                    style: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.height),
                  Text(
                    '${chat.days} new messages',
                    style: getTextStyle(
                      fontSize: 12,
                      color: AppColors.checkBoxActiveColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}
