import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/event_social_feed_controller.dart';
import '../controller/event_overview_controller.dart';
import 'event_social_post_card_widget.dart';

class SocialFeedIndex extends StatelessWidget {
  final String controllerTag;

  const SocialFeedIndex({super.key, required this.controllerTag});

  @override
  Widget build(BuildContext context) {
    final parent = Get.find<EventOverviewController>(tag: controllerTag);
    final eventId = parent.eventId;
    if (eventId == null) {
      return const Center(child: Text('Event not found'));
    }
    final feedTag = 'event-social-feed-$eventId';
    final controller = Get.put(
      EventSocialFeedController(eventId: eventId),
      tag: feedTag,
    );

    return Obx(() {
      if (controller.isInitialLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: controller.refreshFeed,
        child: ListView(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
          children: [EventSocialPostCardWidget(tag: feedTag)],
        ),
      );
    });
  }
}
