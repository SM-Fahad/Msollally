// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/pro_partners/jobs/all_jobs/model/job_model.dart';
import 'package:msollaally/feature/pro_partners/jobs/create_job/controller/create_job_controller.dart';
import 'package:msollaally/feature/pro_partners/jobs/create_job/widgets/create_job_field_label.dart';
import 'package:msollaally/feature/pro_partners/jobs/create_job/widgets/create_job_input_field.dart';
import 'package:msollaally/feature/pro_partners/jobs/create_job/widgets/create_job_list_input.dart';
import 'package:msollaally/feature/pro_partners/jobs/create_job/widgets/create_job_logo_picker.dart';
import 'package:msollaally/feature/pro_partners/jobs/create_job/widgets/create_job_picker_field.dart';

class CreateJobScreen extends StatelessWidget {
  CreateJobScreen({super.key, this.job, this.isEdit = false});

  final JobModel? job;
  final bool isEdit;

  @override
  Widget build(BuildContext context) {
    final tag = 'create-job-${isEdit ? job?.id ?? 'edit' : 'new'}';
    final controller = Get.isRegistered<CreateJobController>(tag: tag)
        ? Get.find<CreateJobController>(tag: tag)
        : Get.put(
            CreateJobController(job: job, isEdit: isEdit),
            tag: tag,
          );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.appBarTitleColor),
          onPressed: Get.back,
        ),
        title: Text(
          controller.screenTitle,
          style: TextStyle(color: AppColors.appBarTitleColor),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionCard(
                children: [
                  _FieldGroup(
                    label: 'Title',
                    isRequired: true,
                    child: CreateJobInputField(
                      controller: controller.titleController,
                      hint: 'Enter job title',
                    ),
                  ),
                  _FieldGroup(
                    label: 'Company Name',
                    isRequired: true,
                    child: CreateJobInputField(
                      controller: controller.companyNameController,
                      hint: 'Enter company name',
                    ),
                  ),
                  _FieldGroup(
                    label: 'Company Logo',
                    child: CreateJobLogoPicker(controller: controller),
                  ),
                  _FieldGroup(
                    label: 'Department',
                    isRequired: false,
                    child: CreateJobInputField(
                      controller: controller.departmentController,
                      hint: 'e.g. Engineering (Optional)',
                    ),
                  ),
                  _FieldGroup(
                    label: 'Reporting Line',
                    isRequired: false,
                    child: CreateJobInputField(
                      controller: controller.reportingLineController,
                      hint: 'e.g. Head of Department (Optional)',
                    ),
                  ),
                  _FieldGroup(
                    label: 'Location',
                    isRequired: false,
                    child: CreateJobInputField(
                      controller: controller.locationController,
                      hint: 'Enter Job Location (Optional)',
                    ),
                  ),
                  _FieldGroup(
                    label: 'Job Type',
                    isRequired: true,
                    child: Obx(
                      () => CreateJobPickerField(
                        text: controller.labelForValue(
                          controller.jobTypeLabelToValue,
                          controller.jobType.value,
                        ),
                        placeholder: 'Select job type',
                        onTap: () => _showSelectionSheet(
                          context: context,
                          labels: controller.jobTypeLabels,
                          onSelected: (value) {
                            controller.jobType.value =
                                controller.jobTypeLabelToValue[value] ?? '';
                          },
                        ),
                      ),
                    ),
                  ),
                  _FieldGroup(
                    label: 'Salary Type',
                    isRequired: false,
                    child: Obx(
                      () => CreateJobPickerField(
                        text: controller.labelForValue(
                          controller.salaryTypeLabelToValue,
                          controller.salaryType.value,
                        ),
                        placeholder: 'Select salary type',
                        onTap: () => _showSelectionSheet(
                          context: context,
                          labels: controller.salaryTypeLabels,
                          onSelected: (value) {
                            controller.salaryType.value =
                                controller.salaryTypeLabelToValue[value] ?? '';
                          },
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _FieldGroup(
                          label: 'Minimum Salary',
                          isRequired: false,
                          child: CreateJobInputField(
                            controller: controller.minimumSalaryController,
                            hint: 'e.g. 1100',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _FieldGroup(
                          label: 'Maximum Salary',
                          isRequired: false,
                          child: CreateJobInputField(
                            controller: controller.maximumSalaryController,
                            hint: 'e.g. 2000',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                    ],
                  ),
                  _FieldGroup(
                    label: 'Job Description',
                    isRequired: true,
                    child: CreateJobInputField(
                      controller: controller.descriptionController,
                      hint: 'Describe the role and work scope',
                      maxLines: 6,
                    ),
                  ),
                  _FieldGroup(
                    label: 'Main Responsibilities',
                    isRequired: false,
                    child: CreateJobListInput(
                      hint: 'Add a responsibility or paste bullet list',
                      inputController:
                          controller.responsibilitiesInputController,
                      items: controller.responsibilities,
                      onAdd: () => controller.addListItem(
                        controller.responsibilitiesInputController,
                        controller.responsibilities,
                      ),
                      onRemove: (index) => controller.removeListItem(
                        controller.responsibilities,
                        index,
                      ),
                    ),
                  ),
                  _FieldGroup(
                    label: 'Requirements',
                    isRequired: false,
                    child: CreateJobListInput(
                      hint: 'Add a requirement',
                      inputController: controller.requirementsInputController,
                      items: controller.requirements,
                      onAdd: () => controller.addListItem(
                        controller.requirementsInputController,
                        controller.requirements,
                      ),
                      onRemove: (index) => controller.removeListItem(
                        controller.requirements,
                        index,
                      ),
                    ),
                  ),
                  _FieldGroup(
                    label: 'Benefits',
                    child: CreateJobListInput(
                      hint: 'Add a benefit',
                      inputController: controller.benefitsInputController,
                      items: controller.benefits,
                      onAdd: () => controller.addListItem(
                        controller.benefitsInputController,
                        controller.benefits,
                      ),
                      onRemove: (index) =>
                          controller.removeListItem(controller.benefits, index),
                    ),
                  ),
                  _FieldGroup(
                    label: 'Professional Skills',
                    child: CreateJobListInput(
                      hint: 'Add a professional skill',
                      inputController:
                          controller.professionalSkillsInputController,
                      items: controller.professionalSkills,
                      onAdd: () => controller.addListItem(
                        controller.professionalSkillsInputController,
                        controller.professionalSkills,
                      ),
                      onRemove: (index) => controller.removeListItem(
                        controller.professionalSkills,
                        index,
                      ),
                    ),
                  ),
                  _FieldGroup(
                    label: 'Other Facilities',
                    child: CreateJobListInput(
                      hint: 'Add another facility',
                      inputController:
                          controller.otherFacilitiesInputController,
                      items: controller.otherFacilities,
                      onAdd: () => controller.addListItem(
                        controller.otherFacilitiesInputController,
                        controller.otherFacilities,
                      ),
                      onRemove: (index) => controller.removeListItem(
                        controller.otherFacilities,
                        index,
                      ),
                    ),
                  ),
                  _FieldGroup(
                    label: 'Experience Level',
                    isRequired: true,
                    child: Obx(
                      () => CreateJobPickerField(
                        text: controller.labelForValue(
                          controller.experienceLevelLabelToValue,
                          controller.experienceLevel.value,
                        ),
                        placeholder: 'Select experience level',
                        onTap: () => _showSelectionSheet(
                          context: context,
                          labels: controller.experienceLevelLabels,
                          onSelected: (value) {
                            controller.experienceLevel.value =
                                controller.experienceLevelLabelToValue[value] ??
                                '';
                          },
                        ),
                      ),
                    ),
                  ),
                  Obx(() {
                    if (controller.experienceLevel.value == 'other') {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _FieldGroup(
                          label: 'Custom Experience Requirements',
                          isRequired: false,
                          child: CreateJobInputField(
                            controller:
                                controller.otherExperienceLevelController,
                            hint: 'Enter custom experience requirements',
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  Obx(
                    () => Row(
                      children: [
                        Expanded(
                          child: _FieldGroup(
                            label: 'Minimum Experience',
                            isRequired: false,
                            child: CreateJobInputField(
                              controller:
                                  controller.minimumExperienceController,
                              hint: 'e.g. 1',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _FieldGroup(
                            label: 'Maximum Experience',
                            isRequired: false,
                            child: CreateJobInputField(
                              controller:
                                  controller.maximumExperienceController,
                              hint: 'e.g. 3',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _FieldGroup(
                    label: 'Application Deadline',
                    isRequired: true,
                    child: Obx(
                      () => CreateJobPickerField(
                        text: controller.applicationDeadline.value == null
                            ? ''
                            : '${controller.applicationDeadline.value!.month.toString().padLeft(2, '0')}/${controller.applicationDeadline.value!.day.toString().padLeft(2, '0')}/${controller.applicationDeadline.value!.year}',
                        placeholder: 'mm/dd/yyyy',
                        icon: Icons.calendar_today_outlined,
                        onTap: () => controller.pickDeadline(context),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          10,
          20,
          20 + MediaQuery.of(context).padding.bottom,
        ),
        child: Obx(
          () => CustomButton(
            text: controller.isSubmitting.value
                ? controller.loadingText
                : controller.submitButtonText,
            onPressed:
                controller.isSubmitting.value ? null : controller.submitJob,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Future<void> _showSelectionSheet({
    required BuildContext context,
    required List<String> labels,
    required ValueChanged<String> onSelected,
  }) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => ListView(
        shrinkWrap: true,
        children: labels
            .map(
              (label) => ListTile(
                title: Text(label),
                onTap: () => Navigator.of(context).pop(label),
              ),
            )
            .toList(),
      ),
    );
    if (selected != null) {
      onSelected(selected);
    }
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;

  _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.sectionBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _FieldGroup extends StatelessWidget {
  final String label;
  final Widget child;
  final bool isRequired;

  _FieldGroup({
    required this.label,
    required this.child,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CreateJobFieldLabel(text: label, isRequired: isRequired),
          child,
        ],
      ),
    );
  }
}
