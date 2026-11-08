import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/academics/courses/academic_courses/screen/academics_screen.dart';
import 'package:msollaally/feature/student/campus/campus_home/screen/student_campus_screen.dart';
import 'package:msollaally/feature/student/more/screen/student_more_screen.dart';
import '../../../navbar/controller/navbar_controller.dart';
import '../../../navbar/model/navbar_item.dart';
import '../../../navbar/widget/bottom_navbar_widget.dart';
import '../../career/my_career/screen/student_career_screen.dart';
import 'student_home_content.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller with student profile
    final controller = Get.put(
      NavbarController(userProfile: UserProfile.student),
      tag: UserProfile.student.name,
    );

    return Scaffold(
      body: Obx(() => _buildBody(controller.currentIndex)),
      bottomNavigationBar: BottomNavbarWidget(controller: controller),
    );
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return StudentHomeContent();
      case 1:
        return StudentAcademicsScreen();
      case 2:
        return StudentCampusScreen();
      case 3:
        return StudentCareerScreen();
      case 4:
        return StudentMoreScreen();
      default:
        return StudentHomeContent();
    }
  }
}
