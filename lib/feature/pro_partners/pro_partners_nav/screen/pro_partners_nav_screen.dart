import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/pro_partners/events/all_events/screen/all_events_screen.dart';
import 'package:msollaally/feature/pro_partners/jobs/all_jobs/screen/all_jobs_screen.dart';
import 'package:msollaally/feature/pro_partners/more/screen/pro_partners_more_screen.dart';
import '../../../navbar/controller/navbar_controller.dart';
import '../../../navbar/model/navbar_item.dart';
import '../../../navbar/widget/bottom_navbar_widget.dart';
import '../../campaign/all_campaigns/screen/all_campaigns_screen.dart';
import '../../dashboard/screen/pro_partners_dashboard_screen.dart';

class ProPartnersNavScreen extends StatelessWidget {
  const ProPartnersNavScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      NavbarController(userProfile: UserProfile.proPartners),
      tag: UserProfile.proPartners.name,
    );

    return Scaffold(
      appBar: null,
      body: Obx(() => _buildBody(controller.currentIndex)),
      bottomNavigationBar: BottomNavbarWidget(controller: controller),
    );
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return ProPartnersDashboardScreen();
      case 1:
        return ProPartnersAllCampaignsScreen();
      case 2:
        return ProPartnersAllEventsScreen();
      case 3:
        return ProPartnersAllJobsScreen();
      case 4:
        return ProPartnersMoreScreen();
      default:
        return ProPartnersDashboardScreen();
    }
  }
}
