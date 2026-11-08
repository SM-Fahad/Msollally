import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../create_campaign/controller/create_campaign_controller.dart';
import 'create_campaign_shared_widgets.dart';

class BudgetTabWidget extends StatelessWidget {
  const BudgetTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateCampaignController>();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 28.h),
      child: Column(
        children: [
          CampaignSectionCard(
            title: 'Budget & Schedule',
            description: 'Set budget and dates.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => _budgetField(
                    errorText: controller.budgetError,
                    textController: controller.budgetController,
                  ),
                ),
                SizedBox(height: 18.h),
                Obx(
                  () => _dateField(
                    context: context,
                    label: 'Start Date',
                    value: controller.startDate.value,
                    errorText: controller.startDateError,
                    onPicked: controller.setStartDate,
                  ),
                ),
                SizedBox(height: 16.h),
                Obx(
                  () => _dateField(
                    context: context,
                    label: 'End Date',
                    value: controller.endDate.value,
                    errorText: controller.endDateError,
                    onPicked: controller.setEndDate,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          CampaignFooterActions(
            primaryText: 'Review',
            primaryAction: () {
              final isValid = controller.validateRequiredFields(
                showMessage: true,
              );
              if (isValid) {
                DefaultTabController.of(context).animateTo(3);
              }
            },
            secondaryText: 'Back',
            secondaryAction: () =>
                DefaultTabController.of(context).animateTo(1),
          ),
        ],
      ),
    );
  }

  Widget _budgetField({
    required TextEditingController textController,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CampaignFieldLabel(
          label: 'Total Budget',
          required: false,
          tag: 'Optional',
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: textController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(fontSize: 15.sp, color: AppColors.black0F172A),
          decoration: campaignInputDecoration(
            hintText: 'Enter budget amount',
            errorText: errorText,
            suffixIcon: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                'TZS',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slateGray64748B,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dateField({
    required BuildContext context,
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime> onPicked,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CampaignFieldLabel(label: label, required: true),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) onPicked(picked);
          },
          child: AbsorbPointer(
            child: TextFormField(
              decoration: campaignInputDecoration(
                hintText: value == null
                    ? 'mm/dd/yyyy'
                    : DateFormat('MM/dd/yyyy').format(value),
                errorText: errorText,
                suffixIcon: const Icon(Icons.calendar_today_outlined),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
