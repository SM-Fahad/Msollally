import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import '../controller/teacher_schedule_class_controller.dart';
import '../widgets/schedule_event_detail_sheet.dart';
import '../widgets/schedule_event_dialog.dart';
import '../widgets/schedule_event_tile.dart';

class TeacherScheduleClassScreen extends StatelessWidget {
  TeacherScheduleClassScreen({super.key});

  final TeacherScheduleClassController controller = Get.put(
    TeacherScheduleClassController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Calendar"),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: controller.loadScheduledClasses,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh calendar',
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Center(
                      child: InkWell(
                        onTap: () => showAddEventDialog(controller.eventController),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryButtonColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text("+  Add", style: getTextStyle(color: AppColors.whiteFDFEFF)),
                        ),
                      ),
                    ),
                  ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value &&
              controller.scheduledClassCount.value == 0) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.value.isNotEmpty &&
              controller.scheduledClassCount.value == 0) {
            return _TeacherCalendarStatusView(
              message: controller.errorMessage.value,
              actionLabel: 'Retry',
              onAction: controller.loadScheduledClasses,
            );
          }

          if (controller.scheduledClassCount.value == 0) {
            return _TeacherCalendarStatusView(
              message: 'No scheduled classes found.',
              actionLabel: 'Refresh',
              onAction: controller.loadScheduledClasses,
            );
          }

          return Column(
            children: [
              if (controller.isLoading.value) const LinearProgressIndicator(),
              Expanded(
                child: WeekView<TeacherCalendarClassEvent>(
                  controller: controller.eventController,
                  weekTitleHeight: 70,
                  eventTileBuilder: (date, events, _, start, end) {
                    return ScheduleEventTile<TeacherCalendarClassEvent>(
                      events: events,
                      start: start,
                      end: end,
                    );
                  },
                  minDay: DateTime(1990),
                  maxDay: DateTime(2050),
                  initialDay: controller.initialDay.value,
                  heightPerMinute: 1.2,
                  onEventTap: (events, date) =>
                      showEventDetailSheet(events, date),
                  onEventDoubleTap: (events, date) => debugPrint("$events"),
                  startDay: WeekDays.saturday,
                  startHour: 7,
                  endHour: 22,
                  showVerticalLines: true,
                  scrollPhysics: const ScrollPhysics(),
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
                    final startMonth = DateFormat('MMMM').format(startDate);
                    final endMonth = DateFormat('MMMM').format(endDate);
                    final year = DateFormat('yyyy').format(endDate);
                    final label = startMonth == endMonth
                        ? '$startMonth $year'
                        : '$startMonth / $endMonth $year';
                    return Container(
                      height: 36.h,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: AppColors.whiteFDFEFF,
                        border: Border(
                          bottom: BorderSide(color: AppColors.lavenderE2E8F0),
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
    );
  }
}

class _TeacherCalendarStatusView extends StatelessWidget {
  const _TeacherCalendarStatusView({
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: getTextStyle(color: AppColors.secondaryTextColor),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
