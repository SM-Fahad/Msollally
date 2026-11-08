import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/recruiter/candidates/all_candidates/screen/all_candidates_screen.dart';
import 'package:msollaally/feature/recruiter/jobs/all_jobs/screen/all_jobs_screen.dart';
import '../../../navbar/controller/navbar_controller.dart';
import '../../../navbar/model/navbar_item.dart';
import '../../../navbar/widget/bottom_navbar_widget.dart';
import '../../home/screen/recruiter_home_screen.dart';
import '../../more/screen/recruiter_more_screen.dart';

class RecruiterNavScreen extends StatelessWidget {
  const RecruiterNavScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      NavbarController(userProfile: UserProfile.recruiter),
      tag: UserProfile.recruiter.name,
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
        return RecruiterHomeScreen();
      case 1:
        return RecruiterAllJobsScreen();
      case 2:
        return RecruiterAllCandidatesScreen();
      case 3:
        return RecruiterMoreScreen();
      default:
        return RecruiterHomeScreen();
    }
  }
}
