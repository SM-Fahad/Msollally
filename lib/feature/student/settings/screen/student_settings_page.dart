import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/notification/widgets/custom_app_bar.dart';
import 'package:msollaally/feature/student/settings/controller/student_settings_controller.dart'
    show StudentSettingsController;

import '../widgets/student_settings_account.dart';
import '../widgets/student_settings_privacy.dart';
import '../widgets/student_settings_subscription.dart';
import '../widgets/student_settings_device_sessions.dart';
import '../../../shared/notification_settings/widgets/shared_notification_settings.dart';

class StudentSettingsPage extends StatelessWidget {
  const StudentSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    var controller = Get.put(StudentSettingsController());
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF09090B) : Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsGeometry.only(top: 38.height),

              child: CustomAppBar(
                leadingIcon: Icon(
                  Icons.arrow_back,
                  size: 24,
                  color: isDark ? Colors.white : const Color(0xFF3F3F3F),
                ),
                onLeadingTap: () {
                  Get.back();
                },
                title: "Settings",
              ),
            ),

            Padding(
              padding: EdgeInsetsGeometry.symmetric(
                vertical: 16.height,
                horizontal: 20.width,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SudentSettingsAccount(),
                  SizedBox(height: 24.height),
                  StudentSettingsPrivacy(controller: controller),
                  SizedBox(height: 24.height),
                  StudentSettingsDeviceSessions(controller: controller),
                  SizedBox(height: 24.height),
                  const SharedNotificationSettings(),
                  SizedBox(height: 24.height),

                  StudentSettingsSubscription(controller: controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
