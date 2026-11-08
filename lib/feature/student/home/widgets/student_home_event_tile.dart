import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/pro_partners/events/all_events/model/event_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/routes/app_route.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StudentHomeEventTile extends StatelessWidget {
  final EventModel event;
  final DateFormat formatter;

  const StudentHomeEventTile({super.key, required this.event, required this.formatter});

  @override
  Widget build(BuildContext context) {
    final media = event.coverImageUrl.isNotEmpty ? event.coverImageUrl : event.mediaUrl;
    
    return InkWell(
      onTap: () {
        Get.toNamed(
          AppRoute.studentCampusEventDetail,
          arguments: {
            'id': event.id,
            'title': event.title,
            'tag': event.status,
            'date': formatter.format(event.dateTime.toLocal()),
            'location': event.location.isEmpty ? 'Location not set' : event.location,
            'rsvps': '${event.rsvps}',
            'views': '${event.views} views',
          },
        );
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image / Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: media.isNotEmpty
                  ? Image.network(
                      media,
                      width: 64.w,
                      height: 64.h,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackImage(),
                    )
                  : _fallbackImage(),
            ),
            SizedBox(width: 14.w),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    event.title.isNotEmpty ? event.title : 'Event',
                    style: getTextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.access_time_filled_rounded, size: 14.sp, color: AppColors.primaryButtonColor),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          DateFormat('MMM dd, yyyy • hh:mm a').format(event.dateTime.toLocal()),
                          style: getTextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 14.sp, color: const Color(0xFF94A3B8)),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          event.location.isNotEmpty ? event.location : 'Campus',
                          style: getTextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF94A3B8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.chevron_right_rounded, color: const Color(0xFFCBD5E1), size: 24.sp),
          ],
        ),
      ),
    );
  }

  Widget _fallbackImage() {
    return Container(
      width: 64.w,
      height: 64.h,
      color: const Color(0xFFF8FAFC),
      child: Icon(Icons.event_note_rounded, color: const Color(0xFF94A3B8), size: 24.sp),
    );
  }
}
