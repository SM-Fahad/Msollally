import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import '../controller/event_overview_controller.dart';
import 'attendees_tab_cards.dart';
import 'attendees_tab_header.dart';

class AttendeesTabWidget extends StatelessWidget {
  final String controllerTag;

  const AttendeesTabWidget({super.key, required this.controllerTag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EventOverviewController>(tag: controllerTag);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.ghostWhiteF7FAFF, AppColors.aliceBlueEEF4FF, AppColors.whiteFDFEFF],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: AttendeesHeader(controller: controller),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isAttendeesLoading.value) {
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  itemCount: 5,
                  itemBuilder: (_, __) => const AttendeeShimmerCard(),
                );
              }

              if (controller.attendees.isEmpty) {
                return AttendeesEmptyState(
                  message: controller.attendeesError.value.isNotEmpty
                      ? controller.attendeesError.value
                      : 'No attendees found for this filter yet.',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                itemCount: controller.attendees.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: AttendeeCard(
                    attendee: controller.attendees[i],
                    controller: controller,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
