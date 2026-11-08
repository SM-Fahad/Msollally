import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../core/common/styles/global_text_style.dart';
import '../../../../../routes/app_route.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/pro_partners/events/all_events/model/event_model.dart';

class StudentEventCard extends StatelessWidget {
  final EventModel event;
  final DateFormat formatter;

  const StudentEventCard({
    super.key,
    required this.event,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    final isUpcoming = event.status.toLowerCase() == 'upcoming';

    return InkWell(
      onTap: () {
        // Fire API call in background for tracking view
        final parsedId = int.tryParse(event.id.toString()) ?? 0;
        if (parsedId != 0) {
          _trackEventView(parsedId);
        }

        Get.toNamed(
          AppRoute.studentCampusEventDetail,
          arguments: {
            'id': event.id,
            'title': event.title,
            'tag': event.status,
            'date': formatter.format(event.dateTime.toLocal()),
            'location': event.location.isEmpty
                ? 'Location not set'
                : event.location,
            'rsvps': '${event.rsvps}',
            'views': '${event.views} views',
          },
        );
      },
      borderRadius: BorderRadius.circular(12.radius),
      child: Container(
        padding: EdgeInsets.all(16.width),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.radius),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Details Column (Left side)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: appTextStyleHeading1(
                      fontSize: 16.fontSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black09090B,
                    ),
                  ),
                  SizedBox(height: 10.height),
                  // Date
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14.fontSize,
                        color: AppColors.tertiaryTextColor,
                      ),
                      SizedBox(width: 6.width),
                      Expanded(
                        child: Text(
                          formatter.format(event.dateTime.toLocal()),
                          style: getTextStyle(
                            color: AppColors.tertiaryTextColor,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.height),
                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14.fontSize,
                        color: AppColors.tertiaryTextColor,
                      ),
                      SizedBox(width: 6.width),
                      Expanded(
                        child: Text(
                          event.location.isEmpty
                              ? 'Location not set'
                              : event.location,
                          style: getTextStyle(
                            color: AppColors.tertiaryTextColor,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.height),
                  // Tag and Views
                  Row(
                    children: [
                      // Upcoming / Past Tag
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.width,
                          vertical: 4.height,
                        ),
                        decoration: BoxDecoration(
                          color: isUpcoming
                              ? AppColors.cornsilkFFF3E0
                              : AppColors.todaysQuickPicContainerBGColor,
                          borderRadius: BorderRadius.circular(4.radius),
                        ),
                        child: Text(
                          event.status,
                          style: getTextStyle(
                            color: isUpcoming
                                ? AppColors.orangeRedE65100
                                : AppColors.gray757575,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.width),
                      // Views Subtext
                      Text(
                        '${event.views} views',
                        style: getTextStyle(
                          color: AppColors.tertiaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.width),
            // Company Branding Right Column
            SizedBox(
              width: 72.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44.width,
                    height: 44.width,
                    decoration: BoxDecoration(
                      color: AppColors.ghostWhiteF8F9FB,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: event.organizerLogo.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              event.organizerLogo,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.business,
                                size: 22.fontSize,
                                color: AppColors.primaryButtonColor,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.business,
                            size: 22.fontSize,
                            color: AppColors.primaryButtonColor,
                          ),
                  ),
                  SizedBox(height: 6.height),
                  Text(
                    event.organizerName.isNotEmpty ? event.organizerName : 'Partner',
                    style: getTextStyle(
                      color: AppColors.black1A1C1E,
                      fontSize: 11.fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _trackEventView(int eventId) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      if (token != null) {
        NetworkCaller().postRequest(
          Urls.eventView(eventId),
          token: 'Bearer $token',
          body: {},
        ); // Fire and forget
      }
    } catch (e) {
      debugPrint('[StudentEventCard] track view error: $e');
    }
  }
}
