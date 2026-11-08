import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/student_campus_controller.dart';
import 'package:msollaally/feature/student/widgets/default_student_app_bar.dart';

import '../widgets/srudent_campus_friends.dart';
import '../widgets/student_campus_union.dart';
import '../widgets/student_campus_wall_field.dart';
import '../widgets/student_campus_tab.dart';
import 'package:msollaally/feature/student/campus/campaign/screen/student_campus_campaign_screen.dart';
import 'package:msollaally/feature/student/campus/campaign/controller/student_campus_campaign_controller.dart';
import 'package:msollaally/feature/student/campus/event/screen/student_campus_events_screen.dart';
import 'package:msollaally/feature/student/campus/event/controller/student_campus_event_controller.dart';
import 'package:msollaally/feature/student/campus/campus_inbox/screen/inbox_screen.dart';

class StudentCampusScreen extends StatelessWidget {
  const StudentCampusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    var _controller = Get.put(StudentCampusController());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DefaultStudentAppBar(title: 'Campus', isHomePage: false),
      body: RefreshIndicator(
        onRefresh: _controller.refreshAll,
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
              if (_controller.selectedTab.value == 0) {
                 _controller.fetchMorePosts();
              } else if (_controller.selectedTab.value == 3) {
                if (Get.isRegistered<StudentCampusCampaignController>()) {
                  Get.find<StudentCampusCampaignController>().fetchMoreCampaigns();
                }
              } else if (_controller.selectedTab.value == 4) {
                if (Get.isRegistered<StudentCampusEventController>()) {
                  Get.find<StudentCampusEventController>().fetchMoreEvents();
                }
              }
            }
            return false;
          },
          child: SingleChildScrollView(
            key: const PageStorageKey<String>('student_campus_wall_scroll_view'),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StudentCampusTab(controller: _controller),
                SizedBox(height: 16.height),
                Obx(() {
                  if (_controller.selectedTab.value == 0) {
                    return StudentCampusWallField(controller: _controller);
                  } else if (_controller.selectedTab.value == 1) {
                    return StudentCampusUnion(controller: _controller);
                  } else if (_controller.selectedTab.value == 2) {
                    return const StudentCampusFriend();
                  } else if (_controller.selectedTab.value == 3) {
                    return const StudentCampusCampaignScreen();
                  } else if (_controller.selectedTab.value == 4) {
                    return const StudentCampusEventsScreen();
                  } else if (_controller.selectedTab.value == 5) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height - 180.height,
                      child: const InboxScreen(showAppBar: false),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
