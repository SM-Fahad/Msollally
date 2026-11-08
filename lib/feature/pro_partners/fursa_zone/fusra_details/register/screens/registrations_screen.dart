import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

import '../../details/controller/fusra_details_controller.dart';
import '../../register/widgets/export_button.dart';
import '../../register/widgets/registration_student_card.dart';
import '../../register/widgets/registration_summary_card.dart';

class RegistrationsScreen extends GetView<FusraDetailsController> {
  const RegistrationsScreen({super.key});

  static const _headerItemsCount = 4;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasError =
          controller.registrationsError.value.isNotEmpty &&
          controller.registeredStudents.isEmpty;
      final showInitialLoader =
          controller.isRegistrationsLoading.value &&
          controller.registeredStudents.isEmpty;
      final showEmptyState =
          !controller.isRegistrationsLoading.value &&
          controller.registeredStudents.isEmpty &&
          !hasError;
      final itemCount =
          _headerItemsCount +
          controller.registeredStudents.length +
          (controller.isLoadingMore.value ? 1 : 0);

      return ListView.builder(
        controller: controller.registrationsScrollController,
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 28),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: RegistrationSummaryCard(
                title: 'Registration Leaderboard',
                totalRegistrations: controller.totalRegistration.value,
              ),
            );
          }

          if (index == 1) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SearchBar(controller: controller),
            );
          }

          if (index == 2) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: ExportButton(
                      text: 'Export CSV',
                      onTap: controller.exportRegistrationsCsv,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ExportButton(
                      text: 'Export Excel',
                      onTap: controller.exportRegistrationsExcel,
                    ),
                  ),
                ],
              ),
            );
          }

          if (index == 3) {
            if (showInitialLoader) {
              return const _CenteredState(child: CircularProgressIndicator());
            }

            if (hasError) {
              return _MessageCard(
                icon: Icons.cloud_off_rounded,
                title: 'Unable to load registrations',
                subtitle: controller.registrationsError.value,
                actionLabel: 'Try Again',
                onTap: () => controller.fetchRegistrations(
                  search: controller.registrationSearchQuery.value,
                ),
              );
            }

            if (showEmptyState) {
              return _MessageCard(
                icon: Icons.search_off_rounded,
                title: 'No registrations found',
                subtitle:
                    'Try refining the search or check again after new students register.',
              );
            }

            return const SizedBox.shrink();
          }

          final dataIndex = index - _headerItemsCount;
          if (dataIndex >= controller.registeredStudents.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final student = controller.registeredStudents[dataIndex];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: RegistrationStudentCard(
              student: student,
              controller: controller,
              isAcademicExpanded: controller.isSectionExpanded(
                student.uniqueId,
                'academic',
              ),
              isContactExpanded: controller.isSectionExpanded(
                student.uniqueId,
                'contact',
              ),
              isAddressExpanded: controller.isSectionExpanded(
                student.uniqueId,
                'address',
              ),
              isBankExpanded: controller.isSectionExpanded(
                student.uniqueId,
                'bank',
              ),
              onAcademicTap: () =>
                  controller.toggleSection(student.uniqueId, 'academic'),
              onContactTap: () =>
                  controller.toggleSection(student.uniqueId, 'contact'),
              onAddressTap: () =>
                  controller.toggleSection(student.uniqueId, 'address'),
              onBankTap: () =>
                  controller.toggleSection(student.uniqueId, 'bank'),
            ),
          );
        },
      );
    });
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});

  final FusraDetailsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.panelBackgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lavenderE2E8F0),
      ),
      child: TextField(
        controller: controller.registrationsSearchController,
        onChanged: controller.onRegistrationSearchChanged,

        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          icon: Icon(Icons.search_rounded, color: AppColors.slateGray64748B),
          hintText: controller.searchHint,
          hintStyle: TextStyle(color: AppColors.darkGray94A3B8),
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.lavenderE2E8F0),
      ),
      child: Column(
        children: [
          Icon(icon, size: 34, color: AppColors.slateGray64748B),
          const SizedBox(height: 12),
          Text(
            title,
            style: getTextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: getTextStyle(fontSize: 14, color: AppColors.slateGray64748B),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onTap != null) ...[
            const SizedBox(height: 14),
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.black0F172A,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  actionLabel!,
                  style: getTextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Center(child: child),
    );
  }
}
