import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/teacher/profile/controller/teacher_profile_controller.dart';
import 'package:msollaally/feature/teacher/profile/widget/teacher_profile_cover_profile.dart';
import 'package:msollaally/feature/teacher/profile/widget/teacher_profile_tile.dart';
import 'package:msollaally/routes/app_route.dart';

class TeacherProfileScreen extends StatelessWidget {
  TeacherProfileScreen({super.key});

  final TeacherProfileController controller =
      Get.isRegistered<TeacherProfileController>()
      ? Get.find<TeacherProfileController>()
      : Get.put(TeacherProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile"), centerTitle: false),
      body: RefreshIndicator(
        onRefresh: controller.fetchMe,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              TeacherProfileCoverAndProfilePic(),
              Obx(
                () => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        controller.displayName,
                        style: getTextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.bio.isNotEmpty
                            ? controller.bio
                            : 'No bio added yet.',
                        style: getTextStyle(
                          color: Colors.grey[700]!,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Profile Items
                      InkWell(
                        onTap: () {
                          Get.toNamed(AppRoute.teacherEditProfileNameScreen);
                        },
                        child: TeacherProfileTile(
                          title: "Name",
                          value: controller.displayName,
                        ),
                      ),
                      TeacherProfileTile(title: "Email", value: controller.email),
                      TeacherProfileTile(
                        title: "Cell",
                        value: controller.cellPhone.isNotEmpty
                            ? controller.cellPhone
                            : controller.phone,
                      ),
                      TeacherProfileTile(
                        title: "Institution",
                        value: controller.institution,
                      ),
                      TeacherProfileTile(
                        title: "Department",
                        value: controller.department,
                      ),
                      TeacherProfileTile(
                        title: "Designation",
                        value: controller.designation,
                      ),
                      TeacherProfileTile(
                        title: "Subjects Taught",
                        value: controller.subjects,
                      ),
                      TeacherProfileTile(title: "Bio", value: controller.bio),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
