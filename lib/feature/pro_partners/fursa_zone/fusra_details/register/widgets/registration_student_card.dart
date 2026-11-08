import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

import '../../details/controller/fusra_details_controller.dart';
import 'registration_info_section.dart';

class RegistrationStudentCard extends StatelessWidget {
  const RegistrationStudentCard({
    super.key,
    required this.student,
    required this.controller,
    required this.isAcademicExpanded,
    required this.isContactExpanded,
    required this.isAddressExpanded,
    required this.isBankExpanded,
    required this.onAcademicTap,
    required this.onContactTap,
    required this.onAddressTap,
    required this.onBankTap,
  });

  final RegistrationStudent student;
  final FusraDetailsController controller;
  final bool isAcademicExpanded;
  final bool isContactExpanded;
  final bool isAddressExpanded;
  final bool isBankExpanded;
  final VoidCallback onAcademicTap;
  final VoidCallback onContactTap;
  final VoidCallback onAddressTap;
  final VoidCallback onBankTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lavenderE7ECF3),
        boxShadow: const [
          BoxShadow(
            color: AppColors.blackAlpha120F172A,
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: student.positionColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  student.position == 'N/A'
                      ? 'Unranked'
                      : 'Rank #${student.position}',
                  style: getTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: student.positionTextColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: getTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Student ID: ${student.id}',
                      style: getTextStyle(
                        fontSize: 14,
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetaChip(
                          icon: Icons.verified_outlined,
                          label: 'Qualification ${student.qualificationStatus}',
                        ),
                        _MetaChip(
                          icon: Icons.star_border_rounded,
                          label: 'Score ${student.qualificationScore}',
                        ),
                        _MetaChip(
                          icon: Icons.refresh_rounded,
                          label: 'Attempts ${student.attempts}',
                        ),
                        // _MetaChip(
                        //   icon: Icons.monetization_on_outlined,
                        //   label: 'Coins ${student.coins}',
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(
            () => RegistrationInfoSection(
              title: student.academic.title,
              backgroundColor: student.academic.backgroundColor,
              expanded: controller.expandedRegistrationSections.contains(
                '${student.uniqueId}-academic',
              ),
              fields: student.academic.fields,
              onTap: onAcademicTap,
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => RegistrationInfoSection(
              title: student.contact.title,
              backgroundColor: student.contact.backgroundColor,
              expanded: controller.expandedRegistrationSections.contains(
                '${student.uniqueId}-contact',
              ),
              fields: student.contact.fields,
              onTap: onContactTap,
            ),
          ),

          /// Do not delete those comment
          // const SizedBox(height: 8),
          // RegistrationInfoSection(
          //   title: student.address.title,
          //   backgroundColor: student.address.backgroundColor,
          //   expanded: isAddressExpanded,
          //   fields: student.address.fields,
          //   onTap: onAddressTap,
          // ),
          // const SizedBox(height: 8),
          // RegistrationInfoSection(
          //   title: student.bank.title,
          //   backgroundColor: student.bank.backgroundColor,
          //   expanded: isBankExpanded,
          //   onTap: onBankTap,
          //   accountNumber: student.bank.accountNumber,
          //   badgeText: student.bank.badgeText,
          // ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.panelBackgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.lavenderE2E8F0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.darkSlateGray475569),
          const SizedBox(width: 6),
          Text(
            label,
            style: getTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.darkSlateGray334155,
            ),
          ),
        ],
      ),
    );
  }
}
