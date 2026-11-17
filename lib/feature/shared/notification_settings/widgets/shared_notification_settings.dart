import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import '../controller/notification_settings_controller.dart';

class SharedNotificationSettings extends StatelessWidget {
  const SharedNotificationSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF121215) : Colors.white;
    final headerBg = isDark ? const Color(0xFF18181B) : Colors.transparent;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : AppColors.lavenderE6E8EC;
    final titleColor = isDark ? Colors.white : AppColors.appBarTitleColor;

    var controller = Get.put(NotificationSettingsController());

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
        color: cardBg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: headerBg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
          ),
          Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.whiteSmokeF0F2F5;
    final titleColor = isDark ? Colors.white : AppColors.black101828;
    final subtitleColor = isDark ? Colors.white70 : AppColors.slateGray667085;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: dividerColor)),
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
                  style: TextStyle(
                    fontSize: 14,
                    color: titleColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor,
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

