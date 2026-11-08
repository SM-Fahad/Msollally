import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import '../controller/notification_settings_controller.dart';

class SharedNotificationSettings extends StatelessWidget {
  const SharedNotificationSettings({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(NotificationSettingsController());

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lavenderE6E8EC),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.lavenderE6E8EC),
              ),
            ),
            child: const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.appBarTitleColor,
              ),
            ),
          ),
          Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _NotificationToggleRow(
                    title: 'In-App Notifications',
                    subtitle: 'Receive notifications within the app',
                    value: controller.inAppEnabled.value,
                    onChanged: (val) => controller.updatePreference(inApp: val),
                  ),
                  _NotificationToggleRow(
                    title: 'Email Notifications',
                    subtitle: 'Receive notifications via email',
                    value: controller.emailEnabled.value,
                    onChanged: (val) => controller.updatePreference(email: val),
                  ),
                  _NotificationToggleRow(
                    title: 'Push Notifications',
                    subtitle: 'Receive push notifications on your device',
                    value: controller.pushEnabled.value,
                    onChanged: (val) => controller.updatePreference(push: val),
                    isLast: true,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _NotificationToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isLast;

  const _NotificationToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.whiteSmokeF0F2F5),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.black101828,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.slateGray667085,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CupertinoSwitch(
            value: value,
            activeTrackColor: AppColors.primaryButtonColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

