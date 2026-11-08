import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/teacher/courses/course_assesment/screen/course_assesment_screen.dart';
import 'package:msollaally/feature/teacher/courses/course_module/controller/course_module_controller.dart';
import 'package:msollaally/feature/teacher/courses/course_module/widget/course_module_card.dart';
import 'package:msollaally/feature/teacher/courses/course_notices/screen/course_notice_screen.dart';
import 'package:msollaally/feature/teacher/courses/course_students/screen/course_student_screen.dart';
import 'package:msollaally/routes/app_route.dart';

class CourseModuleScreen extends StatelessWidget {
  CourseModuleScreen({super.key}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.syncCourseFromArguments(Get.arguments);
    });
  }

  final CourseModuleController controller =
      Get.isRegistered<CourseModuleController>()
      ? Get.find<CourseModuleController>()
      : Get.put(CourseModuleController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Obx(
            () => Text(
              controller.selectedCourse.value?.title.isNotEmpty == true
                  ? controller.selectedCourse.value!.title
                  : 'Module',
            ),
          ),
          bottom: const TabBar(
            tabAlignment: TabAlignment.center,
            isScrollable: true,
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
            tabs: [
              Tab(text: 'Module'),
              Tab(text: 'Assessments'),
              Tab(text: 'Students'),
              Tab(text: 'Notices'),
            ],
          ),
          actions: [
            // Stack(
            //   children: [
            //     Padding(
            //       padding: const EdgeInsets.all(8),
            //       child: InkWell(
            //         onTap: () {
            //           debugPrint('Messages tapped');
            //         },
            //         child: ImageIcon(
            //           const AssetImage(IconsPath.moduleMsgTeacherFlow),
            //           size: 28,
            //           color: Colors.blue,
            //         ),
            //       ),
            //     ),
            //     Positioned(
            //       right: 2,
            //       top: 2,
            //       child: Container(
            //         padding: const EdgeInsets.all(2),
            //         decoration: BoxDecoration(
            //           color: Colors.red,
            //           borderRadius: BorderRadius.circular(10),
            //         ),
            //         constraints: const BoxConstraints(
            //           minWidth: 18,
            //           minHeight: 18,
            //         ),
            //         child: const Text(
            //           '15',
            //           style: TextStyle(color: Colors.white, fontSize: 12),
            //           textAlign: TextAlign.center,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: controller.refreshModules,
            ),
          ],
        ),
        body: TabBarView(
          children: [
            ModuleTabView(controller: controller),
            CourseAssessmentScreen(),
            CourseStudentScreen(),
            CourseNoticeScreen(),
          ],
        ),
      ),
    );
  }
}

class ModuleTabView extends StatelessWidget {
  const ModuleTabView({super.key, required this.controller});

  final CourseModuleController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Text('Module ${controller.modules.length}/25')),
              ElevatedButton.icon(
                onPressed: () async {
                  await Get.toNamed(
                    AppRoute.teacherAddModuleScreen,
                    arguments: {
                      'courseId': controller.selectedCourse.value?.id,
                      'courseTitle': controller.selectedCourse.value?.title,
                    },
                  );
                  await controller.refreshModules();
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Module'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  textStyle: getTextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoadingModules.value &&
                controller.modules.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.modules.isEmpty) {
              return Center(
                child: Text(
                  'No modules found for this course',
                  style: getTextStyle(fontSize: 15, color: Colors.grey[600]!),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.refreshModules,
              child: ListView(
                children: controller.modules
                    .map(
                      (module) =>
                          ModuleCard(module: module, controller: controller),
                    )
                    .toList(),
              ),
            );
          }),
        ),
      ],
    );
  }
}
