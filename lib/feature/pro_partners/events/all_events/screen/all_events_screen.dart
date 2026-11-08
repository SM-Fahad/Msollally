import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/pro_partners/events/create_event/screen/create_event_screen.dart';
import 'package:msollaally/feature/pro_partners/more/controller/pro_partners_more_controller.dart';
import 'package:msollaally/feature/pro_partners/widgets/default_pro_partners_app_bar.dart';
import '../controller/all_events_controller.dart';
import 'all_events_states.dart';
import 'all_events_widgets.dart';

class ProPartnersAllEventsScreen extends StatelessWidget {
  ProPartnersAllEventsScreen({super.key});

  final AllEventsController controller = Get.put(AllEventsController());
  final ProPartnersMoreController moreController = Get.put(
    ProPartnersMoreController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ghostWhiteF6F9FF,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(72),
        child: Obx(
          () => DefaultProPartnersAppBar(
            title: 'Events',
            profileImageUrl: moreController.profileImageUrl,
            notificationCount: 9,
          ),
        ),
      ),
      body: Column(
        children: [
          _Header(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return LoadingList();
              }
              if (controller.errorMessage.value.isNotEmpty) {
                return ErrorState(
                  message: controller.errorMessage.value,
                  onRetry: controller.fetchMyEvents,
                );
              }
              if (controller.events.isEmpty) {
                return RefreshIndicator(
                  onRefresh: controller.fetchMyEvents,
                  child: ListView(
                    padding: EdgeInsets.all(24),
                    children: [EmptyState()],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: controller.fetchMyEvents,
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(18, 4, 18, 90),
                  itemCount: controller.events.length,
                  itemBuilder: (_, index) => Padding(
                    padding: EdgeInsets.only(bottom: 14),
                    child: EventCard(
                      event: controller.events[index],
                      controller: controller,
                    ),
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

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 18, 18, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Events',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.midnightBlue132238,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Manage your events, updates, and registrations.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => Get.to(() => CreateEventScreen()),
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.royalBlue3B82F6,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.royalBlueAlpha223B82F6,
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Add Event',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
