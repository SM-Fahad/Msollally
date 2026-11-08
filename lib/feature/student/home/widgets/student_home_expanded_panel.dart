import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/routes/app_route.dart';
import '../../../../core/const/appcolors.dart';
import '../controller/student_home_controller.dart';
import 'student_home_reminder_tile.dart';
// import 'student_home_community_tile.dart';
// import 'student_home_for_you_tile.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/feature/student/campus/event/controller/student_campus_event_controller.dart';
import 'package:msollaally/feature/student/home/widgets/student_home_event_tile.dart';
// import 'package:msollaally/feature/student/campus/event/screen/student_campus_events_screen.dart';
import 'package:msollaally/feature/navbar/controller/navbar_controller.dart';
import 'package:msollaally/feature/navbar/model/navbar_item.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/student_campus_controller.dart';

import 'package:msollaally/feature/student/career/find_jobs/controller/jobs.controller.dart';
import 'package:msollaally/feature/student/career/find_jobs/screen/job_details_screen.dart';
import 'package:msollaally/feature/student/career/my_career/controller/my_career_controller.dart';

void showStudentHomeExpandedPanel(
  BuildContext context,
  StudentHomeController controller,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.radius)),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 40.width,
                height: 4.height,
                margin: EdgeInsets.symmetric(vertical: 12.height),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 18.width,
                vertical: 8.height,
              ),
              child: Row(
                children: [
                  Text(
                    'More for You',
                    style: getTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(
                  18.width,
                  16.height,
                  18.width,
                  24.height,
                ),
                children: [
                  _buildReminders(controller),
                  // _buildCommunity(controller),
                  _buildCareer(controller),
                  _buildEvents(controller),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildReminders(StudentHomeController controller) {
  return Obx(() {
    final reminders = controller.upcommingReminder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Reminders',
              style: getTextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(Get.context!).pop();
                Get.toNamed(AppRoute.studentCalenderPage);
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 15,
                      color: AppColors.primaryButtonColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Calendar',
                      style: getTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryButtonColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.height),
        if (reminders.isEmpty)
          InkWell(
            onTap: () {
              Navigator.of(Get.context!).pop();
              Get.toNamed(AppRoute.studentCalenderPage);
            },
            borderRadius: BorderRadius.circular(14.radius),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: 24.height,
                horizontal: 16.width,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14.radius),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.event_available_rounded,
                    size: 32,
                    color: const Color(0xFF94A3B8),
                  ),
                  SizedBox(height: 8.height),
                  Text(
                    'No upcoming reminders',
                    style: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 4.height),
                  Text(
                    'Tap to view your calendar',
                    style: getTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryButtonColor,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reminders.length > 2 ? 2 : reminders.length,
            separatorBuilder: (_, __) => SizedBox(height: 8.height),
            itemBuilder: (context, index) =>
                StudentHomeReminderTile(reminder: reminders[index]),
          ),
        SizedBox(height: 20.height),
      ],
    );
  });
}

