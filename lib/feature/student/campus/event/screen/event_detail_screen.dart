import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import '../../../../../core/common/styles/global_text_style.dart';
import '../controller/student_event_social_feed_controller.dart';
import '../widgets/student_event_social_post_card_widget.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Extract static arguments passed from list page
    final argIdStr = Get.arguments?['id']?.toString() ?? '';
    final argId = int.tryParse(argIdStr) ?? 0;
    
    if (argId == 0) {
      return const Scaffold(
        body: Center(child: Text('Invalid Event ID')),
      );
    }

    final feedTag = 'student-event-feed-$argId';
    final controller = Get.put(
      StudentEventSocialFeedController(eventId: argId),
      tag: feedTag,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Event Details',
          style: appTextStyleHeading1(
            fontSize: 20.fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isInitialLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refreshFeed,
          child: ListView(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.width, 16.height, 16.width, 40.height),
            children: [
              StudentEventSocialPostCardWidget(tag: feedTag),
            ],
          ),
        );
      }),
    );
  }
}
