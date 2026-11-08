// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import '../controller/add_job_controller.dart';

class BasicDetailsWidget extends StatelessWidget {
  final AddJobController controller = Get.find();

  BasicDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      hintStyle: TextStyle(color: AppColors.darkGray9CA3AF),
      filled: true,
      fillColor: AppColors.ghostWhiteF8FAFF,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.transparent),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Position Name',
          style: TextStyle(color: AppColors.darkSlateGray374151, fontSize: 14),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller.titleController,
          onChanged: (v) => controller.title.value = v,
          decoration: inputDecoration.copyWith(hintText: 'Enter your title'),
        ),
        SizedBox(height: 12),
        Text(
          'Organization',
          style: TextStyle(color: AppColors.darkSlateGray374151, fontSize: 14),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller.organizationController,
          onChanged: (v) => controller.organization.value = v,
          decoration: inputDecoration.copyWith(
            hintText: 'Enter your Organization name',
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Department',
          style: TextStyle(color: AppColors.darkSlateGray374151, fontSize: 14),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller.departmentController,
          onChanged: (v) => controller.department.value = v,
          decoration: inputDecoration.copyWith(hintText: 'Ex. Engineering'),
        ),
        SizedBox(height: 12),
        Text(
          'Location',
          style: TextStyle(color: AppColors.darkSlateGray374151, fontSize: 14),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller.locationController,
          onChanged: (v) => controller.location.value = v,
          decoration: inputDecoration.copyWith(
            hintText: 'Ex. San Francisco, USA',
          ),
        ),

        SizedBox(height: 12),
        Text(
          'Contract type',
          style: TextStyle(color: AppColors.darkSlateGray374151, fontSize: 14),
        ),
        SizedBox(height: 8),
        // ── Contract type dropdown ──────────────────────────────────────────
        Obx(() {
          final value = controller.contractType.value;
          return DropdownButtonFormField<String>(
            value: value == '' ? null : value,
            decoration: inputDecoration,
            items: [
              'Full Time',
              'Part Time',
              'Contract',
              'Temporary',
              'Freelancer',
              'Internship',
              'Other',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) {
              controller.contractType.value = v ?? '';
              // Clear the custom type when switching away from Other
              if (v != 'Other') {
                controller.otherJobTypeController.clear();
                controller.otherJobType.value = '';
              }
            },
          );
        }),
        // ── "Specify" text field — only visible when Other is selected ──────
        Obx(() {
          if (controller.contractType.value != 'Other') {
            return const SizedBox.shrink();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12),
              Text(
                'Specify Contract Type',
                style: TextStyle(
                  color: AppColors.darkSlateGray374151,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: controller.otherJobTypeController,
                onChanged: (v) => controller.otherJobType.value = v,
                decoration: inputDecoration.copyWith(
                  hintText: 'e.g. Apprenticeship, Volunteer...',
                ),
              ),
            ],
          );
        }),

        SizedBox(height: 12),
        Text(
          'Minimum Salary (Optional)',
          style: TextStyle(color: AppColors.darkSlateGray374151, fontSize: 14),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller.minSalaryController,
          onChanged: (v) => controller.minSalary.value = v,
          keyboardType: TextInputType.text,
          decoration: inputDecoration.copyWith(
            hintText: 'e.g. 2000 or Nil (leave blank to skip)',
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Maximum Salary (Optional)',
          style: TextStyle(color: AppColors.darkSlateGray374151, fontSize: 14),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller.maxSalaryController,
          onChanged: (v) => controller.maxSalary.value = v,
          keyboardType: TextInputType.text,
          decoration: inputDecoration.copyWith(
            hintText: 'e.g. 5000 or Nil (leave blank to skip)',
          ),
        ),

        SizedBox(height: 12),
        Text(
          'Salary Type (Optional)',
          style: TextStyle(color: AppColors.darkSlateGray374151, fontSize: 14),
        ),
        SizedBox(height: 8),
        Obx(() {
          final value = controller.salaryType.value;
          return DropdownButtonFormField<String>(
            value: value == '' ? null : value,
            decoration: inputDecoration,
            items: [
              'Annual',
              'Monthly',
              'Weekly',
              'Daily',
              'Hourly',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => controller.salaryType.value = v ?? '',
          );
        }),

        SizedBox(height: 12),
        Text(
          'Minimum Experience',
          style: TextStyle(color: AppColors.darkSlateGray374151, fontSize: 14),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller.minExperienceController,
          onChanged: (v) => controller.minExperience.value = v,
          decoration: inputDecoration.copyWith(hintText: '0 Years'),
        ),
        SizedBox(height: 12),
        Text(
          'Maximum Experience',
          style: TextStyle(color: AppColors.darkSlateGray374151, fontSize: 14),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller.maxExperienceController,
          onChanged: (v) => controller.maxExperience.value = v,
          decoration: inputDecoration.copyWith(hintText: '4 Years'),
        ),

        SizedBox(height: 12),
        Text(
          'Qualifications',
          style: TextStyle(color: AppColors.darkSlateGray374151, fontSize: 14),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller.qualificationsController,
          onChanged: (v) => controller.qualifications.value = v,
          decoration: inputDecoration.copyWith(hintText: 'E.X Bachelor Degree'),
        ),

        SizedBox(height: 12),
        Text(
          'Main Responsibilities',
          style: TextStyle(color: AppColors.darkSlateGray374151, fontSize: 14),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller.responsibilitiesController,
          onChanged: (v) {
            final list = v
                .split(RegExp(r'[\r\n,]+'))
                .map((s) => s.trim().replaceFirst(RegExp(r'^[\u2022\u25E6\u2023\u2219\*\-\–\—\+]\s*'), '').trim())
                .where((s) => s.isNotEmpty)
                .toList();
            controller.responsibilities.value = list.join(', ');
          },
          maxLines: 4,
          decoration: inputDecoration.copyWith(
            hintText: 'Enter responsibilities (one per line, bullet points, or comma-separated)',
          ),
        ),

        SizedBox(height: 12),
        Text(
          'Benefits',
          style: TextStyle(color: AppColors.darkSlateGray374151, fontSize: 14),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller.benefitsController,
          onChanged: (v) {
            final list = v
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
            controller.benefits.value = list.join(', ');
          },
          maxLines: 3,
          decoration: inputDecoration.copyWith(
            hintText: 'Enter benefits (comma-separated)',
          ),
        ),

        SizedBox(height: 12),
        Text(
          'Other Facilities',
          style: TextStyle(color: AppColors.darkSlateGray374151, fontSize: 14),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller.otherFacilitiesController,
          onChanged: (v) {
            final list = v
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
            controller.otherFacilities.value = list.join(', ');
          },
          maxLines: 3,
          decoration: inputDecoration.copyWith(
            hintText: 'Enter other facilities (comma-separated)',
          ),
        ),

        SizedBox(height: 12),
        SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Close Date',
              style: TextStyle(color: AppColors.darkSlateGray374151, fontSize: 14),
            ),
            SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (d != null) controller.closeDate.value = d;
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.ghostWhiteF8FAFF,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: Obx(
                  () => Text(
                    controller.closeDate.value == null
                        ? 'Pick a Date'
                        : controller.closeDate.value!
                              .toLocal()
                              .toString()
                              .split(' ')[0],
                    style: TextStyle(color: AppColors.secondaryTextColor),
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 12),
        Text(
          'Professional Skills',
          style: TextStyle(color: AppColors.darkSlateGray374151, fontSize: 14),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller.skillsController,
          onChanged: (v) {
            final list = v
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
            controller.skills.assignAll(list);
          },
          decoration: inputDecoration.copyWith(hintText: 'Ex. Leadership'),
        ),
      ],
    );
  }
}
