import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/notification/widgets/custom_app_bar.dart';
import 'package:msollaally/feature/teacher/more/settings/controller/teacher_settings_controller.dart';
import 'package:msollaally/feature/shared/notification_settings/widgets/shared_notification_settings.dart';
import 'package:msollaally/routes/app_route.dart';

class TeacherSettingsScreen extends StatelessWidget {
  TeacherSettingsScreen({super.key});

  final TeacherSettingsController controller = Get.put(
    TeacherSettingsController(),
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
                      Obx(
                        () => _SectionCard(
                          title: 'Profile Info',
                          child:
                              controller.isLoading.value &&
                                  controller.me.value == null
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : Column(
                                  children: [
                                    _InfoRow(
                                      label: 'Name',
                                      value:
                                          controller
                                              .me
                                              .value
                                              ?.profile
                                              ?.fullName ??
                                          controller.me.value?.username,
                                    ),
                                    _InfoRow(
                                      label: 'Email',
                                      value:
                                          controller.me.value?.profile?.email,
                                    ),
                                    _InfoRow(
                                      label: 'Phone',
                                      value: controller.me.value?.phoneNumber,
                                    ),
                                    _InfoRow(
                                      label: 'Cell Phone',
                                      value: controller
                                          .me
                                          .value
                                          ?.profile
                                          ?.cellPhoneNumber,
                                    ),
                                    _InfoRow(
                                      label: 'University',
                                      value:
                                          controller
                                              .me
                                              .value
                                              ?.profile
                                              ?.university
                                              ?.fullName ??
                                          controller
                                              .me
                                              .value
                                              ?.profile
                                              ?.university
                                              ?.name,
                                    ),
                                    _InfoRow(
                                      label: 'Department',
                                      value: (controller.me.value?.profile?.department?.trim().isNotEmpty == true)
                                          ? controller.me.value!.profile!.department
                                          : (controller.me.value?.profile?.faculty?.trim().isNotEmpty == true)
                                              ? controller.me.value!.profile!.faculty
                                              : null,
                                    ),
                                    _InfoRow(
                                      label: 'Designation',
                                      value: controller
                                          .me
                                          .value
                                          ?.profile
                                          ?.designation,
                                    ),
                                    _InfoRow(
                                      label: 'Subject Taught',
                                      value: controller
                                          .me
                                          .value
                                          ?.profile
                                          ?.subjectTaught,
                                    ),
                                    _InfoRow(
                                      label: 'Membership',
                                      value: controller
                                          .me
                                          .value
                                          ?.profile
                                          ?.memberShip,
                                    ),
                                    _InfoRow(
                                      label: 'Referral Level',
                                      value: controller
                                          .me
                                          .value
                                          ?.profile
                                          ?.referalStatusLevel,
                                      isLast: true,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'Account',
                        child: Column(
                          children: [
                            _ActionTile(
                              icon: Icons.manage_accounts_outlined,
                              title: 'Edit Profile',
                              onTap: () =>
                                  Get.toNamed(AppRoute.teacherProfileScreen),
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final bool isLast;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final String displayValue = value != null && value!.trim().isNotEmpty
        ? value!.trim()
        : '--';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.whiteSmokeF0F2F5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.slateGray667085,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              displayValue,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.black101828,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
