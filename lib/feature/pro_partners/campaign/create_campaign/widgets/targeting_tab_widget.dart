import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../create_campaign/controller/create_campaign_controller.dart';
import 'create_campaign_shared_widgets.dart';

class TargetingTabWidget extends StatelessWidget {
  const TargetingTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateCampaignController>();
    final genders = const ['Any', 'Female', 'Male'];
    final majors = controller.majorLabelToValue.keys.toList();
    const years = ['All Years', '1', '2', '3', '4', '5', '6', '7'];

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 28.h),
      child: Column(
        children: [
          CampaignSectionCard(
            title: 'Audience Filters',
            description: 'Target specific students.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => _multiSelectDropdown(
                    label: 'University',
                    hint: 'Add a university',
                    options: controller.universities.toList(),
                    selectedItems: controller.selectedUniversities,
                    onChanged: (v) {
                      if (v != null) controller.addUniversity(v);
                    },
                    onRemove: controller.removeUniversity,
                    errorText: controller.universityError,
                  ),
                ),
                SizedBox(height: 16.h),
                Obx(
                  () => _dropdown(
                    label: 'Gender',
                    hint: 'Select gender',
                    selectedValue: controller.gender.value,
                    options: genders,
                    onChanged: (v) => controller.gender.value = v,
                    errorText: controller.genderError,
                  ),
                ),
                SizedBox(height: 16.h),
                Obx(
                  () => Column(
                    children: [
                      _multiSelectDropdown(
                        label: 'Major',
                        hint: 'Add a major',
                        options: majors,
                        selectedItems: controller.selectedMajors,
                        onChanged: (v) {
                          if (v != null) controller.addMajor(v);
                        },
                        onRemove: controller.removeMajor,
                        errorText: controller.majorError,
                      ),
                      if (controller.selectedMajors.contains('Other')) ...[
                        SizedBox(height: 16.h),
                        _field(
                          label: 'Other Major',
                          hint: 'Specify major',
                          textController: controller.otherMajorController,
                          required: true,
                          errorText: controller.otherMajorError,
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Obx(
                  () => _dropdown(
                    label: 'Year of Study',
                    hint: 'Select year',
                    selectedValue: controller.year.value,
                    options: years,
                    onChanged: (v) => controller.year.value = v,
                    errorText: controller.yearError,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          CampaignFooterActions(
            primaryText: 'Continue',
            primaryAction: () => DefaultTabController.of(context).animateTo(2),
            secondaryText: 'Back',
            secondaryAction: () =>
                DefaultTabController.of(context).animateTo(0),
          ),
        ],
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String hint,
    required String? selectedValue,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    String? errorText,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CampaignFieldLabel(label: label, required: true),
          SizedBox(height: 8.h),
          DropdownButtonFormField<String>(
            key: ValueKey('$label-${selectedValue ?? ''}'),
            isExpanded: true,
            initialValue: selectedValue,
            items: options
                .map(
                  (o) => DropdownMenuItem(
                    value: o,
                    child: SizedBox(
                      width: constraints.maxWidth - 56.w,
                      child: Text(
                        o,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
            style: TextStyle(fontSize: 15.sp, color: AppColors.black0F172A),
            selectedItemBuilder: (_) => options
                .map(
                  (o) => SizedBox(
                    width: constraints.maxWidth - 56.w,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        o,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: AppColors.black0F172A,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
            decoration: campaignInputDecoration(
              hintText: hint,
              errorText: errorText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _multiSelectDropdown({
    required String label,
    required String hint,
    required List<String> options,
    required List<String> selectedItems,
    required ValueChanged<String?> onChanged,
    required ValueChanged<String> onRemove,
    String? errorText,
  }) {
    final availableOptions = options
        .where((option) => !selectedItems.contains(option))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CampaignFieldLabel(label: label, required: true),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          key: UniqueKey(),
          isExpanded: true,
          initialValue: null,
          items: availableOptions
              .map(
                (o) => DropdownMenuItem<String>(
                  value: o,
                  child: Text(o, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: availableOptions.isEmpty ? null : onChanged,
          style: TextStyle(fontSize: 15.sp, color: AppColors.black0F172A),
          decoration: campaignInputDecoration(
            hintText: availableOptions.isEmpty ? 'All selected' : hint,
            errorText: errorText,
          ),
        ),
        if (selectedItems.isNotEmpty) ...[
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: selectedItems
                .map(
                  (item) => _selectedChip(
                    label: item,
                    onRemove: () => onRemove(item),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _selectedChip({
    required String label,
    required VoidCallback onRemove,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 0.72.sw),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.panelBackgroundColor,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: AppColors.lavenderE2E8F0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkSlateGray334155,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close,
                size: 16.sp,
                color: AppColors.slateGray64748B,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required String hint,
    required TextEditingController textController,
    bool required = false,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CampaignFieldLabel(label: label, required: required),
        SizedBox(height: 8.h),
        TextFormField(
          controller: textController,
          style: TextStyle(fontSize: 15.sp, color: AppColors.black0F172A),
          decoration: campaignInputDecoration(
            hintText: hint,
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}
