import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/routes/app_route.dart';

import '../../../../core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import '../controller/student_settings_controller.dart';

class SudentSettingsAccount extends StatelessWidget {
  const SudentSettingsAccount({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg = isDark ? const Color(0xFF18181B) : Colors.grey[50];
    final bodyBg = isDark ? const Color(0xFF121215) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.grey.shade300;
    final titleColor = isDark ? Colors.white : AppColors.black1F1F1F;
    final itemColor = isDark
        ? Colors.white.withValues(alpha: 0.85)
        : Colors.grey.shade600;

    return SizedBox(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 12.width,
              vertical: 12.height,
            ),
            decoration: BoxDecoration(
              color: headerBg,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.radius),
                topRight: Radius.circular(8.radius),
              ),
            ),
            child: Text(
              "Account",
              style: appTextStyleHeading1(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2.fontSize,
                color: titleColor,
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12.width,
              vertical: 12.height,
            ),
            width: double.infinity,
            decoration: BoxDecoration(
              color: bodyBg,
              border: Border(
                left: BorderSide(color: borderColor),
                right: BorderSide(color: borderColor),
                bottom: BorderSide(color: borderColor),
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.radius),
                bottomRight: Radius.circular(8.radius),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Get.toNamed(AppRoute.studentSettingsEditProfileScreen);
                  },
                  child: SizedBox(
                    child: Row(
                      children: [
                        Icon(
                          Icons.personal_injury_outlined,
                          size: 24,
                          color: itemColor,
                        ),
                        SizedBox(width: 8.width),
                        Text(
                          "Edit Profile",
                          style: appTextStyleHeading1(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2.fontSize,
                            color: itemColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.height),
                InkWell(
                  onTap: () => _showChangePasswordBottomSheet(context),
                  child: SizedBox(
                    child: Row(
                      children: [
                        Icon(Icons.key_rounded, size: 24, color: itemColor),
                        SizedBox(width: 8.width),
                        Text(
                          "Change Password",
                          style: appTextStyleHeading1(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2.fontSize,
                            color: itemColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.height),
                InkWell(
                  onTap: () => _showDeleteAccountDialog(context),
                  child: SizedBox(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_outline,
                          size: 24,
                          color: AppColors.uiDangerColor,
                        ),
                        SizedBox(width: 8.width),
                        Text(
                          "Delete Account",
                          style: appTextStyleHeading1(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2.fontSize,
                            color: AppColors.uiDangerColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<StudentSettingsController>();
    controller.currentPasswordController.clear();
    controller.newPasswordController.clear();

    Get.bottomSheet(
      SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            left: 20.width,
            right: 20.width,
            top: 24.height,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.height,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF18181B) : Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20.radius),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Change Password",
                style: appTextStyleHeading1(
                  fontSize: 18.fontSize,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.black1F1F1F,
                ),
              ),
              SizedBox(height: 24.height),
              TextField(
                controller: controller.currentPasswordController,
                obscureText: true,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: "Current Password",
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey.shade600,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.radius),
                  ),
                ),
              ),
              SizedBox(height: 16.height),
              TextField(
                controller: controller.newPasswordController,
                obscureText: true,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: "New Password",
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey.shade600,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.radius),
                  ),
                ),
              ),
              SizedBox(height: 24.height),
              SizedBox(
                width: double.infinity,
                height: 48.height,
                child: ElevatedButton(
                  onPressed: () => controller.changePassword(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButtonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.radius),
                    ),
                  ),
                  child: Text(
                    "Update Password",
                    style: getTextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.height),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<StudentSettingsController>();
    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? const Color(0xFF18181B) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.radius),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 28.radius,
            ),
            SizedBox(width: 8.width),
            Text(
              "Delete Account",
              style: appTextStyleHeading1(
                fontWeight: FontWeight.bold,
                fontSize: 18.fontSize,
                color: isDark ? Colors.white : AppColors.black1F1F1F,
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to completely delete your account? This action cannot be undone.",
          style: getTextStyle(
            color: isDark ? Colors.white70 : Colors.grey.shade700,
            fontSize: 14.fontSize,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Cancel",
              style: getTextStyle(
                color: isDark ? Colors.white70 : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.radius),
              ),
            ),
            child: Text(
              "Delete",
              style: getTextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
