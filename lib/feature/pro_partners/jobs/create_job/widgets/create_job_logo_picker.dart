import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/pro_partners/jobs/create_job/controller/create_job_controller.dart';

class CreateJobLogoPicker extends StatelessWidget {
  final CreateJobController controller;

  const CreateJobLogoPicker({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final File? file = controller.companyLogoFile.value;
      final String imageUrl = controller.companyLogoUrl.value ?? '';
      final bool hasImage = file != null || imageUrl.isNotEmpty;

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.sectionBorderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: controller.isUploadingLogo.value
                  ? null
                  : controller.pickCompanyLogo,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.panelBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.textfieldBorderColor,
                    style: BorderStyle.solid,
                  ),
                ),
                child: hasImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: file != null
                            ? Image.file(file, fit: BoxFit.cover)
                            : Image.network(imageUrl, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.cloud_upload_outlined,
                            size: 32,
                            color: AppColors.secondaryTextColor,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            controller.isUploadingLogo.value
                                ? 'Uploading logo...'
                                : 'Tap to upload company logo',
                            style: const TextStyle(
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            if (hasImage) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.isUploadingLogo.value
                          ? 'Uploading...'
                          : 'Logo uploaded successfully',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.mutedTextColor,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: controller.isUploadingLogo.value
                        ? null
                        : controller.removeCompanyLogo,
                    child: const Text('Remove'),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }
}