// Widget _buildCommunity(StudentHomeController controller) {
//   return Obx(() {
//     final community = controller.community;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Community Chats',
//               style: getTextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w800,
//                 color: const Color(0xFF0F172A),
//               ),
//             ),
//             if (community.isNotEmpty)
//               TextButton(
//                 onPressed: () {
//                   Get.back();
//                   Get.toNamed(AppRoute.studentCampusInbox);
//                 },
//                 style: TextButton.styleFrom(
//                   padding: EdgeInsets.zero,
//                   minimumSize: Size.zero,
//                   tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                 ),
//                 child: Text(
//                   'View All',
//                   style: getTextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: const Color(0xFF4B3980),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         SizedBox(height: 8.height),
//         if (community.isEmpty)
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.symmetric(
//               vertical: 24.height,
//               horizontal: 16.width,
//             ),
//             decoration: BoxDecoration(
//               color: const Color(0xFFF8FAFC),
//               borderRadius: BorderRadius.circular(14.radius),
//               border: Border.all(color: const Color(0xFFE2E8F0)),
//             ),
//             child: Column(
//               children: [
//                 Icon(
//                   Icons.forum_rounded,
//                   size: 32,
//                   color: const Color(0xFF94A3B8),
//                 ),
//                 SizedBox(height: 8.height),
//                 Text(
//                   'No community chats yet',
//                   style: getTextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: const Color(0xFF64748B),
//                   ),
//                 ),
//               ],
//             ),
//           )
//         else
//           ListView.separated(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: community.length > 2 ? 2 : community.length,
//             separatorBuilder: (_, __) => SizedBox(height: 8.height),
//             itemBuilder: (context, index) =>
//                 StudentHomeCommunityTile(chat: community[index]),
//           ),
//         SizedBox(height: 20.height),
//       ],
//     );
//   });
// }

Widget _buildCareer(StudentHomeController controller) {
  final jobController = Get.isRegistered<JobController>()
      ? Get.find<JobController>()
      : Get.put(JobController());

  return Obx(() {
    final jobs = jobController.allJobs;
    final displayJobs = jobs.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Career Opportunities',
              style: getTextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            if (jobs.isNotEmpty)
              GestureDetector(
                onTap: () {
                  Get.back();
                  if (Get.isRegistered<CareerController>()) {
                    Get.find<CareerController>().selectedTab.value = 0;
                  } else {
                    Get.put(CareerController()).selectedTab.value = 0;
                  }
                  if (Get.isRegistered<NavbarController>(
                    tag: UserProfile.student.name,
                  )) {
                    Get.find<NavbarController>(
                      tag: UserProfile.student.name,
                    ).changeTab(3);
                  } else {
                    Get.toNamed(AppRoute.studentCareer);
                  }
                },
                child: Text(
                  'View all',
                  style: getTextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryButtonColor,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 8.height),
        if (displayJobs.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: 24.height,
              horizontal: 16.width,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14.radius),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.work_outline_rounded,
                  size: 32,
                  color: const Color(0xFF94A3B8),
                ),
                SizedBox(height: 8.height),
                Text(
                  'No career opportunities right now',
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          )
        else
          for (final job in displayJobs)
            GestureDetector(
              onTap: () {
                Get.back();
                Get.to(() => JobDetailsScreen(jobId: job.id));
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 12.height),
                padding: EdgeInsets.all(12.width),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.radius),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48.width,
                      height: 48.width,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12.radius),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: job.companyLogo.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12.radius),
                              child: Image.network(
                                job.companyLogo,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                      Icons.business_center_outlined,
                                      size: 24,
                                      color: AppColors.primaryButtonColor,
                                    ),
                              ),
                            )
                          : Icon(
                              Icons.business_center_outlined,
                              size: 24,
                              color: AppColors.primaryButtonColor,
                            ),
                    ),
                    SizedBox(width: 12.width),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: getTextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 4.height),
                          Text(
                            '${job.company} • ${job.location}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: getTextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: const Color(0xFFCBD5E1),
                    ),
                  ],
                ),
              ),
            ),
        SizedBox(height: 12.height),
      ],
    );
  });
}

Widget _buildEvents(StudentHomeController controller) {
  final eventController = Get.isRegistered<StudentCampusEventController>()
      ? Get.find<StudentCampusEventController>()
      : Get.put(StudentCampusEventController());
  final formatter = DateFormat('yyyy-MM-dd, hh:mm a');

  return Obx(() {
    final events = eventController.events;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Event Suggestions',
              style: getTextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            if (events.isNotEmpty)
              GestureDetector(
                onTap: () {
                  Get.back(); // Dismiss the expanded panel
                  if (Get.isRegistered<StudentCampusController>()) {
                    Get.find<StudentCampusController>().selectedTab.value = 4;
                  } else {
                    Get.put(StudentCampusController()).selectedTab.value = 4;
                  }
                  if (Get.isRegistered<NavbarController>(
                    tag: UserProfile.student.name,
                  )) {
                    Get.find<NavbarController>(
                      tag: UserProfile.student.name,
                    ).changeTab(2);
                  } else {
                    Get.toNamed(AppRoute.studentCampus);
                  }
                },
                child: Text(
                  'View More',
                  style: getTextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryButtonColor,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 12.height),
        if (events.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: 24.height,
              horizontal: 16.width,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14.radius),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.event_note_rounded,
                  size: 32,
                  color: const Color(0xFF94A3B8),
                ),
                SizedBox(height: 8.height),
                Text(
                  'No upcoming events',
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 4.height),
                Text(
                  'Check back later for exciting campus events!',
                  style: getTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF94A3B8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          for (int i = 0; i < (events.length > 2 ? 2 : events.length); i++) ...[
            StudentHomeEventTile(event: events[i], formatter: formatter),
            if (i < (events.length > 2 ? 2 : events.length) - 1)
              SizedBox(height: 12.height),
          ],
      ],
    );
  });
}
