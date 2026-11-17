import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/student/settings/controller/student_settings_controller.dart';
import '../../../../core/common/styles/global_text_style.dart';

class StudentSettingsPrivacy extends StatelessWidget {
  final StudentSettingsController controller;

  const StudentSettingsPrivacy({super.key, required this.controller});

  String _formatOption(String option) {
    if (option == 'only_me') return 'Only Me';
    if (option == 'friend') return 'Friends';
    return option.capitalizeFirst ?? option;
  }

  Widget _buildPrivacyOption(
    BuildContext context,
    String title,
    RxString selectedValue,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark
        ? Colors.white.withValues(alpha: 0.85)
        : Colors.grey.shade600;
    final boxBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.grey.shade300;
    final boxBgColor = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.transparent;

    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: appTextStyleHeading1(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2.fontSize,
              color: labelColor,
            ),
          ),
          Obx(
            () => Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.width,
                vertical: 4.height,
              ),
              decoration: BoxDecoration(
                color: boxBgColor,
                border: Border.all(color: boxBorderColor),
                borderRadius: BorderRadius.circular(4.radius),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isDense: true,
                  dropdownColor: isDark
                      ? const Color(0xFF1E1E24)
                      : Colors.white,
                  value: selectedValue.value,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    size: 24,
                    color: labelColor,
                  ),
                  items: controller.privacyOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        _formatOption(value),
                        style: appTextStyleHeading1(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2.fontSize,
                          color: labelColor,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      selectedValue.value = newValue;
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg = isDark ? const Color(0xFF18181B) : Colors.grey[50];
    final bodyBg = isDark ? const Color(0xFF121215) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.grey.shade300;
    final titleColor = isDark ? Colors.white : AppColors.black1F1F1F;

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
              "Privacy",
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
            child: Obx(() {
              if (controller.isLoadingPrivacy.value) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.height),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryButtonColor,
                    ),
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPrivacyOption(
                    context,
                    "Profile Visibility",
                    controller.profileVisibility,
                  ),
                  SizedBox(height: 16.height),
                  _buildPrivacyOption(context, "See Plan", controller.seePlan),
                  SizedBox(height: 16.height),
                  _buildPrivacyOption(
                    context,
                    "Send Request",
                    controller.sendRequest,
                  ),
                  SizedBox(height: 16.height),
                  _buildPrivacyOption(
                    context,
                    "See Class",
                    controller.seeClass,
                  ),
                  SizedBox(height: 16.height),
                  _buildPrivacyOption(
                    context,
                    "Can Message",
                    controller.canMessage,
                  ),
                  SizedBox(height: 24.height),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryButtonColor,
                        padding: EdgeInsets.symmetric(vertical: 12.height),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.radius),
                        ),
                      ),
                      onPressed: controller.isUpdatingPrivacy.value
                          ? null
                          : () => controller.updatePrivacySettings(),
                      child: controller.isUpdatingPrivacy.value
                          ? SizedBox(
                              height: 20.height,
                              width: 20.height,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Save Privacy Settings",
                              style: appTextStyleHeading1(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
