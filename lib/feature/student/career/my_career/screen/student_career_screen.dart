import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/widgets/default_student_app_bar.dart';
import 'package:msollaally/feature/student/career/find_jobs/screen/job_screen.dart';
import 'package:msollaally/feature/student/career/gigs/screen/gigs_screen.dart';
import 'package:msollaally/feature/student/career/scholarships/screen/scholarship_screen.dart';
import 'package:msollaally/feature/student/career/my_career/controller/my_career_controller.dart';
import 'package:msollaally/feature/student/career/my_career/widget/career_tab_item.dart';
import 'package:msollaally/feature/student/career/my_career/widgets/my_career_tab_view.dart';

class StudentCareerScreen extends StatelessWidget {
  StudentCareerScreen({super.key});

  final CareerController controller = Get.put(CareerController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: DefaultStudentAppBar(
          title: _getTitle(controller.selectedTab.value),
          isHomePage: false,
        ),
        body: Column(
          children: [
            _buildTabBar(),
            const Divider(height: 1),
            Expanded(child: _buildTabContent(controller.selectedTab.value, controller)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTab(0, 'My Career'),
            _buildTab(1, 'Find Jobs'),
            _buildTab(2, 'Gigs'),
            _buildTab(3, 'Scholarships'),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    return GestureDetector(
      onTap: () => controller.selectedTab.value = index,
      child: CareerTabItem(label: label, isActive: controller.selectedTab.value == index),
    );
  }

  Widget _buildTabContent(int tab, CareerController controller) {
    switch (tab) {
      case 0:
        return MyCareerTabView(controller: controller);
      case 1:
        return JobScreen();
      case 2:
        return const GigScreen();
      case 3:
        return const ScholarshipScreen();
      default:
        return const SizedBox();
    }
  }

  String _getTitle(int tab) {
    switch (tab) {
      case 0:
        return 'My Career';
      case 1:
        return 'Find Jobs';
      case 2:
        return 'Gigs';
      case 3:
        return 'Scholarships';
      default:
        return 'Career';
    }
  }
}
