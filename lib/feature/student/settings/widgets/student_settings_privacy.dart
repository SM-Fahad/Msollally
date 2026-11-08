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

  Widget _buildPrivacyOption(String title, RxString selectedValue) {
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
              color: Colors.grey.shade600,
            ),
          ),
          Obx(
            () => Container(
              padding: EdgeInsets.symmetric(horizontal: 8.width, vertical: 4.height),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4.radius),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isDense: true,
                  value: selectedValue.value,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    size: 24,
                    color: Colors.grey.shade600,
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
                          color: Colors.grey.shade600,
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
              "Privacy",
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
            child: Obx(() {
              if (controller.isLoadingPrivacy.value) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.height),
                  child: Center(
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
                    "Profile Visibility",
                    controller.profileVisibility,
                  ),
                  SizedBox(height: 16.height),
                  _buildPrivacyOption("See Plan", controller.seePlan),
                  SizedBox(height: 16.height),
                  _buildPrivacyOption("Send Request", controller.sendRequest),
                  SizedBox(height: 16.height),
                  _buildPrivacyOption("See Class", controller.seeClass),
                  SizedBox(height: 16.height),
                  _buildPrivacyOption("Can Message", controller.canMessage),
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
