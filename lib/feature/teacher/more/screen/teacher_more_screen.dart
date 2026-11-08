import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/common/widgets/more_heading_profile.dart';
import 'package:msollaally/core/common/widgets/more_option_tile.dart';
import 'package:msollaally/feature/teacher/more/controller/more_controller.dart';
import 'package:msollaally/feature/teacher/more/settings/screen/teacher_settings_screen.dart';
import 'package:msollaally/feature/teacher/profile/controller/teacher_profile_controller.dart';
import 'package:msollaally/routes/app_route.dart';
import '../../widgets/default_teacher_app_bar.dart';

class TeacherMoreScreen extends StatelessWidget {
  TeacherMoreScreen({super.key});

  final MoreController controller = Get.put(MoreController());
  final TeacherProfileController profileController =
      Get.isRegistered<TeacherProfileController>()
      ? Get.find<TeacherProfileController>()
      : Get.put(TeacherProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultTeacherAppBar(isHomePage: false, title: 'More'),
      body: RefreshIndicator(
        onRefresh: profileController.fetchMe,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Obx(
                () => Center(
                  child: MoreHeadingProfile(
                    name: profileController.displayName,
                    photoUrl: profileController.profileImageUrl,
                    onTap: () => Get.toNamed(AppRoute.teacherProfileScreen),
                  ),
                ),
              ),
              // MorePremiumCard(onTapUpgrade: () {}),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                child: Text(
                  "Profile & Settings",
                  style: getTextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Obx(
                () => Column(
                  children: controller.options
                      .map(
                        (option) => MoreOptionTile(
                          title: option.title,
                          onTap: () {
                            if (option.title == 'Logout') {
                              _showLogoutDialog();
                              return;
                            }
                            if (option.title == 'Settings') {
                              Get.to(() => TeacherSettingsScreen());
                              return;
                            }
                            if (option.title == 'Session') {
                              Get.toNamed(AppRoute.teacherSessionScreen);
                              return;
                            }
                            if (option.title == 'Edit Profile') {
                              Get.toNamed(AppRoute.teacherProfileScreen);
                              return;
                            }
                            if (option.title == 'Help & Support') {
                              Get.toNamed(AppRoute.proPartnersHelpSupport);
                              return;
                            }
                            if (option.title == 'About LinkYetu') {
                              Get.toNamed(AppRoute.termsAndPrivacyScreen, arguments: {'type': 'about', 'title': 'About LinkYetu'});
                              return;
                            }
                            if (option.title == 'Send Feedback') {
                              Get.toNamed(AppRoute.feedbackScreen);
                              return;
                            }
                            if (option.title == 'Terms & Conditions') {
                              Get.toNamed(AppRoute.termsAndPrivacyScreen, arguments: {'type': 'terms', 'title': 'Terms & Conditions'});
                              return;
                            }
                            if (option.title == 'Privacy Policy') {
                              Get.toNamed(AppRoute.termsAndPrivacyScreen, arguments: {'type': 'privacy', 'title': 'Privacy Policy'});
                              return;
                            }
                            debugPrint("Clicked ${option.title}");
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          Obx(
            () => TextButton(
              onPressed: controller.isLoggingOut.value
                  ? null
                  : controller.logout,
              child: controller.isLoggingOut.value
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
