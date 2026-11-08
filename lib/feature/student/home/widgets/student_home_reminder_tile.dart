import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import '../model/upcomming_reminder.dart';

class StudentHomeReminderTile extends StatelessWidget {
  const StudentHomeReminderTile({super.key, required this.reminder});
  final UpcommingReminderModel reminder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.width, vertical: 10.height),
      decoration: BoxDecoration(
        color: reminder.containercolor,
        borderRadius: BorderRadius.circular(14.radius),
        border: Border.all(
          color: reminder.containerBorderborderColor,
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          reminder.icon.endsWith('.svg')
              ? SvgPicture.asset(
                  reminder.icon,
                  height: 24.height,
                  width: 24.width,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF0F172A),
                    BlendMode.srcIn,
                  ),
                )
              : Image.asset(
                  reminder.icon,
                  height: 24.height,
                  width: 24.width,
                  fit: BoxFit.contain,
                ),
          SizedBox(width: 12.width),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
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
                  'Due in ${reminder.day} days',
                  style: getTextStyle(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
