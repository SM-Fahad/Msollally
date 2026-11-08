import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/const/icons_path.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/auth/service/auth_service.dart';
import 'package:msollaally/feature/student/more/model/student_more_health_wellness_model.dart';
import 'package:msollaally/feature/student/more/model/student_more_settings_privacy_model.dart';
import 'package:msollaally/feature/student/more/model/student_more_tools_model.dart';
import 'package:msollaally/routes/app_route.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/student_campus_fursa_zone/fursa_zone_screen/student_campus_fursa_zone.dart';

class StudentMoreController extends GetxController {
  var toolsList = <StudentMoreToolsModel>[].obs;
  var healthAndWellnessList = <StudentMoreHealthWellnessModel>[].obs;
  var settingAndPrivacy = <StudentMoreSettingsPrivacyModel>[].obs;
  var extraList = <StudentMoreToolsModel>[].obs;

  @override
  void onInit() {
    super.onInit();

    extraList.addAll([
      StudentMoreToolsModel(
        icon: Image.asset(IconsPath.forsaicon, height: 20, width: 20),
        title: "Fursa Zone",
        ontap: () => Get.to(() => const StudentCampusFursaZone()),
      ),

      StudentMoreToolsModel(
        icon: Image.asset(IconsPath.referralprograme, height: 20, width: 20),
        title: "Referral Program",
        ontap: () => Get.toNamed(AppRoute.referralScreen),
      ),
    ]);

    toolsList.addAll([
      StudentMoreToolsModel(
        icon: Image.asset(
          "assets/icons/calender.png",
          height: 24.height,
          width: 24.height,
        ),
        title: "Calendar",
        ontap: () {
          Get.toNamed(AppRoute.studentCalenderPage);
        },
      ),
      StudentMoreToolsModel(
        icon: Image.asset(
          "assets/icons/fileConvert.png",
          height: 24.height,
          width: 24.height,
        ),
        title: "Convert",
        ontap: () {
          Get.toNamed(AppRoute.studentFileConverterPage);
        },
      ),
      StudentMoreToolsModel(
        icon: Image.asset(
          "assets/icons/ai.png",
          height: 24.height,
          width: 24.height,
        ),
        title: "AI Chat",
        ontap: () {
          Get.toNamed(AppRoute.studentAIChatpage);
        },
      ),
      StudentMoreToolsModel(
        icon: Image.asset(
          "assets/icons/check.png",
          height: 24.height,
          width: 24.height,
        ),
        title: "To Do",
        ontap: () {
          Get.toNamed(AppRoute.studentAllTaskList);
        },
      ),
    ]);

    // add health and wellness List
    healthAndWellnessList.addAll([
      StudentMoreHealthWellnessModel(
        ontap: () {
          Get.toNamed(AppRoute.studentWellnessScreen);
        },
        title: "Emergency Support",
        subTitle: "Quick access to emergency services.",
        buttonText: "Contact",
        bgColor: AppColors.lavenderF3E8FF,
        borderColor: AppColors.mediumPurpleA855F7,
      ),
      StudentMoreHealthWellnessModel(
        ontap: () {
          Get.toNamed(AppRoute.studentHealthScreen, arguments: {'type': 'mental_health'});
        },
        title: "Mental Health",
        subTitle: "Access stress management tools, meditation guides, resources.",
        buttonText: "Access Resource",
        bgColor: AppColors.seaShellFFF7ED,
        borderColor: AppColors.darkOrangeF97316,
      ),
      StudentMoreHealthWellnessModel(
        ontap: () {
          Get.toNamed(AppRoute.studentHealthScreen, arguments: {'type': 'physical_health'});
        },
        title: "Physical Health",
        subTitle: "Explore workout guides and nutritional tips.",
        buttonText: "Explore",
        bgColor: AppColors.lavenderBlushFEF2F2,
        borderColor: AppColors.tomatoEF4444,
      ),
    ]);

    //add student more settings and privacy list

    settingAndPrivacy.addAll([
      StudentMoreSettingsPrivacyModel(
        icon: Icon(Icons.settings, size: 24, color: AppColors.black1F1F1F),
        title: "Settings",
        ontap: () {
          Get.toNamed(AppRoute.studentSettings);
        },
      ),

      StudentMoreSettingsPrivacyModel(
        icon: Icon(Icons.feedback, size: 24, color: AppColors.black1F1F1F),
        title: "Send Feedback",
        ontap: () {
          Get.toNamed(AppRoute.feedbackScreen);
        },
      ),
      StudentMoreSettingsPrivacyModel(
        icon: Icon(Icons.info, size: 24, color: AppColors.black1F1F1F),
        title: "About LinkYetu",
        ontap: () {
          Get.toNamed(
            AppRoute.termsAndPrivacyScreen,
            arguments: {'type': 'about', 'title': 'About LinkYetu'},
          );
        },
      ),
      StudentMoreSettingsPrivacyModel(
        icon: Icon(Icons.description, size: 24, color: AppColors.black1F1F1F),
        title: "Terms & Conditions",
        ontap: () {
          Get.toNamed(
            AppRoute.termsAndPrivacyScreen,
            arguments: {'type': 'terms', 'title': 'Terms & Conditions'},
          );
        },
      ),
      StudentMoreSettingsPrivacyModel(
        icon: Icon(Icons.privacy_tip, size: 24, color: AppColors.black1F1F1F),
        title: "Privacy Policy",
        ontap: () {
          Get.toNamed(
            AppRoute.termsAndPrivacyScreen,
            arguments: {'type': 'privacy', 'title': 'Privacy Policy'},
          );
        },
      ),
      StudentMoreSettingsPrivacyModel(
        icon: Icon(Icons.logout, size: 24, color: AppColors.black1F1F1F),
        title: "Logout",
        ontap: () => _showLogoutDialog(),
      ),
    ]);
  }

  final RxBool isLoggingOut = false.obs;

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Logout', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          Obx(
            () => TextButton(
              onPressed: isLoggingOut.value ? null : () => _logout(),
              child: isLoggingOut.value
                  ? SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _logout() async {
    try {
      isLoggingOut.value = true;

      await AuthService.logout();

      // Remove access token after successful logout
      final prefHelper = SharedPreferenceHelper();
      await prefHelper.clearTokens();

      Get.back();

      Get.offAllNamed(AppRoute.loginScreen);

      debugPrint('LOGOUT: Tokens cleared and navigated to login screen');
    } catch (e) {
      // Clear tokens even if logout fails (e.g., 401 error)
      final prefHelper = SharedPreferenceHelper();
      await prefHelper.clearTokens();

      Get.back();

      debugPrint('LOGOUT Exception: $e - Tokens cleared locally');

      Get.offAllNamed(AppRoute.loginScreen);
    } finally {
      isLoggingOut.value = false;
    }
  }
}
