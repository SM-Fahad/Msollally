import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/icons_path.dart';
import 'package:msollaally/feature/teacher/students/controller/teacher_student_controller.dart';
import 'package:msollaally/feature/teacher/students/widget/user_tile.dart';
import 'package:msollaally/feature/teacher/widgets/default_teacher_app_bar.dart';
import 'package:msollaally/routes/app_route.dart';

class TeacherStudentsScreen extends StatelessWidget {
  TeacherStudentsScreen({super.key});

  final TeacherStudentController controller = Get.put(
    TeacherStudentController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultTeacherAppBar(isHomePage: false, title: 'Students'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Group Name",
              style: getTextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.blue.withValues(alpha: 0.08),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Group name (optional)",
                  hintStyle: getTextStyle(color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
                onChanged: (val) => controller.groupName.value = val,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              decoration: InputDecoration(
                hintText: "Search",
                hintStyle: getTextStyle(color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                prefixIcon: const ImageIcon(AssetImage(IconsPath.searchIcon)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (val) => controller.searchQuery.value = val,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.students.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.errorMessage.value.isNotEmpty &&
                    controller.students.isEmpty) {
                  return _TeacherStudentsStatusView(
                    message: controller.errorMessage.value,
                    actionLabel: 'Retry',
                    onAction: controller.fetchStudents,
                  );
                }

                final filteredUsers = controller.filteredUsers;
                if (filteredUsers.isEmpty) {
                  return _TeacherStudentsStatusView(
                    message: controller.searchQuery.value.trim().isEmpty
                        ? 'No students found.'
                        : 'No students match your search.',
                    actionLabel: 'Refresh',
                    onAction: controller.fetchStudents,
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchStudents,
                  child: ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return UserTile(
                        user: user,
                        onTap: () => controller.toggleSelection(user),
                        onProfileTap: () => Get.toNamed(
                          AppRoute.studentCampusPublicProfile,
                          arguments: user.studentId,
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeacherStudentsStatusView extends StatelessWidget {
  const _TeacherStudentsStatusView({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: getTextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
