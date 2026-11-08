// ignore_for_file: no_leading_underscores_for_local_identifiers, avoid_print

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/calender/controller/student_calender_controller.dart';
import 'package:msollaally/feature/student/notification/widgets/custom_app_bar.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/teacher/schedule_classes/widgets/schedule_event_tile.dart';
import 'package:msollaally/feature/teacher/schedule_classes/widgets/schedule_event_detail_sheet.dart';
import 'package:msollaally/feature/teacher/schedule_classes/widgets/schedule_event_dialog.dart';

import '../../../../core/const/icons_path.dart';
import 'package:msollaally/core/const/appcolors.dart';

class StudentCalenderPage extends StatelessWidget {
  const StudentCalenderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _controller = Get.put(StudentCalenderController());
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leadingIcon: SvgPicture.asset(IconsPath.arrowLeftIcon),
              onLeadingTap: () {
                Get.back();
              },
              title: "My Weekly Calender",
              actionWidget: Container(
                padding: EdgeInsets.all(8.width),
                height: 40.height,
                width: 40.width,
                decoration: BoxDecoration(
                  color: AppColors.primaryButtonColor,
                  borderRadius: BorderRadius.circular(8.radius),
                ),
                child: Image.asset(
                  IconsPath.plusIcon,
                  height: 40.height,
                  width: 40.height,
                  color: AppColors.buttonColorOnboarding,
                ),
              ),
              onActionTap: () =>
                  showAddEventDialog(_controller.eventController),
            ),
            Expanded(
              child: Obx(() {
                if (_controller.errorMessage.value.isNotEmpty &&
                    _controller.scheduledClassCount.value == 0) {
                  return _StudentCalendarStatusView(
                    message: _controller.errorMessage.value,
                    actionLabel: 'Retry',
                    onAction: _controller.loadScheduledClasses,
                  );
                }

                return Column(
                  children: [
                    if (_controller.isLoading.value)
                      const LinearProgressIndicator(),
                    Expanded(
                      child: WeekView<StudentCalendarClassEvent>(
                        controller: _controller.eventController,
                        weekTitleHeight: 70,
                        eventTileBuilder: (date, events, _, start, end) {
                          return ScheduleEventTile<StudentCalendarClassEvent>(
                            events: events,
                            start: start,
                            end: end,
                          );
                        },
                        minDay: DateTime(DateTime.now().year - 1),
                        maxDay: DateTime(DateTime.now().year + 3),
                        initialDay: _controller.initialDay.value,
                        heightPerMinute: 1,
                        onEventTap: (events, date) =>
                            showEventDetailSheet(events, date),
                        onEventDoubleTap: (events, date) => print(events),
                        onDateLongPress: (date) => print(date),
                        startDay: WeekDays.saturday,
                        startHour: 0,
                        endHour: 24,
                        timeLineBuilder: (date) {
                          return Transform.translate(
                            // Shift 12 AM down slightly so it isn't clipped by the top edge
                            offset: Offset(0, date.hour == 0 ? 8.0 : 0.0),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: EdgeInsets.only(right: 8.width),
                                child: Text(
                                  DateFormat('h a').format(date),
                                  style: getTextStyle(
                                    fontSize: 11,
                                    color: AppColors.secondaryTextColor,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        showVerticalLines: true,
                        weekDays: const [
                          WeekDays.monday,
                          WeekDays.tuesday,
                          WeekDays.wednesday,
                          WeekDays.thursday,
                          WeekDays.friday,
                          WeekDays.saturday,
                          WeekDays.sunday,
                        ],
                        weekPageHeaderBuilder: (startDate, endDate) {
                          // Show month(s) + year in the week header.
                          final startMonth = DateFormat(
                            'MMMM',
                          ).format(startDate);
                          final endMonth = DateFormat('MMMM').format(endDate);
                          final year = DateFormat('yyyy').format(endDate);
                          final label = startMonth == endMonth
                              ? '$startMonth $year'
                              : '$startMonth / $endMonth $year';
                          return Container(
                            height: 36.height,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 16.width),
                            decoration: BoxDecoration(
                              color: AppColors.whiteFDFEFF,
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.lavenderE2E8F0,
                                ),
                              ),
                            ),
                            child: Text(
                              label,
                              style: getTextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryTextColor,
                              ),
                            ),
                          );
                        },
                        fullDayHeaderTextConfig: const FullDayHeaderTextConfig(
                          textAlign: TextAlign.center,
                          textOverflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        keepScrollOffset: true,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentCalendarStatusView extends StatelessWidget {
  const _StudentCalendarStatusView({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.width),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: getTextStyle(color: AppColors.secondaryTextColor),
            ),
            SizedBox(height: 12.height),
            ElevatedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
