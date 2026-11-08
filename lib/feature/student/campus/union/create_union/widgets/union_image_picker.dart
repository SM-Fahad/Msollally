import 'dart:io';
import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/student/campus/union/create_union/controller/create_union_controller.dart';

class UnionImagePickers extends StatelessWidget {
  const UnionImagePickers({super.key, required this.controller});

  final CreateUnionController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildPicker(
            label: 'Logo',
            onTap: controller.pickLogo,
            pathObs: controller.logoPath,
          ),
        ),
        SizedBox(width: 16.width),
        Expanded(
          child: _buildPicker(
            label: 'Cover Image',
            onTap: controller.pickCover,
            pathObs: controller.coverPath,
          ),
        ),
      ],
    );
  }

  Widget _buildPicker({
    required String label,
    required VoidCallback onTap,
    required RxString pathObs,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: appTextStyleHeading2(fontWeight: FontWeight.w600)),
        SizedBox(height: 8.height),
        GestureDetector(
          onTap: onTap,
          child: Obx(
            () => Container(
              height: 100.height,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.radius),
                border: Border.all(color: Colors.grey[300]!),
                image: pathObs.value.isNotEmpty
                    ? DecorationImage(
                        image: FileImage(File(pathObs.value)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: pathObs.value.isEmpty
                  ? const Center(
                      child: Icon(Icons.add_a_photo, color: Colors.grey),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
