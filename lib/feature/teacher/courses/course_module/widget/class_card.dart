import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/const/icons_path.dart';
import 'package:msollaally/feature/teacher/courses/course_module/controller/course_module_controller.dart';
import 'package:msollaally/feature/teacher/courses/course_module/model/course_module_model.dart';
import 'package:msollaally/feature/teacher/widgets/get_random_color.dart';
import 'package:msollaally/routes/app_route.dart';

class ClassCard extends StatelessWidget {
  const ClassCard({
    super.key,
    required this.courseClass,
    required this.module,
    required this.controller,
  });

  final CourseClass courseClass;
  final CourseModule module;
  final CourseModuleController controller;

  @override
  Widget build(BuildContext context) {
    final cardColor = getRandomColor();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: cardColor.withAlpha(50), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  courseClass.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  courseClass.time,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  courseClass.hall,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Get.toNamed(
                AppRoute.editModuleClassScreen,
                arguments: {'module': module, 'class': courseClass},
              );
            },
            child: ImageIcon(
              const AssetImage(IconsPath.editIconTeacherFlow),
              size: 24,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => controller.confirmDeleteClass(courseClass),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Delete class',
          ),
        ],
      ),
    );
  }
}
