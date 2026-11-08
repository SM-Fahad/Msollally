import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/academics/library/screen/library_screen.dart';
import 'package:msollaally/feature/student/academics/preparation/screen/prep_screen.dart';
import 'package:msollaally/feature/student/academics/qBank/screen/question_bank.dart';
import 'package:msollaally/feature/student/widgets/default_student_app_bar.dart';
import '../controller/academics_controller.dart';
import '../../../plans/screen/plans_screen.dart';
import '../widgets/academics_tab_item.dart';
import '../widgets/academics_courses_section.dart';

class StudentAcademicsScreen extends StatelessWidget {
  StudentAcademicsScreen({super.key});

  final RxInt selectedTab = 0.obs;

  @override
  Widget build(BuildContext context) {
    final courseController = Get.put(CourseController());

    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: DefaultStudentAppBar(
          isHomePage: false,
          title: _getTitle(selectedTab.value),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabBar(),
            Expanded(
              child: _buildTabContent(selectedTab.value, courseController),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            AcademicsTabItem(
              title: "Courses",
              icon: Icons.menu_book_rounded,
              isActive: selectedTab.value == 0,
              onTap: () => selectedTab.value = 0,
            ),
            const SizedBox(width: 8),
            AcademicsTabItem(
              title: "Plans",
              icon: Icons.calendar_today_outlined,
              isActive: selectedTab.value == 1,
              onTap: () => selectedTab.value = 1,
            ),
            const SizedBox(width: 8),
            AcademicsTabItem(
              title: "Prep",
              icon: Icons.psychology_outlined,
              isActive: selectedTab.value == 2,
              onTap: () => selectedTab.value = 2,
            ),
            const SizedBox(width: 8),
            AcademicsTabItem(
              title: "Library",
              icon: Icons.local_library_outlined,
              isActive: selectedTab.value == 3,
              onTap: () => selectedTab.value = 3,
            ),
            const SizedBox(width: 8),
            AcademicsTabItem(
              title: "Q Bank",
              icon: Icons.help_outline_rounded,
              isActive: selectedTab.value == 4,
              onTap: () => selectedTab.value = 4,
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle(int tab) => "Academics";

  Widget _buildTabContent(int tab, CourseController courseController) {
    switch (tab) {
      case 0:
        return AcademicsCoursesSection(courseController: courseController);
      case 1:
        return StudentPlanScreen();
      case 2:
        return StudentPrepScreen();
      case 3:
        return StudentLibraryScreen();
      case 4:
        return QuestionBankScreen();
      default:
        return SizedBox();
    }
  }
}
