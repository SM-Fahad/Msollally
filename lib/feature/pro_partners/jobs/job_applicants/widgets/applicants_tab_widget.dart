// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/pro_partners/jobs/job_applicants/controller/job_applicants_controller.dart';
import 'package:msollaally/feature/pro_partners/jobs/job_applicants/widgets/applicant_card_widget.dart';
import 'package:msollaally/feature/pro_partners/jobs/job_applicants/widgets/applicant_state_widgets.dart';

class ApplicantsListTab extends StatelessWidget {
  final String controllerTag;
  final int tabIndex;

  ApplicantsListTab({
    super.key,
    required this.controllerTag,
    required this.tabIndex,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JobApplicantsController>(tag: controllerTag);

    return Obx(() {
      final applicants = controller.listForIndex(tabIndex);

      if (controller.isLoadingTab.value && applicants.isEmpty) {
        return ApplicantLoadingState();
      }

      if (controller.errorMessage.value.isNotEmpty && applicants.isEmpty) {
        return ApplicantErrorState(
          message: controller.errorMessage.value,
          onRetry: controller.refreshCurrentTab,
        );
      }

      if (applicants.isEmpty) {
        return ApplicantEmptyState(
          title: controller.emptyMessageForIndex(tabIndex),
          subtitle:
              'Pull to refresh or check again after new applications arrive.',
        );
      }

      return ListView.separated(
        padding: EdgeInsets.only(bottom: 24),
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        itemCount: applicants.length,
        separatorBuilder: (_, __) => SizedBox(height: 14),
        itemBuilder: (_, index) => ApplicantCardWidget(
          applicant: applicants[index],
          controllerTag: controllerTag,
        ),
      );
    });
  }
}
