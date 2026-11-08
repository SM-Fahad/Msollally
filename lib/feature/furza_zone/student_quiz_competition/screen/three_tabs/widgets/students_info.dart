import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

// GetX Controller for managing expandable section state
class ExpandableSectionController extends GetxController {
  final RxBool isExpanded = false.obs;

  void toggleExpanded() {
    isExpanded.value = !isExpanded.value;
  }
}

class StudentInfoCard extends StatelessWidget {
  final String studentName;
  final String studentId;
  final int position;
  final String university;
  final String year;
  final String program;
  final String email;
  final String phone;
  final String region;
  final String district;
  final String ward;
  final String street;
  final String bankAccount;
  final String currency;
  final String registeredDate;

  const StudentInfoCard({
    super.key,
    required this.studentName,
    required this.studentId,
    required this.position,
    required this.university,
    required this.year,
    required this.program,
    required this.email,
    required this.phone,
    required this.region,
    required this.district,
    required this.ward,
    required this.street,
    required this.bankAccount,
    required this.currency,
    required this.registeredDate,
  });

  @override
  Widget build(BuildContext context) {
    final Color positionColor;
    switch (position) {
      case 1:
        positionColor = AppColors.goldFDC700;
        break;
      case 2:
        positionColor = AppColors.darkGray99A1AF;
        break;
      case 3:
        positionColor = AppColors.darkOrangeFF8904;
        break;
      default:
        positionColor = AppColors.darkGray99A1AF;
    }
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        studentName,
                        style: getTextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        studentId,
                        style: getTextStyle(
                          fontSize: 14,
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: positionColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'position $position',
                    style: getTextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          _ExpandableSection(
            title: 'Academic Information',
            backgroundColor: AppColors.ghostWhiteF9FAFB,
            children: [
              _InfoRow(label: 'University', value: university),
              _InfoRow(label: 'Year', value: year),
              _InfoRow(label: 'Program', value: program, isLast: true),
            ],
          ),
          SizedBox(height: 12),

          _ExpandableSection(
            title: 'Contact Information',
            backgroundColor: AppColors.aliceBlueEFF6FF,
            children: [
              _InfoRow(label: 'Email', value: email),
              _InfoRow(label: 'Phone', value: phone, isLast: true),
            ],
          ),
          SizedBox(height: 12),
          _ExpandableSection(
            title: 'Current Address',
            backgroundColor: AppColors.ghostWhiteFAF5FF,
            children: [
              _InfoRow(label: 'Region', value: region),
              _InfoRow(label: 'District', value: district),
              _InfoRow(label: 'Ward', value: ward),
              _InfoRow(label: 'Street', value: street, isLast: true),
            ],
          ),
          SizedBox(height: 12),
          _ExpandableSection(
            title: 'Bank Account',
            backgroundColor: AppColors.honeydewF0FDF4,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    bankAccount,
                    style: getTextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                  Text(
                    currency,
                    style: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                'Registered: $registeredDate',
                style: getTextStyle(fontSize: 12, color: AppColors.darkGray9CA3AF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableSection extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final List<Widget> children;

  const _ExpandableSection({
    required this.title,
    required this.backgroundColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      ExpandableSectionController(),
      tag: title, // Use title as unique tag for each section
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              controller.toggleExpanded();
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryTextColor,
                    ),
                  ),
                  Obx(
                    () => AnimatedRotation(
                      turns: controller.isExpanded.value ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.buttonColorOnboarding,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Obx(
            () => AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              ),
              crossFadeState: controller.isExpanded.value
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
              sizeCurve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: getTextStyle(fontSize: 13, color: AppColors.secondaryTextColor),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: getTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
