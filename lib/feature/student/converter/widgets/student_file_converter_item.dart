import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/const/icons_path.dart';
import 'package:msollaally/core/const/appcolors.dart';
import '../controller/student_file_converter_controller.dart';

class StudentFileConverterItem extends StatelessWidget {
  const StudentFileConverterItem({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<StudentFileConverteController>()
        ? Get.find<StudentFileConverteController>()
        : Get.put(StudentFileConverteController());

    return Obx(() {
      final isUploading = controller.isUploading.value;
      
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 16.height),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.radius),
          color: AppColors.fileConverterUploadFileBGColor,
          border: Border.all(
            color: isUploading
                ? AppColors.primaryButtonColor
                : AppColors.fileConverterUploadFileBorderColor,
            width: isUploading ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: isUploading
                        ? SizedBox(
                            width: 24.width,
                            height: 24.height,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryButtonColor),
                            ),
                          )
                        : Container(
                            padding: EdgeInsets.all(8.radius),
                            decoration: BoxDecoration(
                              color: AppColors.primaryButtonColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.radius),
                            ),
                            child: Icon(
                              Icons.insert_drive_file_rounded,
                              size: 24.fontSize,
                              color: AppColors.primaryButtonColor,
                            ),
                          ),
                  ),
                  SizedBox(width: 16.width),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.uploadedFileName.value.isNotEmpty
                              ? controller.uploadedFileName.value
                              : 'No file selected',
                          style: appTextStyleHeading1(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2.fontSize,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (controller.uploadedFileSize.value.isNotEmpty) ...[
                          SizedBox(height: 4.height),
                          Text(
                            controller.uploadedFileSize.value,
                            style: appTextStyleHeading2(
                              fontSize: 12.fontSize,
                              fontWeight: FontWeight.w500,
                              letterSpacing: .02.fontSize,
                              color: AppColors.dimGray52525B,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (controller.uploadedFileName.value.isNotEmpty && !isUploading)
              InkWell(
                onTap: controller.removeFile,
                borderRadius: BorderRadius.circular(20.radius),
                child: Container(
                  padding: EdgeInsets.all(8.radius),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    IconsPath.uploadFileXIcon,
                    height: 14.height,
                    width: 14.width,
                    // ignore: deprecated_member_use
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
