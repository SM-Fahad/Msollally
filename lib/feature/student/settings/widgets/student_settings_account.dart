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
    return SizedBox(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 12.height),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey.shade300),
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
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 12.height),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey.shade300),
                right: BorderSide(color: Colors.grey.shade300),
                bottom: BorderSide(color: Colors.grey.shade300),
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
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 8.width),
                        Text(
                          "Edit Profile",
                          style: appTextStyleHeading1(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2.fontSize,
                            color: Colors.grey.shade600,
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
                        Icon(
                          Icons.key_rounded,
                          size: 24,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 8.width),
                        Text(
                          "Change Password",
                          style: appTextStyleHeading1(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2.fontSize,
                            color: Colors.grey.shade600,
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
                        Icon(
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
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.radius)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Change Password", style: appTextStyleHeading1(fontSize: 18.fontSize, fontWeight: FontWeight.bold)),
              SizedBox(height: 24.height),
              TextField(
                controller: controller.currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Current Password",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.radius)),
                ),
              ),
              SizedBox(height: 16.height),
              TextField(
                controller: controller.newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "New Password",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.radius)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.radius)),
                  ),
                  child: Text("Update Password", style: getTextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    final controller = Get.find<StudentSettingsController>();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.radius)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28.radius),
            SizedBox(width: 8.width),
            Text("Delete Account", style: appTextStyleHeading1(fontWeight: FontWeight.bold, fontSize: 18.fontSize)),
          ],
        ),
        content: Text(
          "Are you sure you want to completely delete your account? This action cannot be undone.",
          style: getTextStyle(color: Colors.grey.shade700, fontSize: 14.fontSize),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: getTextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.radius)),
            ),
            child: Text("Delete", style: getTextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
