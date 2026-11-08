import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/student/campus/union/create_union/controller/create_union_controller.dart';

class CreateUnionFormFields extends StatelessWidget {
  const CreateUnionFormFields({super.key, required this.controller});

  final CreateUnionController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField(
          'Union Name',
          controller.nameController,
          'Enter union name',
        ),
        SizedBox(height: 16.height),
        _buildTextField(
          'Description',
          controller.descriptionController,
          'Enter description',
          maxLines: 3,
        ),
        SizedBox(height: 16.height),
        _buildCategoryDropdown(),
        SizedBox(height: 16.height),
        _buildTextField(
          'Website',
          controller.websiteController,
          'https://example.com',
        ),
        SizedBox(height: 16.height),
        _buildTextField(
          'Email',
          controller.emailController,
          'union@university.edu',
        ),
        SizedBox(height: 16.height),
        _buildTextField(
          'Contact Number',
          controller.contactNumberController,
          '+1234567890',
        ),
        SizedBox(height: 16.height),
        _buildTextField(
          'Tags',
          controller.tagsController,
          'chess, strategy, competition (comma separated)',
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController textController,
    String hint, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: appTextStyleHeading2(fontWeight: FontWeight.w600)),
        SizedBox(height: 8.height),
        TextField(
          controller: textController,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey, fontSize: 14.fontSize),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.width,
              vertical: 12.height,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.radius),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.radius),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.radius),
              borderSide: const BorderSide(color: AppColors.primaryButtonColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: appTextStyleHeading2(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.height),
        Obx(
          () => DropdownButtonFormField<String>(
            initialValue: controller.category.value,
            items: ['entertainment', 'academic', 'sports', 'social', 'other']
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e.capitalizeFirst!),
                  ),
                )
                .toList(),
            onChanged: (value) => controller.category.value = value!,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.width,
                vertical: 12.height,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.radius),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.radius),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
