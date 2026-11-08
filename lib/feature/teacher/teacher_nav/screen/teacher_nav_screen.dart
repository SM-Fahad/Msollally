import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/teacher/courses/screen/teacher_courses_screen.dart';
import 'package:msollaally/feature/teacher/more/screen/teacher_more_screen.dart';
import 'package:msollaally/feature/teacher/students/screen/teacher_students_screen.dart';
import '../../../navbar/controller/navbar_controller.dart';
import '../../../navbar/model/navbar_item.dart';
import '../../../navbar/widget/bottom_navbar_widget.dart';
import '../../home/screen/teacher_home_screen.dart';

class TeacherNavScreen extends StatelessWidget {
  const TeacherNavScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      NavbarController(userProfile: UserProfile.teacher),
      tag: UserProfile.teacher.name,
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
        return TeacherHomeScreen();
      case 1:
        return TeacherCoursesScreen();
      case 2:
        return TeacherStudentsScreen();
      case 3:
        return TeacherMoreScreen();
      default:
        return TeacherHomeScreen();
    }
  }
}
