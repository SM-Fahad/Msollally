import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';

class ScheduleEventTile<T extends Object?> extends StatelessWidget {
  final List<CalendarEventData<T>> events;
  final DateTime start;
  final DateTime end;

  const ScheduleEventTile({
    super.key,
    required this.events,
    required this.start,
    required this.end,
  });

  @override
  Widget build(BuildContext context) {
    final event = events.first;
    final accentColor = event.color;
    final timeText =
        '${DateFormat('h:mm a').format(start)} - ${DateFormat('h:mm a').format(end)}';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: accentColor.withValues(alpha: 0.6)),
        color: accentColor.withValues(alpha: 0.15),
      ),
      child: ClipRect(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                event.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: getTextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: accentColor),
              ),
              Text(
                timeText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: getTextStyle(
                  fontSize: 9,
                  color: AppColors.secondaryTextColor,
                ),
              ),
              if ((event.description ?? '').trim().isNotEmpty)
                Text(
                  event.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: getTextStyle(
                    fontSize: 9,
                    color: AppColors.secondaryTextColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
