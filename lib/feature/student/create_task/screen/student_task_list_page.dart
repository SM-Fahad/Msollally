import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/create_task/controller/student_create_task_controller.dart';
import 'package:msollaally/feature/student/notification/widgets/custom_app_bar.dart';
import 'package:msollaally/routes/app_route.dart';

import '../../../../core/const/icons_path.dart';
import 'package:msollaally/core/const/appcolors.dart';
import '../widgets/student_create_task_iteam.dart';

class StudentAllTaskList extends StatelessWidget {
  const StudentAllTaskList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<StudentCreateTaskController>()
        ? Get.find<StudentCreateTaskController>()
        : Get.put(StudentCreateTaskController());
    controller.fetchAllTasks();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar(
                leadingIcon: SvgPicture.asset(
                  IconsPath.arrowLeftIcon,
                  height: 24.height,
                  width: 24.width,
                ),
                onLeadingTap: () {
                  Get.back();
                },
                title: "Tasks",
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    // srudent task items
                    [StudentTaskListItem(controller: controller)],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(100.radius),
        ),
        backgroundColor: AppColors.primaryButtonColor,
        elevation: 0,
        highlightElevation: 0,

        onPressed: () {
          Get.toNamed(AppRoute.studentCreateTask);
        },
        child: Image.asset(IconsPath.plusIcon, color: Colors.white),
      ),
    );
  }
}
