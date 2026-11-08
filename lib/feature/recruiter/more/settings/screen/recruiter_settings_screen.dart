import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/recruiter/more/settings/controller/recruter_settings_controller.dart';
import 'package:msollaally/feature/shared/notification_settings/widgets/shared_notification_settings.dart';
import 'package:msollaally/feature/student/notification/widgets/custom_app_bar.dart';
import 'package:msollaally/routes/app_route.dart';

class RecruiterSettingsScreen extends StatelessWidget {
  RecruiterSettingsScreen({super.key});

  final RecruiterSettingsController controller = Get.put(
    RecruiterSettingsController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leadingIcon: const Icon(
                Icons.arrow_back,
                color: AppColors.appBarTitleColor,
              ),
              onLeadingTap: () => Get.back(),
              title: 'Settings',
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _SectionCard(
                        title: 'Account',
                        child: Column(
                          children: [
                            _ActionTile(
                              icon: Icons.manage_accounts_outlined,
                              title: 'Edit Profile',
                              onTap: () =>
                                  Get.toNamed(AppRoute.recruiterProfileScreen),
                            ),
                            _ActionTile(
                              icon: Icons.key_outlined,
                              title: 'Change Password',
                              onTap: () => Get.toNamed(
                                AppRoute.recruiterChangePasswordScreen,
                              ),
                            ),
                            _ActionTile(
                              icon: Icons.delete_outline,
                              title: 'Delete Account',
                              titleColor: AppColors.tomatoEB5757,
                              onTap: controller.confirmDeleteAccount,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Privacy settings
                      Obx(
                        () => _SectionCard(
                          title: 'Privacy',
                          child: Column(
                            children: [
                              _DropdownRow(
                                title: 'Profile Visibility',
                                value: controller.profileVisibility.value,
                                items: controller.privacyOptions,
                                onChanged: (v) => controller.updatePrivacyField(
                                  field: 'profileVisibility',
                                  newValue: v,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _DropdownRow(
                                title: 'Who can see your Plan?',
                                value: controller.seePlan.value,
                                items: controller.privacyOptions,
                                onChanged: (v) => controller.updatePrivacyField(
                                  field: 'seePlan',
                                  newValue: v,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _DropdownRow(
                                title: 'Who can send Request?',
                                value: controller.sendRequest.value,
                                items: controller.privacyOptions,
                                onChanged: (v) => controller.updatePrivacyField(
                                  field: 'sendRequest',
                                  newValue: v,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _DropdownRow(
                                title: 'Who can see your Class?',
                                value: controller.seeClass.value,
                                items: controller.privacyOptions,
                                onChanged: (v) => controller.updatePrivacyField(
                                  field: 'seeClass',
                                  newValue: v,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _DropdownRow(
                                title: 'Who can Message you?',
                                value: controller.canMessage.value,
                                items: controller.privacyOptions,
                                onChanged: (v) => controller.updatePrivacyField(
                                  field: 'canMessage',
                                  newValue: v,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const SharedNotificationSettings(),
                      const SizedBox(height: 16),
                      // RecruiterSettingsDeviceSessions(controller: controller),
                      // const SizedBox(height: 16),
                      // RecruiterSettingsSubscription(controller: controller),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
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
              border: Border(bottom: BorderSide(color: AppColors.lavenderE6E8EC)),
            ),
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          Padding(padding: const EdgeInsets.all(12), child: child),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? titleColor;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: titleColor ?? AppColors.appBarTitleColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? AppColors.appBarTitleColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownRow extends StatelessWidget {
  final String title;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _DropdownRow({
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  String _privacyLabel(String apiValue) {
    switch (apiValue) {
      case 'anyone':
        return 'Anyone';
      case 'friend':
        return 'Friend';
      case 'only_me':
        return 'Only me';
      default:
        return apiValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.appBarTitleColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lightGrayD0D5DD),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(_privacyLabel(e)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}
